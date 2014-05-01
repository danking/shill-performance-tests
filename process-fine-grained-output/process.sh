#!/bin/bash

function die() { echo "process.sh: $@" 1>&2 ; exit 1; }

RESULTS_DIR="results"
mkdir -p $RESULTS_DIR

for file in info.*
do
    [[ "$file" =~ info\.(.*) ]] || die "$file is not of the form info.(.*)"
    i="${BASH_REMATCH[1]}"

    INFO_FILE=$file
    LOG_FILE=log.$i

    [ ! -e summary.$i -a ! -e result.$i ] || die "Ensure that neither summary.$i nor result.$i exist"

    [ -e log.$i ] || die "Ensure that log.$i exists"

    cat $INFO_FILE $LOG_FILE | awk -f extract-stats1.awk > $RESULTS_DIR/summary.$i

    cat $LOG_FILE | awk -f clear-before-pkg-native.awk | awk -f extract-stats2.awk > $RESULTS_DIR/result.$i
done
