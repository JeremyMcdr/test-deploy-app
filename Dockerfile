# Test Deploy App - Dockerfile
# Image nginx légère pour servir une page statique

FROM nginx:alpine

# Copier la configuration nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers statiques
COPY src/ /usr/share/nginx/html/

# Exposer le port 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Commande par défaut
CMD ["nginx", "-g", "daemon off;"]
