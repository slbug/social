FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2

RUN gem update --system && gem install bundler

WORKDIR /usr/src/app

COPY Gemfile* ./

RUN bundle config set without 'development test'

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
