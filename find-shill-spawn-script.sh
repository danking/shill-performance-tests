#!/bin/bash

PATH_TO_LINUX=~/linux

TEST_NAME=find-exec-shill-yes-spawn
COMMAND="racket"
ARGS=(find-exec-spawn.amb)
RUNS=11
PATH_TO_TEST_LOGS=~/tests/results
PATH_TO_SHILL=~/shill

bash generic-test.sh $TEST_NAME $COMMAND "${ARGS[*]}" $RUNS $PATH_TO_TEST_LOGS $PATH_TO_SHILL
