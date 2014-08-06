#!/usr/local/bin/bash

function die() { echo "generic-test.sh: $@" 1>&2 ; exit 1; }

# arguments

DIR="$1"
shift
SIZES="$@"

[ -n "${DIR}" ] || die "You need to provide a directory to place the test files"

# executable portion

for SIZE in $SIZES
do
    dd if=/dev/zero of="${DIR}/test-$SIZE" bs=${SIZE} count=1
done
