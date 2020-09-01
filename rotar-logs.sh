!/bin/bash
# Rotar el archivo de registro de trazas de navegacion de squid
# en un directorio destinado para ello
# La tarea se realiza a las 11 y 59 pm de cada dia

# Permisos de ejecucion
# chmod a+rx /usr/local/sbin/rotar-logs.sh

# Agregar a la lista de tareas en crontab
# 59 23 * * * /usr/local/sbin/rotar-logs.sh

# ubicacion del directorio base de logs de squid
LOGFILEDIR=/var/log/squid

# ubicacion del log de acceso
LOGFILE=${LOGFILEDIR}/access.log

# ubicacion del log de cache
CACHEFILE=${LOGFILEDIR}/cache.log

# ubicacion del log de store
STOREFILE=${LOGFILEDIR}/store.log

# directorio base para la rotacion
BASEDIR=/var/squid-logs

# directorio de almacenamiento de logs
LOGDIR=${BASEDIR}/$(date +%Y)/$(date +%m).$(date +%B)

# nombre de archivo del log
FILENAME=access-$(date +%d%H%M).log

# comprobar que existe el directorio de almacenamiento de logs
# si no existe, crearlo.
if [ ! -d ${LOGDIR} ]; then
mkdir -p ${LOGDIR}
fi

# detener el servicio de squid
/etc/init.d/squid stop

# Pausa interna de bash de ejecucion
sleep 30s

# No dejar vivo a ningun hilo de demonio suelto por ahi
killall squid

# Esperamos otro poquito para garantizar que ya es el otro dia
sleep 30s

# Repetimos el llamado por si tu kernel es sopenco y no acaba de realizar la tarea
killall squid

# mover el log hacia el directorio de almacenamiento de logs
cp ${LOGFILE} ${LOGDIR}/${FILENAME}

# vaciar access.log
cat /dev/null > ${LOGFILE}

# vaciar store.log
cat /dev/null > ${STOREFILE}

# vaciar cache.log
cat /dev/null > ${CACHEFILE}

# arrancamos el servicio de squid
/etc/init.d/squid start

# Regla de oro. Si un script finaliza de forma satisfactoria emite un mensaje de OK == 0
exit 0
