#!/usr/local/bin/bash

function die() { echo "$(basename ${0}): $@" 1>&2 ; exit 1; }

sudo sysctl security.mac.shill.shill_debug=0

RUNS=$1
EXE=$2

[ "$#" -eq 2 ] || die "Exactly two arguments required, $# provided. Valid invocation:

  bash generate-global-policy.sh RUNS EXE

  - RUNS -- The number of runs of each full suite
  - EXE -- which executable to run
"

RESULTS_DIR=results
mkdir -p ${RESULTS_DIR}

RESULTS_FILE="${RESULTS_DIR}/${EXE}-results-$(date +%F-%T)"
touch ${RESULTS_FILE} || die "Could not create ${RESULTS_FILE}"
for i in $(seq 1 ${RUNS})
do
    TARGET_FILE=$(mktemp "$0.test.dir.XXXXXX")

    "${EXE}" "${TARGET_FILE}" >> ${RESULTS_FILE}

    rm -rf "${TARGET_FILE}" || die "Could not remove ${TARGET_FILE}"
done

rm -rf "$0.test.dir.*"
