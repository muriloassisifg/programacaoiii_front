# Dockerfile para Flutter Web
FROM debian:stable-slim AS build-env

# Instala dependências necessárias para Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone o Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Define variáveis de ambiente
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Habilita Flutter Web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Cria diretório de trabalho
WORKDIR /app

# Copia arquivos do projeto
COPY pubspec.* ./
RUN flutter pub get

COPY . .

# Build da aplicação web
RUN flutter build web --release

# Stage 2: Servidor Nginx para servir os arquivos
FROM nginx:alpine

# Copia os arquivos buildados para o Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copia configuração customizada do Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expõe a porta
EXPOSE 80

# Comando para iniciar o Nginx
CMD ["nginx", "-g", "daemon off;"]
