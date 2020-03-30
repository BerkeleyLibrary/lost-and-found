FROM ruby:2.5-alpine3.7 AS base

ARG APP_USER=lostandfound
ARG APP_UID=40040

RUN addgroup -S -g $APP_UID $APP_USER && \
    adduser -S -u $APP_UID -G $APP_USER $APP_USER && \
    mkdir -p /opt/app /var/opt/app && \
    chown -R $APP_USER:$APP_USER /opt/app /var/opt/app /usr/local/bundle

RUN apk --no-cache --update upgrade && \
    apk --no-cache add \
        bash \
        ca-certificates \
        git \
        libc6-compat \
        nodejs \
        openssl \
        tzdata \
        mariadb-client-libs \
        xz-libs \
        yarn \
    && rm -rf /var/cache/apk/*

WORKDIR /opt/app

USER $APP_USER

ENV PATH="/opt/app/bin:$PATH" \
    RAILS_LOG_TO_STDOUT=yes

ENTRYPOINT ["/opt/app/bin/docker-entrypoint.sh"]
CMD ["server"]

FROM base AS development

# Temporarily switch back to root to install build packages.
USER root

# Install system packages needed to build gems with C extensions.
RUN apk --update --no-cache add \
        build-base \
        coreutils \
        git \
    rm -rf /var/cache/apk/*

# Drop back to app user
USER $APP_USER

# Workaround for certificate issue pulling av_core gem from git.lib.berkeley.edu
ENV GIT_SSL_NO_VERIFY=1

# The base image ships bundler 1.17.2, but on macOS, Ruby 2.6.4 comes with
# bundler 1.17.3 as a default gem, and there's no good way to downgrade.
RUN gem install bundler -v 1.17.3

# Install gems. We do this first in order to maximize cache reuse, and we
# do it only in the development image in order to minimize the size of the
# final production image (which just copies the build products from dev)
COPY --chown=$APP_USER Gemfile* ./
RUN bundle install --jobs=$(nproc) --deployment --path=/usr/local/bundle

# Copy the rest of the codebase.
COPY --chown=$APP_USER . .



FROM base AS production

# Run as the app user to minimize risk to the host.
USER $APP_USER

# Copy the built codebase from the dev stage
COPY --from=development --chown=$APP_USER /opt/app /opt/app
COPY --from=development --chown=$APP_USER /usr/local/bundle /usr/local/bundle
COPY --from=development --chown=$APP_USER /var/opt/app /var/opt/app

RUN bundle check
# Default container port (for documentation only)
# see https://docs.docker.com/engine/reference/builder/#expose
RUN rails assets:precompile
EXPOSE 3000
VOLUME ["/opt/app/public"]
ENV RACK_ENV=production RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true

