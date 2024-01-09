# Usa la imagen oficial de Nginx como base
FROM nginx:latest

# Copia tu archivo index.html al directorio de trabajo de Nginx
COPY index.html /usr/share/nginx/html

# Expone el puerto 80 para que puedas acceder a la aplicación web
EXPOSE 80