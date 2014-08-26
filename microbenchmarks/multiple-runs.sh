#!/usr/local/bin/bash

sudo sysctl security.mac.shill.shill_debug=0

RUNS=$1

[ "$#" -eq 1 ] || die "Exactly one argument required, $# provided. Valid invocation:

  bash generate-global-policy.sh RESULTS_DIR

  - RUNS -- The number of runs of each full suite
"

RESULTS_FOLDER="results-sandboxed-$(date +%F-%T)"
mkdir ${RESULTS_FOLDER}
for i in $(seq 1 ${RUNS})
do
    bash matrix.sh $RESULTS_FOLDER 1 1>&2 2>status-log-sandboxed-$(date +%F-%T)
done

RESULTS_FOLDER="results-unsandboxed-$(date +%F-%T)"
mkdir ${RESULTS_FOLDER}
for i in $(seq 1 ${RUNS})
do
    bash matrix.sh $RESULTS_FOLDER 0 1>&2 2>status-log-unsandboxed-$(date +%F-%T)
done
