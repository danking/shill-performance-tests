#!/bin/bash

LOG_DIR=$(date "+logs--%Y-%m-%d--%H:%M:%S")
LOG_PATH=~/tests/${LOG_DIR}
mkdir ${LOG_PATH}

if [ $? -ne 0 ]
then
    echo "Could not create ~/tests/${LOG_DIR}, failing."
    exit 1
fi

for i in `seq 0 10`
do
    echo "Test $i"
    echo "Test $i" > ${LOG_PATH}/no-sandbox-times
    /usr/bin/time -al -o ${LOG_PATH}/no-sandbox-times \
        find . -name '*.c' -exec grep -Hi torvalds '{}' ';' > ${LOG_PATH}/no-sandbox.$i
done
