#!/usr/local/bin/bash

SCRIPTS+=(find-script.sh grading-bash.sh emacs-bash.sh)
SCRIPTS+=(emacs-bash.sh)
SCRIPTS+=(curl-bash.sh untar-bash.sh configure-bash.sh make-bash.sh install-bash.sh uninstall-bash.sh)
SCRIPTS+=(find-script.sh find-sandbox-script.sh find-exec-shill-no-spawn.sh)
SCRIPTS+=(grading-sandbox.sh grading-bash.sh grading-shill.sh)
SCRIPTS+=(emacs-sandbox.sh emacs-shill.sh)
SCRIPTS+=(curl-sandbox.sh untar-sandbox.sh configure-sandbox.sh make-sandbox.sh install-sandbox.sh uninstall-sandbox.sh)

echo "Starting evaluation for:"
echo "${SCRIPTS[*]}"

PATH_TO_LINUX=/usr/src
PATH_TO_TEST_LOGS=~/tests/results
PATH_TO_SHILL=~/shill
PATH_TO_TESTS=~/tests

echo ">> I'm going to call sudo now, be ready with your password!"
sudo sysctl security.mac.shill.shill_debug=0

for s in ${SCRIPTS[*]}
do
    echo ">> Executing $s"
    bash $s $PATH_TO_LINUX $PATH_TO_TEST_LOGS $PATH_TO_SHILL 10 $PATH_TO_TESTS
done

sudo sysctl security.mac.shill.shill_debug=1
