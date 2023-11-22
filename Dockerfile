FROM ruby:3.1-alpine

RUN apk update && apk add build-base tzdata shared-mime-info nodejs  postgresql-dev postgresql-client imagemagick imagemagick-dev imagemagick-libs yarn

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME
RUN bundle install -j4

EXPOSE 3000

COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
