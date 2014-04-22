#!/bin/bash

PATH_TO_LINUX=$1
PATH_TO_TEST_LOGS=$2
PATH_TO_SHILL=$3
RUNS=$4
PATH_TO_TESTS=$5

function die() { echo "find-shill-script.sh: $@" 1>&2 ; exit 1; }

[ "$#" -eq 5 ] || die "5 arguments required, $# provided"

TEST_NAME=find-exec-shill-no-spawn
COMMAND="racket"
ARGS=(find-exec.amb)

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL
