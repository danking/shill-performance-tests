#!/usr/local/bin/bash

sudo sysctl security.mac.shill.shill_debug=0

RUNS=$1

[ "$#" -eq 1 ] || die "Exactly one argument required, $# provided. Valid invocation:

  bash generate-global-policy.sh RESULTS_DIR

  - RUNS -- The number of runs of each full suite
"

RESULTS_FILE="shill-grant-results-sandboxed-$(date +%F-%T)"
touch ${RESULTS_FILE} || die "Could not create ${RESULTS_FILE}"
for i in $(seq 1 ${RUNS})
do
    TARGET_FILE=$(mktemp "$0.test.file.XXXXXX")

    ./shill-grant "${TARGET_FILE}" >> ${RESULTS_FILE}

    rm -rf "${TARGET_FILE}" || die "Could not remove ${TARGET_FILE}"
done

rm -rf "$0.test.file.*"

RESULTS_FILE="shill-grant-results-unsandboxed-$(date +%F-%T)"
touch ${RESULTS_FILE} || die "Could not create ${RESULTS_FILE}"
for i in $(seq 1 ${RUNS})
do
    TARGET_FILE=$(mktemp "$0.test.file.XXXXXX")

    ./shill-no-grant "${TARGET_FILE}" >> ${RESULTS_FILE}

    rm -rf "${TARGET_FILE}" || die "Could not remove ${TARGET_FILE}"
done

rm -rf "$0.test.file.*"
