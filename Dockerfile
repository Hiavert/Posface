FROM php:8.1-apache

# Instalar extensiones necesarias
RUN docker-php-ext-install pdo pdo_mysql

# Copiar todo el código al contenedor
COPY . /var/www/html/

# Ajustar permisos para storage y bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Activar mod_rewrite de Apache
RUN a2enmod rewrite

# Copiar configuración de Apache personalizada
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Exponer puerto 80
EXPOSE 80

# Comando para iniciar Apache en primer plano
CMD ["apache2-foreground"]
