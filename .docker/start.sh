#!/bin/sh
# Esperar a que la DB esté disponible
echo "⏳ Esperando MySQL..."
until php -r "new PDO('mysql:host=${DB_HOST};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}');" 2>/dev/null; do
  sleep 3
  echo "⏳ Esperando conexión..."
done

# Ejecutar migraciones
php artisan migrate --force || true

# Iniciar Apache
exec apache2-foreground
