
############################################################
# Dockerfile to build Web container images
# Based on Ubuntu:16.04
############################################################

FROM phusion/passenger-customizable
ENV RUBY_VERSION 2.4.1
RUN /pd_build/ruby-$RUBY_VERSION.sh
RUN bash -lc "rvm --default use ruby-$RUBY_VERSION"

# set the app directory var
ENV APP_HOME /home/web

RUN apt-get update -qq

# Install apt dependencies
RUN apt-get install -y --no-install-recommends \
    build-essential \
    curl libssl-dev \
    git \
    locales \
    tzdata \
    libpq-dev \
    nodejs \
    xvfb libfontconfig wkhtmltopdf

# Use en_US.UTF-8 as our locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Enable Nginx
RUN rm -f /etc/service/nginx/down

# Copy required files 
WORKDIR ${APP_HOME}
ADD Gemfile* ${APP_HOME}/

# Install gems to /bundle
ENV BUNDLE_GEMFILE=${APP_HOME}/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle

RUN bundle install

# Copy app on path
ADD . ${APP_HOME}/

##################### INSTALLATION ENDS #####################

EXPOSE 3000
CMD ["/sbin/my_init"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
