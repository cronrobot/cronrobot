FROM ruby:3.0.1-alpine

ARG ENVIRONMENT

ENV PORT=3030
ENV RAILS_ENV=${ENVIRONMENT}
ENV RACK_ENV=${ENVIRONMENT}
ENV RAILS_ROOT /opt/app

WORKDIR /opt/app

RUN mkdir -p /opt/app
RUN touch /boot.sh # this is the script which will run on start
RUN echo 'set -e' >> /boot.sh

RUN apk add --no-cache build-base tzdata git sqlite-dev postgresql-dev sqlite-dev nodejs

# daemon for cron jobs
RUN echo 'echo will install crond...' >> /boot.sh
RUN echo 'crond' >> /boot.sh

COPY Gemfile* ./
RUN bundle install --jobs 20 --retry 5

COPY . .

# compile assets
RUN apk add --no-cache npm
RUN npm install -g yarn
RUN yarn
RUN RAILS_ENV=${ENVIRONMENT} bin/rails assets:precompile

RUN echo 'echo db:migrate' >> /boot.sh
RUN echo 'bin/rails db:migrate' >> /boot.sh

# launch the application
RUN echo 'echo starting the application' >> /boot.sh
CMD sh /boot.sh && bundle exec rails s