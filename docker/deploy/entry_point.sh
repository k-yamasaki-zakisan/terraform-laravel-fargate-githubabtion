#!/bin/sh

composer install
php artisan cache:clear
php artisan config:clear
chmod -R 777 storage
php artisan migrate --force
php artisan serve --host=0.0.0.0 --port=80