#!/bin/bash

# Configurações
TARGET_DIR="/1tb/video"
THRESHOLD=80

# Verifica a percentagem de uso do disco onde está o diretório
USAGE=$(df "$TARGET_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')

echo "$(date "+%Y-%m-%d %H:%M:%S") - Uso atual do disco: $USAGE%"

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "Disco acima de $THRESHOLD%. Iniciando limpeza de arquivos MKV antigos..."
    
    # Lista arquivos MKV por data (mais antigos primeiro) e remove 
    # Removemos de 10 em 10 para não apagar tudo de uma vez
    find "$TARGET_DIR" -name "*.mkv" -type f -printf '%T+ %p\n' | sort | head -n 20 | awk '{print $2}' | xargs rm -f
    
    echo "Limpeza concluída. Verificando novo status..."
    df -h "$TARGET_DIR"
else
    echo "Espaço em disco ok. Nada a fazer."
fi
