FROM ruby:2.5.3

ENV LANG C.UTF-8
ENV DOCKERIZE_VERSION v0.6.1

RUN apt-get update -qq && \
    apt-get install -y curl && \
    apt-get install -y wget && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs \
                       imagemagick --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && \
    wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN mkdir -p /var/www/workspace
ENV RAILS_ROOT /var/www/workspace
WORKDIR $RAILS_ROOT

RUN mkdir -p $RAILS_ROOT/tmp/sockets
COPY ./Gemfile $RAILS_ROOT/Gemfile
# COPY ./workspace/Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

COPY . $RAILS_ROOT

# ENV BUNDLE_PATH $RAILS_ROOT/vendor/bundle/ruby/2.5.0
