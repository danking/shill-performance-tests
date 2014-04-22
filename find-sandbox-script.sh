#!/bin/bash

PATH_TO_LINUX=$1
PATH_TO_TEST_LOGS=$2
PATH_TO_SHILL=$3
RUNS=$4
PATH_TO_TESTS=$5

function die() { echo "find-sandbox-script.sh: $@" 1>&2 ; exit 1; }

[ "$#" -eq 5 ] || die "5 arguments required, $# provided"

TEST_NAME=find-yes-sandbox
COMMAND=${PATH_TO_SHILL}/sandbox/sandbox
ARGS=(${PATH_TO_TEST_LOGS}/../find-sandbox.policy \
      /usr/bin/find ${PATH_TO_LINUX} -name '*.c' -exec grep -Hi torvalds '{}' \;)

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL

