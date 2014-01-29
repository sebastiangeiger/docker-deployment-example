# This is mostly copied together from
# http://dockerfile.github.io/#/nginx and https://github.com/zumbrunnen/docker-rails
# Run it with: `docker run -d -name <containername> -link <dbcontainer>:db -v /var/www/<dir>:/var/www/<dir> -e APP_NAME=<appname> zumbrunnen/rails`

FROM ubuntu:13.10
MAINTAINER Sebastian Geiger <sebastian.geiger@mo-stud.io>

# Setting environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV APP_RUBY_VERSION 2.0.0
ENV RAILS_ENV production
ENV DB_USERNAME docker
ENV DB_PASSWORD docker

#Preparing apt-get
RUN apt-get -qq update
RUN apt-get -yqq upgrade

# Installing ruby 2.0.0-p353 from source
RUN apt-get -yqq install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev wget
RUN cd /tmp && wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz && tar -xvzf ruby-2.0.0-p353.tar.gz
RUN cd /tmp/ruby-2.0.0-p353/ && ./configure --prefix=/usr/local && make && make install

# Install Postgres
RUN apt-get install -yqq postgresql-client libpq5 libpq-dev

# Install Nodejs to satisfy the execjs gem
RUN apt-get install -yqq nodejs

# Install Passenger / Nginx
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN apt-get -yqq install apt-transport-https ca-certificates
ADD passenger.list /etc/apt/sources.list.d/passenger.list
RUN chown root: /etc/apt/sources.list.d/passenger.list
RUN chmod 600 /etc/apt/sources.list.d/passenger.list
RUN apt-get -qq update
RUN apt-get -yqq install nginx-extras passenger
# ADD nginx.conf ...

# Copy application files over
ADD . /app
RUN cd /app && sh install_app

# Now run it
EXPOSE 80
CMD ["/usr/bin/nginx"]
