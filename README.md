# computacion-aplicada-tp-up
Computación Aplicada TP 2024
FRANCO CESPI - IGNACIO CASTELLUCCI - JOAQUÍN SALAS - RAFAEL ALDANA

Repo requerido en el trabajo practico de la materia Computación Aplicada en la Universidad de Palermo

## Armado de entorno

1. La máquina virtual está dividida en 9 partes, se deben descargar y ensamblar con el compresor rar. Puede ser utilizado winrar.

2. Se debe tener presente que a la máquina virtual en cuestión no se le conoce la clave de root, por lo que es necesario realizar el blanqueo de la misma previo a realizar las actividades. La clave debe cambiarse a “123456” (sin las comillas).

3. Configurar apt y descargar programas

### Resolucion

-! Recordar deshabilitar el segundo adaptador desde Virtual Box antes de iniciar la maquina virtual
- Iniciar la maquina y en la pantalla de boot presionar la tecla `e`
- Modificar la linea de booteo de `ro quiet` (read-only) a `rw init=/bin/bash`
- Crl + x para continuar con esos cambios
- Utilizar el comando passwd para habilitar el cambio de password y ingresar ‘123456’

NOTA: los comandos se ejecutan loageado al sistema como root user
```bash
# Hacer una copia de backup del archivo sources.list original
mv /etc/apt/sources.list /etc/apt/sources.list.bak

# Modificar archivo de apt para poder descargar paquetes utlizando:
# deb http://deb.debian.org/debian buster main contrib non-free
# deb-src http://deb.debian.org/debian buster main contrib non-free
echo "deb http://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list

# aplicar los cambios en source.list
apt update

# Instalar paquetes que se utilizaran
apt-get -y install net-tools openssh-server mardiadb-server apache2
```

## Setear Servidores
1. Crear dos maquinas que alberguen un tipo de servidor cada una:

a. WEB. Que tenga instalado y funcionando un servidor Apache con soporte para el lenguaje PHP (Instalar PHP7.3 o superior). Debe servir el archivo index.php que se descarga de BlackBoard y usado en el servidor llamado WebServer
b. MYSQL. Que tenga instalado y funcionando un servidor MySQL o MARIADB. A este motor se le debe cargar el script sql db.sql que se halla en BlackBoard y debe ser usado en el servidor DBServer.

*Nota: Que sea instalado y funcionando un servicio SSH, que permita ingresar al usuario root, con la clave pública que se haya en BlackBoard y será usada para ambos servidores.
*Nota2: Tener presente que solo se puede probar desde la máquina anfitriona o de la misma máquina virtual.

WebServer Machine
| HHD       | RAID     | P.V. | V.G.  | L.V.      | Filesystem  |
|-----------|----------|------|-------|-----------|-------------|
| /dev/sd*1 | /dev/md0 | pv0  | vg_tp | lv_www    | /www_dir    |
|           |          |      |       | lv_backup | /backup_dir |

DBServer
| HHD       | RAID     | P.V. | V.G.  | L.V.      | Filesystem  |
|-----------|----------|------|-------|-----------|-------------|
| /dev/sd*1 | /dev/md0 | pv0  | vg_tp | lv_db     | /db_dir     |
|           |          |      |       | lv_backup | /backup_dir |

*1: Puede ser que el dispositivo sea sdb, sdc o sdd, por eso el “*”en la descripción de los cuadros.


### Resolucion

#### Incorporacion de discos
1. Configurarle un nuevo disco la maquina virtual (apagada)
- Configuracion > Almacenamiento > Añadir disco duro > boton crear
* Reservado dinamicamente
* Configurar ubicacion y tamaño: 3 GB
- Selecionar el nuevo disco creado > Seleccionar > Aceptar

2. Preparar, particionar y formatear el nuevo disco

