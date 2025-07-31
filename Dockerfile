# Imagen base PHP con Apache y extensiones necesarias
FROM php:8.2-apache

# Instalar dependencias del sistema y extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    unzip git libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql zip

# Habilitar mod_rewrite de Apache
RUN a2enmod rewrite

# Copiar archivo de configuración del VirtualHost
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto
COPY . .

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Variables temporales para evitar errores de DB en build
ENV CACHE_STORE=file
ENV SESSION_DRIVER=file

# Instalar dependencias PHP sin dev y optimizar autoload
RUN composer install --no-dev --optimize-autoloader

# Limpiar caches que no dependen de la DB
RUN php artisan config:clear && php artisan cache:clear && php artisan view:clear

# Dar permisos correctos al storage y bootstrap
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Copiar script de arranque
COPY .docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Exponer puerto 80
EXPOSE 80

# Comando de inicio: primero migraciones, luego Apache
CMD ["/usr/local/bin/start.sh"]

