# Étape 1 : Builder Flutter Web
FROM cirrusci/flutter:stable AS build

WORKDIR /app
COPY . .

# Résolution des dépendances
RUN flutter pub get

# Build Web
RUN flutter build web

# Étape 2 : Serveur nginx
FROM nginx:alpine

# Copie du build Flutter vers nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copie de la config nginx si besoin (facultatif)
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
