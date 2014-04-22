#!/bin/bash

PATH_TO_LINUX=~/linux

TEST_NAME=grep-recursive
COMMAND="grep"
ARGS=(-R --include="*.c" -H Torvalds ${PATH_TO_LINUX})
RUNS=11
PATH_TO_TEST_LOGS=~/tests/results
PATH_TO_SHILL=~/shill

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL
