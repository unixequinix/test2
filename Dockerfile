############################################################
# Dockerfile to build Web container images
# Based on Ubuntu:16.04
############################################################

FROM ubuntu:16.04
RUN apt-get update -qq

ENV RUBY_VERSION 2.5.0
ENV PASSENGER_VERSION 4.0.37

# Basics
RUN apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN apt-get -y upgrade
RUN apt-get -y install curl libcurl4-gnutls-dev git libxslt-dev libxml2-dev libpq-dev libffi-dev libssl-dev
RUN apt-get install -y --no-install-recommends apt-utils build-essential tzdata openssl imagemagick xvfb libfontconfig wkhtmltopdf locales git
RUN apt-get install -y nginx openssh-server git-core openssh-client
RUN apt-get -y install nodejs
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

RUN /bin/bash -l -c 'gem install passenger --version $PASSENGER_VERSION'
RUN /bin/bash -l -c 'passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx'
RUN /bin/bash -l -c 'gem install bundler --no-rdoc --no-ri'

# Set the app directory var
ENV APP_HOME /home/current

# Install bundler
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

# Copy required files
WORKDIR $APP_HOME
ADD config/glownet/nginx.conf /opt/nginx/conf/nginx.conf
ADD config/glownet/passenger.conf /opt/nginx/conf/passenger.conf

# Copy app on path
ADD . $APP_HOME/

##################### INSTALLATION ENDS #####################
# Avoid bundle exec command
EXPOSE 3000
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["bash", "-lc"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
