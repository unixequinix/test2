############################################################
# Dockerfile to build Web container images
# Based on Ubuntu:16.04
############################################################

FROM ubuntu:16.04
RUN apt-get update -qq

ENV RUBY_VERSION 2.5.0

# Basics
RUN apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN apt-get install -y --no-install-recommends apt-utils build-essential tzdata openssl libpq-dev libssl-dev xvfb libfontconfig wkhtmltopdf locales curl git
RUN apt-get install -y nginx openssh-server git-core openssh-client
RUN apt-get install -y nano

# Use en_US.UTF-8 as our locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install RVM, Ruby, and Bundler
RUN echo "gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
RUN echo progress-bar >> ~/.curlrc
RUN curl -L https://get.rvm.io | bash -s
RUN echo "source /usr/local/rvm/scripts/rvm" >> /etc/bash.bashrc
RUN bash -l -c "rvm requirements"
RUN bash -l -c "rvm install --default $RUBY_VERSION"

# Set the app directory var
ENV APP_HOME /home/api

# Install bundler
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

# Copy required files
WORKDIR $APP_HOME

# Copy app on path
ADD . $APP_HOME/

##################### INSTALLATION ENDS #####################
# Avoid bundle exec command
EXPOSE 3000
ENTRYPOINT ["bash", "-lc"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
