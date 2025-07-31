FROM php:8.2-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    unzip git libpq-dev libzip-dev && \
    docker-php-ext-install pdo pdo_mysql zip && \
    a2enmod rewrite

# Copiar archivos del proyecto
WORKDIR /var/www/html
COPY . .

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instalar dependencias Laravel
RUN composer install --no-dev --optimize-autoloader

# Limpiar y cachear configuración (sin romper build)
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache || true

# Copiar virtualhost
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Copiar script de inicio
COPY .docker/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
