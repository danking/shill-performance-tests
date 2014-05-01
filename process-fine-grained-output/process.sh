#!/bin/bash

function die() { echo "process.sh: $@" 1>&2 ; exit 1; }

RESULTS_DIR="results"
mkdir -p $RESULTS_DIR

[ ! -e $RESULTS_DIR/summary ] || die "Ensure that ${RESULTS_DIR}/summary does not exist"

for file in info.*
do
    [[ "$file" =~ info\.(.*) ]] || die "$file is not of the form info.(.*)"
    i="${BASH_REMATCH[1]}"

    INFO_FILE=$file
    LOG_FILE=log.$i

    [ -e log.$i ] || die "Ensure that log.$i exists"

    cat $INFO_FILE $LOG_FILE | awk -f extract-stats.awk >> $RESULTS_DIR/summary
done
