#!/bin/bash

function die() { echo "test.sh: $@" 1>&2 ; exit 1; }

cc open-read-write.c || die "Couldn't compile open-read-write.c"

mkdir -p results
LOG_FILE=$(date "+sandboxed-log--%Y-%m-%d--%H:%M:%S")
touch results/${LOG_FILE} || die "Couldn't touch results/${LOG_FILE}"

echo "fopen fread fwrite" > results/${LOG_FILE}

for i in `seq 0 100`
do
    echo Test ${i}:  sandboxed
    racket syscall-test.amb >> results/${LOG_FILE}
done

LOG_FILE=$(date "+nosandbox-log--%Y-%m-%d--%H:%M:%S")
touch results/${LOG_FILE}

echo "fopen fread fwrite" > results/${LOG_FILE}

for i in `seq 0 100`
do
    echo Test ${i}: no sandbox
    ./a.out >> results/${LOG_FILE}
done
