#!/bin/bash

PATH_TO_LINUX=~/linux

TEST_NAME=find-no-kmod
COMMAND="find"
ARGS=(${PATH_TO_LINUX} -name '*.c' -exec grep -Hi torvalds '{}' \;)
RUNS=11
PATH_TO_TEST_LOGS=~/tests/results
PATH_TO_SHILL=~/shill

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL
