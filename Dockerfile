FROM php:8.4-fpm-alpine

WORKDIR /var/www

# System deps + PHP extensions needed by Laravel
RUN apk add --no-cache \
    git \
    curl \
    unzip \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy composer files first for layer caching
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader --prefer-dist

# Copy the rest of the source
COPY . .

# Finish autoloader + run post-install scripts
RUN composer dump-autoload --optimize

# In dev: storage & bootstrap/cache must be writable
RUN chmod -R 777 storage bootstrap/cache

# Create a non-root user — security best practice
RUN addgroup -g 1000 www && adduser -u 1000 -D -G www www

USER www

EXPOSE 9000

CMD ["php-fpm"]

