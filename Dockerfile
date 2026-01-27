# =============================================================================
# Target: base
#
# The base stage scaffolds elements which are common to building and running
# the application, such as installing ca-certificates, creating the app user,
# and installing runtime system dependencies.
FROM ruby:3.3-slim AS base

# This declares that the container intends to listen on port 3000. It doesn't
# actually "expose" the port anywhere -- it is just metadata. It advises tools
# like Traefik about how to treat this container in staging/production.
EXPOSE 3000

ENV APP_USER=lostandfound
ENV APP_UID=40001

# Create the application user/group and installation directory
RUN groupadd --system --gid $APP_UID $APP_USER \
    && useradd --home-dir /opt/app --system --uid $APP_UID --gid $APP_USER $APP_USER

RUN mkdir -p /opt/app /var/opt/app \
    && chown -R $APP_USER:$APP_USER /opt/app /var/opt/app /usr/local/bundle

# Get list of available packages
RUN apt-get update -qq

# Install standard packages from the Debian repository
RUN apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gpg \
      git \
      libc6 \
      libpq-dev \
      libssl-dev \
      shared-mime-info \
      sqlite3 \
      tzdata \
      xz-utils

# Install Node.js and Yarn from their own repositories

# Add Node.js package repository (version 16 LTS release) & install Node.js
# -- note that the Node.js setup script takes care of updating the package list
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends nodejs

# Add Yarn package repository, update package list, & install Yarn
# TODO: why are we installing Yarn 1.22 instead of 3.x?
# TODO: don't fetch signing key by signature. ref AP-562, yarnpkg/yarn#9216
RUN curl -sL https://keys.openpgp.org/vks/v1/by-fingerprint/72ECF46A56B4AD39C907BBB71646B01B86E50310 | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends yarn

# Remove packages we only needed as part of the Node.js / Yarn repository
# setup and installation -- note that the Node.js setup scripts installs
# a full version of Python, but at runtime we only need a minimal version
RUN apt-mark manual python3-minimal \
    && apt-get autoremove --purge -y \
      curl \
      python3

# ==============================
# Selenium testing

# Workaround for https://github.com/rails/rails/issues/41828
RUN mkdir -p /opt/app/tmp && \
    mkdir -p /opt/app/artifacts/screenshots && \
    ln -s ../artifacts/screenshots /opt/app/tmp/screenshots

# ==============================
# Run configuration

# All subsequent commands are executed relative to this directory.
WORKDIR /opt/app

# Run as the application user to minimize risk to the host.
USER $APP_USER

# Add binstubs to the path.
ENV PATH="/opt/app/bin:$PATH"

# If run with no other arguments, the image will start the rails server by
# default. Note that we must bind to all interfaces (0.0.0.0) because when
# running in a docker container, the actual public interface is created
# dynamically at runtime (we don't know its address in advance).
#
# Note that at this point, the rails command hasn't actually been installed
# yet, so if the build fails before the `bundle install` step below, you
# will need to override the default command when troubleshooting the buggy
# image.
CMD ["rails", "server", "-b", "0.0.0.0"]

# =============================================================================
# Target: development
#
# The development stage installs build dependencies (system packages needed to
# install all your gems) along with your bundle. It's "heavier" than the
# production target.
FROM base AS development

# ------------------------------------------------------------
# Install build packages

# Temporarily switch back to root to install build packages.
USER root

# Install system packages needed to build gems with C extensions.
RUN apt-get install -y --no-install-recommends \
    g++ \
    make \
    libyaml-dev

USER $APP_USER

# Use a recent version of Bundler
RUN gem install bundler -v 2.5.23

# Install gems. We don't enforce the validity of the Gemfile.lock until the
# final (production) stage.
COPY --chown=$APP_USER:$APP_USER Gemfile* ./
RUN bundle install

COPY --chown=$APP_USER:$APP_USER package.json yarn.lock ./
RUN yarn install

# Copy the rest of the codebase. We do this after bundle-install so that
# changes unrelated to the gemset don't invalidate the cache and force a slow
# re-install.
COPY --chown=$APP_USER:$APP_USER . .

# =============================================================================
# Target: production
#
# The production stage extends the base image with the application and gemset
# built in the development stage. It includes runtime dependencies but not
# heavyweight build dependencies.
FROM base AS production

# Run the production stage in production mode.
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

# Copy the built codebase from the dev stage
COPY --from=development --chown=$APP_USER /opt/app /opt/app
COPY --from=development --chown=$APP_USER /usr/local/bundle /usr/local/bundle
COPY --from=development --chown=$APP_USER /var/opt/app /var/opt/app

# Ensure the bundle is installed and the Gemfile.lock is synced.
RUN bundle config set frozen 'true'
RUN bundle install --local

# Pre-compile assets so we don't have to do it in production.
# NOTE: dummy SECRET_KEY_BASE to prevent spurious initializer issues
#       -- see https://github.com/rails/rails/issues/32947
RUN SECRET_KEY_BASE=1 rails assets:precompile --trace
