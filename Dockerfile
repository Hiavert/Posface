FROM php:8.1-apache

# Instala extensiones necesarias (pdo_mysql, zip, etc)
RUN docker-php-ext-install pdo_mysql zip

# Copia tu código a /var/www/html
COPY . /var/www/html

# Copia configuración personalizada de Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Copia el script de arranque
COPY .docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Instala Composer y dependencias
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader --working-dir=/var/www/html

# Da permisos correctos a storage y bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Exponer puerto (Railway usa uno dinámico pero Apache escucha 80 internamente)
EXPOSE 80

# Arranca con nuestro script para usar el puerto correcto
CMD ["/usr/local/bin/start.sh"]

