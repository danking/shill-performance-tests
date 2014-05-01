#!/usr/local/bin/bash

PATH_TO_LINUX=$1
PATH_TO_TEST_LOGS=$2
PATH_TO_SHILL=$3
RUNS=$4
PATH_TO_TESTS=$5

function die() { echo "grading-shill-fine-grained-timing-no-contracts.sh $@" 1>&2 ; exit 1; }

[ "$#" -eq 5 ] || die "5 arguments required, $# provided"

TEST_NAME=grading-shill-fine-grained-timing-no-contracts
COMMAND=racket
ARGS=(grade.amb)
BEFORE="cc $PATH_TO_TESTS/nanoseconds.c ; \
pushd ${PATH_TO_TESTS}/../ ; \
racket sed.rkt --off shill/ ; \
popd
pushd ${PATH_TO_SHILL}/examples/grading ; \
bash clean.sh ; \
$PATH_TO_TESTS/a.out"
AFTER="bash clean.sh ; \
popd ; \
pushd ${PATH_TO_TESTS}/../ ; \
racket sed.rkt --on shill/ ; \
popd
"

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL "$BEFORE" "$AFTER"

