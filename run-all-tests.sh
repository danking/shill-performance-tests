#!/usr/local/bin/bash

SCRIPTS=(find-sandbox-script.sh \
         find-script.sh find-shill-script.sh find-shill-spawn-script.sh \
         grep-recursive-script.sh)

PATH_TO_LINUX=/usr/src
PATH_TO_TEST_LOGS=~/tests/results
PATH_TO_SHILL=~/shill
PATH_TO_TESTS=~/tests

echo ">> I'm going to call sudo now, be ready with your password!"
sudo sysctl security.mac.shill.shill_debug=0

echo ">> NB: I'm not running find-no-kmod-script.sh!"
echo

for s in ${SCRIPTS[*]}
do
    echo ">> Executing $s"
    bash $s $PATH_TO_LINUX $PATH_TO_TEST_LOGS $PATH_TO_SHILL 1 $PATH_TO_TESTS
done

sudo sysctl security.mac.shill.shill_debug=1
