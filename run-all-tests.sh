#!/bin/bash

SCRIPTS=(find-no-kmod-script.sh find-sandbox-script.sh \
         find-script.sh find-shil-script.sh find-shill-spawn-script.sh \
         grep-recursive-script.sh)

PATH_TO_LINUX=~/linux
PATH_TO_TEST_LOGS=~/tests/results
PATH_TO_SHILL=~/shill
PATH_TO_TESTS=~/tests

for s in ${SCRIPTS[*]}
do
    echo ">> Executing $s"
    bash $s $PATH_TO_LINUX $PATH_TO_TEST_LOGS $PATH_TO_SHILL 1 $PATH_TO_TESTS
done
