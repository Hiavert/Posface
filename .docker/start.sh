#!/bin/bash
set -e

echo ">> Ejecutando migraciones..."
php artisan migrate --force || echo ">> Migraciones fallaron o ya están aplicadas."

echo ">> Optimizando caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo ">> Iniciando Apache..."
exec apache2-foreground
