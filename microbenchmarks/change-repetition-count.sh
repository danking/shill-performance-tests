#!/bin/bash

FILES=(cwu.c mkdir.c orc.c owc.c r.c w.c)

for file in ${FILES[@]}
do
    echo $file
    TEMPFILE=$(mktemp "$0.XXXXXX")
    cat $file | sed "s/REPETITIONS $1/REPETITIONS $2/" > ${TEMPFILE}
    mv ${TEMPFILE} ${file}
done
