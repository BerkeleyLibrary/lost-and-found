# ============================================================================
# Target: base
# Includes system dependencies common to both dev and production.
FROM ruby:2.6.5-alpine AS base

# This is just metadata and doesn't actually "expose" this port. Rather, it
# tells other tools (e.g. Traefik) what port the service in this image is
# expected to listen on.
#
# @see https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 3000

# Standard documentation. Jenkins injects the build info automatically,
# allowing us to trace the provenance of a particular image.
LABEL edu.berkeley.lib.build-number="${BUILD_NUMBER}"
LABEL edu.berkeley.lib.build-url="${BUILD_URL}"
LABEL edu.berkeley.lib.git-commit="${GIT_COMMIT}"
LABEL edu.berkeley.lib.git-repo="${GIT_URL}"
LABEL edu.berkeley.lib.project-tier="4-hour response during business-hours"
LABEL edu.berkeley.lib.project-description="The Lost and Found Application \
is a proprietary service belonging to the UCB library system, tasked with \
tracking lost items found on library premises."

RUN addgroup -S -g 40001 lostandfound \
&&  adduser -S -u 40001 -G lostandfound lostandfound \
&&  install -o lostandfound -g lostandfound -d /opt/app \
&&  chown -R lostandfound:lostandfound /opt

RUN apk --no-cache --update upgrade \
&&  apk --no-cache add \
        bash \
        ca-certificates \
        git \
        libc6-compat \
        mariadb-connector-c-dev \
        nodejs \
        openssl \
        sqlite-libs \
        postgresql-libs \
        tzdata \
        xz-libs \
        wget \
        shared-mime-info \
        yarn \
&&  rm -rf /var/cache/apk/*

# Add and trust InCommon's CA certificates
RUN cd /usr/local/share/ca-certificates \
&&  wget https://gist.githubusercontent.com/danschmidt5189/e7aa0c94342013c348987ca9470265ed/raw/47ef2ea414789ca50d755b99031dbcbb58d6d915/entrust-g2-ca-cert.pem \
&&  wget https://gist.githubusercontent.com/danschmidt5189/e7aa0c94342013c348987ca9470265ed/raw/47ef2ea414789ca50d755b99031dbcbb58d6d915/entrust-l1k-ca-cert.pem \
&&  wget https://gist.githubusercontent.com/danschmidt5189/e7aa0c94342013c348987ca9470265ed/raw/47ef2ea414789ca50d755b99031dbcbb58d6d915/incommon-rsa-server-ca-cert.pem \
&&  update-ca-certificates

WORKDIR /opt/app

# ============================================================================
# Target: development
# Installs all dependencies, requiring the (large) build-base package. Build
# artifacts are copied out in the final stage.
FROM base AS development

# Install system packages needed to build gems with C extensions.
RUN apk --update --no-cache add \
        build-base \
        coreutils \
        mariadb-dev \
        postgresql-dev \
        sqlite-dev

USER lostandfound

# The base image ships bundler 1.17.2, but on macOS, Ruby 2.6.4 comes with
# bundler 1.17.3 as a default gem, and there's no good way to downgrade.
RUN gem install bundler -v 2.2.4

# Install gems by copying over just the Gemfiles ruby version file. We do this
# before copying over the rest of the codebase to avoid invalidating the
# Docker cache and forcing an unnecessary bundle-install.
COPY --chown=lostandfound .ruby-version Gemfile* ./
RUN bundle install --path /usr/local/bundle

COPY --chown=lostandfound . .

# Extend the path to include our binstubs. Note that this must be done after
# we've installed the application (and these scripts) otherwise you'll run
# into weird path-related issues.
ENV PATH "/opt/app/bin:$PATH"

RUN rails assets:precompile

CMD ["rails", "server"]

# ============================================================================
# Target: production
# Slimmed down, extending the 'base' stage with only the built package from
# the 'development' stage.
FROM base AS production

# Run as the app user to minimize risk to the host.
USER lostandfound

# Copy the built codebase from the dev stage
COPY --from=development --chown=lostandfound /opt/app /opt/app
COPY --from=development --chown=lostandfound /usr/local/bundle /usr/local/bundle
ENV PATH "/opt/app/bin:$PATH"

# Sanity-check that everything was installed correctly and still runs in the
# slimmed-down production image.
RUN bundle install --deployment --local --path=/usr/local/bundle \
&&  rails log:clear tmp:clear

CMD ["rails", "server"]
