#!/bin/sh

echo "🚀 Starting Laravel container..."

# Copy .env if not exists
# if [ ! -f .env ]; then
#   echo "📄 Creating .env file..."
#   cp .env.example .env
# fi

# Generate app key if not set
# if ! grep -q "APP_KEY=base64" .env; then
#   echo "🔑 Generating app key..."
#   php artisan key:generate
# fi

# Wait for MySQL
echo "⏳ Waiting for database..."
until php -r "
try {
    new PDO('mysql:host=' . getenv('DB_HOST') . ';dbname=' . getenv('DB_DATABASE'), getenv('DB_USERNAME'), getenv('DB_PASSWORD'));
    echo 'DB connected';
} catch (Exception \$e) {
    exit(1);
}
"; do
  sleep 2
done

echo "✅ Database ready"

# Run migrations
php artisan migrate --force

# Optional: seed
# php artisan db:seed --force

echo "🔥 Laravel is ready!"

# Start php-fpm
exec php-fpm
