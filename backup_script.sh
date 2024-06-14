#!/bin/bash

function show_help() {
    echo "Uso: $0 [ORIGEN] [DESTINO]"
    echo "Realiza un backup de los directorios especificados."
    echo "Argumentos:"
    echo "  ORIGEN  Directorio de origen que se desea respaldar"
    echo "  DESTINO Directorio de destino donde se guardarán los respaldos"
    echo "Opciones:"
    echo "  -h      Muestra esta ayuda"
    exit 1
}

# Verifica si se ha pasado la opción de ayuda
if [[ $1 == "-h" ]]; then
    show_help
fi

# Verifica que se hayan pasado los argumentos requeridos
if [ $# -ne 2 ]; then
    echo "Error: Se requieren dos argumentos: ORIGEN y DESTINO"
    show_help
fi

ORIGEN=$1
DESTINO=$2

# Verifica que los directorios de origen y destino existan
if [ ! -d "$ORIGEN" ]; then
    echo "Error: El directorio de origen $ORIGEN no existe o no está montado."
    exit 1
fi

if [ ! -d "$DESTINO" ]; then
    echo "Error: El directorio de destino $DESTINO no existe o no está montado."
    exit 1
fi

# Función para realizar el backup
function backup() {
    local src=$1
    local dest=$2
    local base_name=$(basename $src)
    local date=$(date +%Y%m%d)
    local filename="${dest}/${base_name}_bkp_${date}.tar.gz"
    #EJEMPLO: etc_bkp_20240302.tar.gz
    tar -czf "$filename" -C "$src" .
    if [ $? -eq 0 ]; then
        echo "Backup de $src completado con éxito en $filename"
    else
        echo "Error al realizar el backup de $src"
    fi
}

backup $ORIGEN $DESTINO 

exit 0

