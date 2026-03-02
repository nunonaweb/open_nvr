#!/bin/bash
# /app/record.sh (dentro do container)

dir='/1tb/video'
user='python'
senha='mandrake'
ip=$CAMERA_IP

cleanup() {
    echo "Sinal de interrupção recebido! Encerrando FFmpeg graciosamente..."
    kill -SIGINT $FFMPEG_PID
    wait $FFMPEG_PID
    exit 0
}

trap cleanup SIGTERM SIGINT
mkdir -p "$dir"

if [ -z "$ip" ]; then
    echo "ERRO: A variável CAMERA_IP não foi definida."
    exit 1
fi

echo "--- Iniciando Monitoramento da Câmera: $ip ---"

if ping -c 1 -W 2 "$ip" &> /dev/null; then
    echo "$(date "+%Y-%m-%d %H:%M:%S") - IP $ip ONLINE. Gravando em MKV segmentado." >> "$dir/pingao.log"

    # MUDANÇA PARA MKV SEGMENTADO
    # O MKV aceita melhor interrupções bruscas sem corromper o arquivo inteiro
    ffmpeg -rtsp_transport tcp -i "rtsp://$user:$senha@$ip:554" \
        -c:v copy -an \
        -f segment \
        -segment_time 600 \
        -segment_atclocktime 1 \
        -strftime 1 \
        -reset_timestamps 1 \
        "$dir/%Y%m%d%H%M%S-${ip##*.}.mkv" &
    
    FFMPEG_PID=$!
    wait $FFMPEG_PID
    
    exit_status=$?
    echo "FFmpeg encerrou com status: $exit_status"
    exit $exit_status
else
    echo "ALERTA: O IP $ip OFFLINE."
    exit 1
fi
