#!/bin/sh
# Cambia el puerto 80 por el que te asigna Railway ($PORT)
sed -i "s/80/${PORT}/g" /etc/apache2/sites-available/000-default.conf

# Arranca Apache en foreground (importante para que el contenedor no se cierre)
apache2ctl -D FOREGROUND

