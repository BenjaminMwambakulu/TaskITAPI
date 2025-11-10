# Stage 1: PHP dependencies
FROM composer:latest AS composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Stage 2: Node.js dependencies and build
FROM node:20-alpine AS node

WORKDIR /app
COPY package.json package-lock.json ./
COPY resources/js ./resources/js
COPY resources/css ./resources/css
COPY vite.config.js ./
RUN npm ci
RUN npm run build

# Stage 3: Production PHP image
FROM php:8.4-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    postgresql-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    zip \
    libzip-dev \
    unzip

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    bcmath \
    gd \
    zip \
    opcache

# Configure opcache for production
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Set working directory
WORKDIR /var/www

# Copy composer dependencies from composer stage
COPY --from=composer /app/vendor /var/www/vendor

# Copy frontend build from node stage
COPY --from=node /app/public/build /var/www/public/build

# Copy application files
COPY . /var/www

# Generate optimized composer autoload
RUN composer dump-autoload --no-dev --optimize

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Configure PHP-FPM
COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Expose port 9000
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]