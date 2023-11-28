# Start from a small, trusted base image with the version pinned down
FROM ruby:3.1-alpine AS base

# Install system dependencies required both at runtime and build time
# The image uses Postgres
RUN apk add --update \
  tzdata \
  shared-mime-info \
  nodejs \
  postgresql-dev \
  postgresql-client \
  imagemagick \
  imagemagick-dev \
  imagemagick-libs \
  yarn

# This stage will be responsible for installing gems and npm packages
FROM base AS dependencies

# Install system dependencies required to build some Ruby gems (pg)
RUN apk add --update build-base

# Create a non-root user to run the app and own app-specific files
RUN adduser -D mva-official-site-user

# Set app home directory and chowm it to non-root user
ENV APP_HOME /app
RUN mkdir $APP_HOME
RUN chown mva-official-site-user $APP_HOME
# We'll install the app in this directory
WORKDIR $APP_HOME
COPY --chown=mva-official-site-user . $APP_HOME
COPY --chown=mva-official-site-user migrate-database.sh /$APP_HOME
RUN chmod +x migrate-database.sh

# Install gems (excluding development/test dependencies)
RUN bundle install --jobs=4 --retry=3

# COPY package.json yarn.lock ./

# Install npm packages
# RUN yarn install --frozen-lockfile

# We're back at the base stage
FROM base

# Switch to non-root user
USER mva-official-site-user

# Copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

# Copy over npm packages from the dependencies stage
# Note that we have to use `--chown` here
# COPY --chown=mva-official-site-user --from=dependencies /node_modules/ node_modules/

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
# COPY --chown=mva-official-site-user . ./

# Set variables parameters
ENV RAILS_ENV=development
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV LOG_LEVEL=debug
ENV DISABLE_DATABASE_ENVIRONMENT_CHECK=1
ENV RAILS_ENV=development
ENV BIND_ON=0.0.0.0:3000
ENV RAILS_MAX_THREADS=4
ENV WEB_CONCURRENCY=2
ENV REQUEST_TIMEOUT=30
ENV LAUNCHY_DRY_RUN=true
ENV BROWSER=/dev/null

# Postgre parametrs
ENV POSTGRESQL_SERVICE=db
ENV POSTGRESQL_USER=minvet
ENV POSTGRESQL_PASSWORD=minvet1!PP
ENV POSTGRESQL_DATABASE=minvet
ENV DATABASE_URL=postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_SERVICE:5432/$POSTGRESQL_DATABASE?encoding=utf8&pool=40

# Finded that in the source code need to test
ENV PORT=3000

# Need to test if that still needed
EXPOSE 3000

# Install assets
# RUN RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile

# Launch the server
CMD ["./migrate-database.sh"]
# CMD ["bundle", "exec", "rackup"]
