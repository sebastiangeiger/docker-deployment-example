# This is mostly copied together from
# http://dockerfile.github.io/#/nginx and https://github.com/zumbrunnen/docker-rails
# Run it with: `docker run -d -name <containername> -link <dbcontainer>:db -v /var/www/<dir>:/var/www/<dir> -e APP_NAME=<appname> zumbrunnen/rails`

FROM ubuntu:12.10
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

# Install Nginx.
RUN apt-get install -yqq software-properties-common
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get install -yqq nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Install supervisord
RUN apt-get install -yqq supervisor

# Attach volumes.
# VOLUME /etc/nginx/sites-enabled
# VOLUME /var/log/nginx
#
# # Set working directory.
# WORKDIR /etc/nginx
#
# Create startup file for passenger and start supervisord
ADD start_passenger /opt/start_passenger
ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD passenger.conf /etc/supervisor/conf.d/passenger.conf

# Copy files over
RUN mkdir -p /var/www
ADD . /var/www/docker-deployment-example
RUN cd /var/www/docker-deployment-example && sh install_app

# Now run supervisord
EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
