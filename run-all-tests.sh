#!/usr/local/bin/bash

#SCRIPTS+=(find-exec-sandbox.sh find-no-sandbox.sh grading-bash.sh emacs-bash.sh)
#SCRIPTS+=(curl-bash.sh untar-bash.sh configure-bash.sh make-bash.sh install-bash.sh uninstall-bash.sh)
#SCRIPTS+=(find-exec-shill-no-spawn.sh find-exec-shill-yes-spawn.sh)
#SCRIPTS+=(find-exec-shill-yes-spawn-compiled.sh)
SCRIPTS+=(grading-sandbox.sh grading-shill.sh)
SCRIPTS+=(find-exec-sandbox.sh find-exec-shill-yes-spawn.sh)
#SCRIPTS+=(emacs-sandbox.sh emacs-shill.sh)
#SCRIPTS+=(curl-sandbox.sh untar-sandbox.sh configure-sandbox.sh make-sandbox.sh install-sandbox.sh uninstall-sandbox.sh)
#SCRIPTS=(untar-bash.sh untar-sandbox.sh)
#SCRIPTS+=(configure-none.sh emacs-none.sh)
#SCRIPTS+=(grading-none.sh make-none.sh untar-none.sh curl-none.sh)
#SCRIPTS+=(find-none.sh install-none.sh uninstall-none.sh)
#SCRIPTS+=(apache-none.sh)
#SCRIPTS+=(apache-native.sh apache-sandbox.sh)
#SCRIPTS+=(find-exec-xargs-none.sh)
#SCRIPTS+=(find-exec-xargs-native.sh find-exec-xargs-sandbox.sh find-exec-xargs-shill.sh)

echo "Starting evaluation for:"
echo "${SCRIPTS[*]}"

PATH_TO_LINUX=/usr/src
PATH_TO_TEST_LOGS=/home/sdmoore/tests/results
PATH_TO_SHILL=/home/sdmoore/shill
PATH_TO_TESTS=/home/tests

echo ">> I'm going to call sudo now, be ready with your password!"
sudo sysctl security.mac.shill.shill_debug=0

for s in ${SCRIPTS[*]}
do
    echo ">> Executing $s"
    bash $s $PATH_TO_LINUX $PATH_TO_TEST_LOGS $PATH_TO_SHILL 50 $PATH_TO_TESTS
done

sudo sysctl security.mac.shill.shill_debug=1
