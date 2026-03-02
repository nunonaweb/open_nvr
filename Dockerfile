FROM alpine:3.18

# Instala ffmpeg, bash e ferramentas de rede (iputils para o ping)
RUN apk add --no-cache ffmpeg bash iputils tzdata

# Cria o diretório de trabalho e o ponto de montagem
WORKDIR /app
RUN mkdir -p /1tb/video

# Copia o script mantendo o nome ou renomeando (ajustado para o que o YAML espera)
COPY microservices.sh /app/record.sh
RUN chmod +x /app/record.sh

# Não precisamos da instrução VOLUME aqui, pois o Kubernetes gerencia o HostPath
# Mas vamos garantir que o diretório tenha permissões
RUN chmod 777 /1tb/video

# Executa o script. 
# Usar a forma de "exec" (com colchetes) é melhor para o repasse de sinais
ENTRYPOINT ["/bin/bash", "/app/record.sh"]
