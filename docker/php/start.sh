#!/bin/sh

# Create SQLite database directory if it doesn't exist
mkdir -p /var/www/database

# Create SQLite database file if it doesn't exist
if [ ! -f /var/www/database/database.sqlite ]; then
    touch /var/www/database/database.sqlite
    chown -R www-data:www-data /var/www/database
fi

# Start PHP-FPM
php-fpm