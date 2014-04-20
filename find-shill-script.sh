#!/bin/bash




LOG_DIR=$(date "+logs--%Y-%m-%d--%H:%M:%S")
LOG_PATH=~/tests/find-exec/shill/${LOG_DIR}
mkdir ${LOG_PATH}

if [ $? -ne 0 ]
then
    echo "Could not create ${LOG_PATH}, failing."
    exit 1
fi

for i in `seq 0 10`
do
    echo "Test $i"
    echo "Test $i" >> ${LOG_PATH}/times
    /usr/bin/time -al -o ${LOG_PATH}/times \
        racket find-exec.amb > ${LOG_PATH}/log.$i
done
