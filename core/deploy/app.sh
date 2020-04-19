#!/bin/bash

set -e

APP_NAME="tp-core"
ROOT=$(dirname "$(readlink -e $0)")

SCRIPT=$ROOT/bin/$APP_NAME
LOG_XML="$ROOT/config/logback.xml"

if [ -f $LOG_XML ]; then
    LOG_CONFIG="-Dlogback.configurationFile=$LOG_XML"
else
    LOG_CONFIG=""
fi

CONFIG_FILE="$ROOT/config/application.conf"

if [ -f $CONFIG_FILE ]; then
    CONFIG="-Dconfig.file=$ROOT/config/application.conf"
else
    CONFIG=""
fi

if [ -z "$2" ]; then
    N=0
else
    N=$2
fi

NN=$(printf %02d $N)

CC="-Dnode=$N -Dhttp.port=500${N}1 -Dakka.remote.netty.tcp.port=500${N}2" # -Dio.netty.tryReflectionSetAccessible=true --add-exports java.base/jdk.internal.misc=ALL-UNNAMED"

ID=$(uuidgen)
EXTRA="-Dapp-uuid=$ID"
RUN_DIR="/run/tp/${APP_NAME}/$N"
mkdir -pv ${RUN_DIR}
PID_FILE_NAME=${RUN_DIR}/${APP_NAME}-${ID}.pid

JDK_VERSION_MAIN=$(javap -verbose java.lang.Object | grep "major version" | cut -d " " -f5)

GC_OPTS="-XX:+UseG1GC"

if [[ $JDK_VERSION_MAIN -gt 54 ]]; then
  GC_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
else
  GC_OPTS="-XX:+UseG1GC"
fi

export JAVA_OPTS="-Dapp-name=${APP_NAME} -Xmx4G -Xms4G -server $GC_OPTS $JAVA_OPTS"

RUN_COMMAND="bash $SCRIPT $CC $CONFIG $LOG_CONFIG $EXTRA"

function runServer() {
    nohup $RUN_COMMAND > /dev/null 2>&1 &
    sleep 2
    pid=$(ps -ef | grep "$ID" | grep -v grep | awk '{print $2}')
    if [ -n "$pid" ]; then
        echo $pid > $PID_FILE_NAME
        echo "server started. pid: $pid"
    else
        echo "starting failed!"
    fi
}

function runStop() {
    fs=$(ls $RUN_DIR | grep "${APP_NAME}-")
    for i in $(ls $RUN_DIR | grep "${APP_NAME}-")
    do
        pid=$(cat $RUN_DIR/$i)
        kill $pid || echo "process $pid not exist."
        rm -vfr $RUN_DIR/$i
        echo "service stopped. pid: $pid"
    done
}

function runRestart() {
    runStop && runServer
}

case $1 in
    run)
        $RUN_COMMAND
 	      ;;
    start | server)
        runServer
        ;;
    stop)
        runStop
        ;;
    restart)
        runRestart
        ;;
    *)
        $RUN_COMMAND
        ;;
esac

exit 0
