#!/bin/bash
# /app/record.sh (dentro do container)

# Configurações fixas (podem ser movidas para Env Vars depois se desejar)
dir='/1tb/video'
user='python'
senha='mandrake'

# O IP é injetado pelo Kubernetes via Variável de Ambiente
ip=$CAMERA_IP

# Garante que o diretório de destino existe
mkdir -p "$dir"

# Verifica se a variável CAMERA_IP foi passada
if [ -z "$ip" ]; then
    echo "ERRO: A variável CAMERA_IP não foi definida."
    exit 1
fi

# Obtém a data/hora para o nome do arquivo
ano=$(date +%Y)
mes=$(date +%m)
dia=$(date +%d)
hora=$(date +%H)
minuto=$(date +%M)

# Extrai o final do IP para identificação no nome do arquivo
numero_ip=$(echo "$ip" | sed 's/.*\.//')
nome_arquivo="$dir/$ano$mes$dia$hora$minuto-$numero_ip.mp4"

echo "--- Iniciando Monitoramento da Câmera: $ip ---"

# Verifica se a câmera está acessível antes de iniciar
if ping -c 1 -W 2 "$ip" &> /dev/null; then
    data_log=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$data_log - IP $ip está ONLINE. Iniciando gravação." >> "$dir/pingao.log"
    
    echo "Gravando em: $nome_arquivo"

    # EXECUÇÃO DO FFMPEG
    # Note: Removemos o '&' do final. O container viverá enquanto o ffmpeg rodar.
    ffmpeg -rtsp_transport tcp -i rtsp://$user:$senha@"$ip":554 \
        -map 0:v -c:v libx264 -preset ultrafast -crf 23 \
        -pix_fmt yuv420p -an -vsync 1 \
        "$nome_arquivo"
    
    # Se o ffmpeg parar, o script chegará aqui e o container será reiniciado pelo K8s
    exit_status=$?
    echo "FFmpeg encerrou com status: $exit_status"
    exit $exit_status

else
    echo "ALERTA: O IP $ip não respondeu ao ping. Abortando para reinício automático."
    exit 1
fi
