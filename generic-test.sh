#!/usr/local/bin/bash

function die() { echo "generic-test.sh: $@" 1>&2 ; exit 1; }

# arguments

TEST_NAME=$1
COMMAND=$2
ARGS=$3
RUNS=$4
PATH_TO_TEST_LOGS=$5
PATH_TO_SHILL=$6

[ "$#" -eq 6 ] || die "5 arguments required, $# provided. Valid invocation:

  bash generic-test.sh name command runs test_log_path shill_path

  - name -- the name of this test, should be a valid directory name
  - command -- the command to run the test, usually needs to be quoted
  - runs -- the number of times to run the test
  - test_path -- the path to the directory in which to place results (no trailing slash)
"

[ -d "${PATH_TO_TEST_LOGS}" ] || die "The fourth argument should be a directory, was ${PATH_TO_TEST_LOGS}"

[ -d "${PATH_TO_SHILL}" ] || die "The fifth argument should be a directory, was ${PATH_TO_SHILL}"

# executable portion

LOG_DIR=$(date "+logs--%Y-%m-%d--%H:%M:%S")
LOG_PATH="${PATH_TO_TEST_LOGS}/${TEST_NAME}/${LOG_DIR}"
mkdir -p ${LOG_PATH}

if [ $? -ne 0 ]
then
    echo "Could not create ${LOG_PATH}, failing."
    exit 1
fi

for i in `seq 1 ${RUNS}`
do
    echo $(git log | head -n 1) > ${LOG_PATH}/git-commit
    echo "Test $i"
    echo "Test $i" >> ${LOG_PATH}/times
    /usr/bin/time -al -o ${LOG_PATH}/times \
        $COMMAND ${ARGS[*]} > ${LOG_PATH}/log.$i
done
