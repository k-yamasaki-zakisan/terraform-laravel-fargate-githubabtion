FROM php:8.1-apache

# dockerからの実行でログファイルなどを作れるようにするために権限周りを変更
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

RUN apt update \
    && apt install -y \
    g++ \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    zip \
    zlib1g-dev \
    git \
    && docker-php-ext-install \
    intl \
    opcache \
    pdo \
    pdo_pgsql \
    pgsql

ENV TZ Asia/Tokyo

RUN  a2enmod rewrite

# apacheの設定ファイルを設置
COPY ./docker/deploy/000-default.conf /etc/apache2/sites-enabled/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./src /var/www/html
WORKDIR /var/www/html

RUN rm .env
RUN composer install

COPY ./docker/deploy/entry_point.sh /var/www/html/entry_point.sh
RUN chmod a+x /var/www/html/entry_point.sh
ENTRYPOINT /var/www/html/entry_point.sh