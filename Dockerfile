FROM php:8.2
LABEL maintainer="d.hoffmann@mac.com"

ENV DEPLOYER_VERSION=7.3.0

RUN apt-get update && apt-get install -y \
        git \
        jq \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmemcached-dev \
        libpng-dev \
        gnupg \
        build-essential \
        zip unzip \
        zlib1g-dev \
        rsync \
        openssh-client

# node
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
      && apt-get install -y nodejs

# update npm to last version
RUN npm i -g npm

# composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --2.2 \
  && rm -f /tmp/composer-setup.*

RUN docker-php-source extract \
  && NPROC=$(getconf _NPROCESSORS_ONLN) \
  && docker-php-ext-install -j${NPROC} gd \
        mysqli \
        opcache \
        pdo_mysql

RUN docker-php-source delete

# Install Deployer
COPY install_deployer.php /

RUN php /install_deployer.php
RUN rm /install_deployer.php

RUN composer global require deployer/recipes --dev


