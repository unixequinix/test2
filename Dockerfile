############################################################
# Dockerfile to build Web container images
# Based on Ubuntu:16.04
############################################################

FROM phusion/passenger-customizable:0.9.26
ENV RUBY_VERSION 2.4.2
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

# Copy required files 
WORKDIR ${APP_HOME}
ADD Gemfile* ${APP_HOME}/

# Avoid bundle exec command
ENTRYPOINT ["bundle", "exec"]

# Install gems to /bundle
# ENV BUNDLE_GEMFILE=${APP_HOME}/Gemfile \
#     BUNDLE_JOBS=2 \
#     BUNDLE_PATH=/bundle
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

RUN bundle check || bundle install --binstubs="$BUNDLE_BIN"

# Copy app on path
ADD . ${APP_HOME}/

##################### INSTALLATION ENDS #####################

EXPOSE 3000
CMD ["/sbin/my_init"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
