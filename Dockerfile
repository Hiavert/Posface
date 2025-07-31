FROM php:8.1-apache

# Instala dependencias para zip y mysql
RUN apt-get update && apt-get install -y libzip-dev unzip

# Instala extensiones necesarias (pdo_mysql, zip)
RUN docker-php-ext-install pdo_mysql zip

# Copia tu código
COPY . /var/www/html

# Copia configuración apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Copia script de arranque
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Instala composer y dependencias
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader --working-dir=/var/www/html

# Da permisos correctos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]


