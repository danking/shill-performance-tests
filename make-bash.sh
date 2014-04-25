#!/usr/local/bin/bash

PATH_TO_LINUX=$1
PATH_TO_TEST_LOGS=$2
PATH_TO_SHILL=$3
RUNS=$4
PATH_TO_TESTS=$5

function die() { echo "make-bash.sh: $@" 1>&2 ; exit 1; }

[ "$#" -eq 5 ] || die "5 arguments required, $# provided"

TEST_NAME=make-bash
COMMAND="make"
ARGS=()
BEFORE="pushd ${PATH_TO_SHILL}/examples/packages/emacs ; bash clean.sh ; bash pre-make.sh"
AFTER="popd"

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL "$BEFORE" "$AFTER"