a. Manualmente
```bash
# listar informacion de los dispositivos de bloque
# lsblk

# listar 'storage divices' detectados
# ls -l /dev/sd*

# cear particion
fdisk /dev/sdb
# input:
# - n
# - p
# - 1
# - ENTER
# - ENTER
# - w

# Contruir un sistema de ficheros / Make filesystem
mkfs -t ext4 /dev/sdb1
```
Input:


b. Automatizado en el script
```bash
# cear particion
fdisk -u -p /dev/sdb <<EOF
n
p
1


w
EOF

# Contruir un sistema de ficheros / Make filesystem
mkfs -t ext4 /dev/sdb1
```

===== serguir viendo video min 1:17:00
# MONTAJE DE DISCOS


# CREACION DE LOS VOLUMENES


# chech apache status using:
# sudo systemctl status apache2

# modify the php.ini file to have a source from a diferent root directory
# modificar el archivo php.ini para que sirva por default desde el directorio /www_dir

# reiniciar apache para que impacten los cambios
apachectl restart
# service apache2 restart


```

2. Los archivos correspondientes a la base de datos creados y los archivos php servidos, deben estar en sus respectivos filesystems diferentes, que se deben crear aparte de la instalación y ser montados al inicio del sistema operativo. En ambos servidores se debe contar con un directorio de Backup para resguardos.

Estos filesystems deben ser montados en 
- /www_dir, /db_dir
- /backup_dir (x2)
  
Siendo /www_dir para los archivos .php servidos en el WebServer (es decir, reemplaza a /var/www), /db_dir para los archivos de la base de datos (es decir que, reemplaza a /var/lib/mysql) en el DBServer, y /backup_dir para los archivos de backup en ambos servidores. Para esto se debe modificar los archivos de configuración de los servicios respectivos (apache2 y mysql).

El tamaño de los mismos es:
- /www_dir: 3GB
- /db_dir: 3GB
- /backup_dir: 6GB

Se deberá implementar esta solución con LVM y RAID 1, de acuerdo a lo visto en clase. Pueden utilizar el siguiente link como apoyo. Los LVs que se creen, tienen que tener los nombres acordes a lo que va a alojar:
- lv_db
- lv_backup
- lv_www.

## Redes
1. Las placas de red deben ser configuradas con el fin de aceptar una IP ESTÁTICA.
2. Los servidores deben contar con una IP LOCAL en sus interfaces del mismo rango para que entre ellos puedan comunicarse.

## Backup
1. Se deberá realizar backup por medio de UN script de desarrollo
propio denominado “backup_full.sh” a los directorios que se
mencionan, con su correspondiente planificación:
a. TODOS LOS DÍAS a las 0 hs: /etc, /var/logs
b. LOS DOMINGOS a las 23 hs: /www_dir
c. LOS LUNES, MIÉRCOLES, VIERNES, /db_dir
2. Los nombres de los archivos deben tener relación con lo respaldado y
contener dentro del nombre la fecha en formato ANSI (YYYYMMDD), por
ejemplo: para /etc, sería “etc_bkp_20240302.tar.gz”
3. Todos los archivos de backup generados deben guardarse en el
filesystem /backup_dir.
4. El script de backup que se desarrolle debe tener la validación de que
los filesystem origen y destino se encuentren disponibles, es decir, que
existan y/o estén montados según corresponda, previamente a la
ejecución del backup.
5. Ambos (origen y destino) deben ser pasados como argumentos al
script.
6. Adicionalmente, el script debe poseer una opción de ayuda “-h”.
Esto implica que el script debe manejar que los argumentos no hayan
sido escritos por el usuario.
7. El script debe ser agregado al cron.

## Entregables
1. Los entregables consisten en los directorios /root, /etc, /opt, /var,
/www_dir, /db_dir y /backup_dir, de cada uno de los servidores. Todos
ellos comprimidos individualmente en formato tar.gz y subidos al
repositorio github que cada equipo haya informado anteriormente.
2. Se debe entregar un diagrama topológico de la infraestructura armada.
NOTA: De ser algunos de los archivos de tamaño considerable, usar el
comando split
