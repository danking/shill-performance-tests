#!/usr/local/bin/bash

function die() { echo "$(basename ${0}): $@" 1>&2 ; exit 1; }
function create_test_results_dirs() {
    for TEST in "$@"
    do
        TEST_RESULTS_DIR=${RESULTS_DIR}/${TEST}
        mkdir ${TEST_RESULTS_DIR} || die "Could not create results dir for test ${TEST}"
    done
}
function set_test_results_dir() {
    TEST_RESULTS_DIR=${RESULTS_DIR}/${TEST}
}
function echo_current_test() {
    echo "Running ${TEST}  ${SESSION_COUNT}-${GLOBAL_CAP_COUNT}-${LOCAL_CAP_COUNT}-${PATH_LENGTH}-${DATA_SIZE}"
}
function setup_output_file() {
    set_test_results_dir
    OUTPUT=${TEST_RESULTS_DIR}/data-${SESSION_COUNT}-${GLOBAL_CAP_COUNT}-${LOCAL_CAP_COUNT}-${PATH_LENGTH}-${DATA_SIZE}
    touch ${OUTPUT} || die "Could not create results file ${OUTPUT}"
}

# arguments

RESULTS_SUPER_DIR=$1

[ "$#" -eq 1 ] || die "Exactly 1 argument required, $# provided. Valid invocation:

  bash generate-global-policy.sh RESULTS_DIR

  - RESULTS_SUPER_DIR -- the directory in which to place results directory
"
[ -d "${RESULTS_SUPER_DIR}" ] || die "The first argument should be an extant directory"

RESULTS_DIR="${RESULTS_SUPER_DIR}/logs-$(date +%F-%T)"

mkdir "${RESULTS_DIR}" || die "Could not create ${RESULTS_DIR}"

# executable portion

SESSION_COUNTS=(1 10 100 1000)
GLOBAL_CAP_COUNTS=(1 10 100 1000)
LOCAL_CAP_COUNTS=(1 10 100 1000)
DATA_SIZES=(1 10 100 1000)
PATHS=('foo' 'foo/bar' 'foo/bar/baz/qux/quux' 'foo/bar/baz/qux/quux/foo/bar/baz/qux/quux')
SIZE_AND_EXTANT_PATH_TESTS=(./r ./w ./owc)
SIZE_AND_NONEXTANT_PATH_TESTS=(./cwu)
JUST_EXTANT_PATH_TESTS=(./orc)
JUST_NONEXTANT_PATH_TESTS=(./mkdir)

REPETITIONS=$(seq 1 100)

echo ${SESSION_COUNTS[@]}

create_test_results_dirs ${SIZE_AND_EXTANT_PATH_TESTS[@]} \
                         ${SIZE_AND_NONEXTANT_PATH_TESTS[@]} \
                         ${JUST_EXTANT_PATH_TESTS[@]} \
                         ${JUST_NONEXTANT_PATH_TESTS[@]}

for SESSION_COUNT in ${SESSION_COUNTS[@]}
do
    echo ${SESSION_COUNT}
    for GLOBAL_CAP_COUNT in ${GLOBAL_CAP_COUNTS[@]}
    do
        for LOCAL_CAP_COUNT in ${LOCAL_CAP_COUNTS[@]}
        do
            for TARGET_PATH in ${PATHS[@]}
            do
                mkdir -p $(dirname "${TARGET_PATH}")

                SLASHES=$(echo ${TARGET_PATH} | sed 's:[^/]::g')"/"
                PATH_LENGTH=${#SLASHES}

                for DATA_SIZE in ${DATA_SIZES[@]}
                do
                    for TEST in ${SIZE_AND_EXTANT_PATH_TESTS[@]}
                    do
                        setup_output_file
                        echo_current_test
                        for i in ${REPETITIONS[@]}
                        do
                            rm -rf "${TARGET_PATH}"
                            touch "${TARGET_PATH}"
                            ${TEST} "${DATA_SIZE}" "${TARGET_PATH}" >> ${OUTPUT}
                            echo " " >> ${OUTPUT}
                        done
                    done

                    for TEST in ${SIZE_AND_NONEXTANT_PATH_TESTS[@]}
                    do
                        setup_output_file
                        echo_current_test
                        for i in ${REPETITIONS[@]}
                        do
                            rm -rf "${TARGET_PATH}"
                            ${TEST} "${DATA_SIZE}" "${TARGET_PATH}" >> ${OUTPUT}
                            echo " " >> ${OUTPUT}
                        done
                    done
                done

                for TEST in ${JUST_EXTANT_PATH_TESTS[@]}
                do
                    setup_output_file
                    echo_current_test
                    for i in ${REPETITIONS[@]}
                    do
                        rm -rf "${TARGET_PATH}"
                        touch "${TARGET_PATH}"
                        ${TEST} "${TARGET_PATH}" >> ${OUTPUT}
                        echo " " >> ${OUTPUT}
                    done
                done

                for TEST in ${JUST_NONEXTANT_PATH_TESTS[@]}
                do
                    setup_output_file
                    echo_current_test
                    for i in ${REPETITIONS[@]}
                    do
                        rm -rf "${TARGET_PATH}"
                        ${TEST} "${TARGET_PATH}" >> ${OUTPUT}
                        echo " " >> ${OUTPUT}
                    done
                done
                rm -rf "${TARGET_PATH}"
            done
        done
    done
done
