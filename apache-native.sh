#!/usr/local/bin/bash

PATH_TO_LINUX=$1
PATH_TO_TEST_LOGS=$2
PATH_TO_SHILL=$3
RUNS=$4
PATH_TO_TESTS=$5

function die() { echo "apache-native.sh: $@" 1>&2 ; exit 1; }

[ "$#" -eq 5 ] || die "5 arguments required, $# provided"

TEST_NAME=apache-native
COMMAND="ab"
ARGS=(-c 100 -n 1000 127.0.0.1/emacs-24.3.tar.gz)
BEFORE="pushd ${PATH_TO_SHILL}/examples/apache ; httpd"
AFTER="httpd -k stop ; popd"

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL "$BEFORE" "$AFTER"
