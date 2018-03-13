FROM php:7.2
MAINTAINER Mikołaj Pich "m.pich@outlook.com"

RUN apt update && apt install -y \
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

  # node & npm
  && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt update && apt install -y nodejs \

  # composer
  && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
  && rm -f /tmp/composer-setup.* \

  # composer parallel install
  && composer global require hirak/prestissimo:^0.3 \

  && docker-php-source extract \

  && docker-php-ext-configure gd \
      --with-gd \
      --with-freetype-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \

  && NPROC=$(getconf _NPROCESSORS_ONLN) \

  && docker-php-ext-install -j${NPROC} gd \
        mysqli \
        opcache \
        pdo_mysql \

  && pecl install \
        memcached-3.0.3 \

  && docker-php-ext-enable \
        memcached \

  && docker-php-source delete
