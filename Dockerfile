FROM ubuntu:20.04
LABEL maintainer="Fernando Santana <fernandosantanajr@gmail.com>"
LABEL version="0.0.2"
LABEL description="php7.3, php8.0 and nodejs 14"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y curl zip unzip \
    git supervisor software-properties-common

RUN add-apt-repository -y ppa:ondrej/php

RUN add-apt-repository -y ppa:ondrej/nginx

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update --fix-missing

RUN apt-get install -y nginx nodejs mysql-client

RUN apt-get install -y php8.0-fpm php8.0-cli \
        php8.0-curl php8.0-mysql php8.0-mbstring \
        php8.0-xml php8.0-zip php8.0-xdebug php8.0-gd php8.0-imagick

RUN apt-get install -y php7.3-fpm php7.3-cli \
        php7.3-curl php7.3-mysql php7.3-mbstring \
        php7.3-xml php7.3-zip php7.3-xdebug php7.3-gd php7.3-imagick

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php

RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
    &&  sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/7.3/fpm/php-fpm.conf \
    &&  sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.3/fpm/php.ini \
    &&  sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/8.0/fpm/php-fpm.conf \
    &&  sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/8.0/fpm/php.ini

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN usermod -u 1000 www-data

ENV npm_config_cache=/tmp/.npm

CMD ["supervisord"]
