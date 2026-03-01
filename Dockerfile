FROM alpine:3.18

# Instala ffmpeg, bash e ferramentas de rede
RUN apk add --no-cache ffmpeg bash iputils

# Cria o diretório de vídeos
WORKDIR /app
RUN mkdir -p /videos

# Copia o script para dentro do container
COPY microservices.sh /app/record.sh
RUN chmod +x /app/record.sh

# Define o volume para persistência
VOLUME ["/videos"]

# Executa o script
ENTRYPOINT ["/bin/bash", "/app/record.sh"]

