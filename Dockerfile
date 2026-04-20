FROM php:8.4-fpm-alpine

WORKDIR /var/www

# System deps + PHP extensions needed by Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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
RUN groupadd -g 1000 www && useradd -u 1000 -ms /bin/bash -g www www

USER www

EXPOSE 9000

CMD ["php-fpm"]
