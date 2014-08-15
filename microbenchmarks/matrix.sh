#!/usr/local/bin/bash

set -m

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
function spawn_local_children() {
    # set up $LOCAL_CAP_COUNT sessions each with one cap on
    # the target path
    for i in $(seq ${LOCAL_CAP_COUNT})
    do
        ${BACKGROUND_SANDBOX} ${LOCAL_POLICY_FILE} ./sleep
        ACTIVE_LOCAL_KIDS=("${ACTIVE_LOCAL_KIDS[@]}" "${LAUNCHED_PID}")
    done
    sleep ${PAUSE_BETWEEN_SESSION_ALLOC_SECONDS}
}
function kill_local_children() {
    # kill all local children
    for PID in "${ACTIVE_LOCAL_KIDS[@]}"
    do
        kill -9 ${PID} || die "Could not kill pid ${PID}, a local kid pid"
        wait ${PID} && die "Pid ${PID} appears to not have cleanly died"
    done
    ACTIVE_LOCAL_KIDS=()
}
function caps_for_test() {
    case "$1" in
        "./r")
            echo "+stat, +lookup, +read" ;;
        "./w")
            echo "+stat, +lookup, +write, +append" ;;
        "./owc")
            echo "+stat, +lookup, +write, +append" ;;
        "./orc")
            echo "+stat, +lookup, +read" ;;
        "./cwu")
            echo "+create-file { +stat, +write, +append, +unlink }, +stat, +lookup, +unlink-file " ;;
        "./mkdir")
            echo "+create-dir { +stat, +unlink }, +stat, +lookup, +unlink-dir, +unlink-file " ;;
    esac
}

# arguments

RESULTS_SUPER_DIR=$1
SANDBOXEDP=$2

[ "$#" -eq 2 ] || die "Exactly two arguments required, $# provided. Valid invocation:

  bash generate-global-policy.sh RESULTS_DIR

  - RESULTS_SUPER_DIR -- the directory in which to place results directory
  - SANDBOXEDP -- whether or not to use the shill sandbox
"
[ -d "${RESULTS_SUPER_DIR}" ] || die "The first argument should be an extant directory"
[ ${SANDBOXEDP} -eq 1 -o ${SANDBOXEDP} -eq 0 ] || die "The second argument should be 1 or 0"

RESULTS_DIR="${RESULTS_SUPER_DIR}/logs-$(date +%F-%T)"

mkdir "${RESULTS_DIR}" || die "Could not create ${RESULTS_DIR}"

# executable portion

SESSION_COUNTS=(1 10 100)
GLOBAL_CAP_COUNTS=(1 10 100)
LOCAL_CAP_COUNTS=(1 10 100)
DATA_SIZES=(1 10 100 1000)
TEST_PATHS_FOLDER=$(mktemp -d "$0.test.files.XXXXXX")
PATHS=("${TEST_PATHS_FOLDER}/foo" "${TEST_PATHS_FOLDER}/foo/bar" "${TEST_PATHS_FOLDER}/foo/bar/baz/qux/quux" "${TEST_PATHS_FOLDER}/foo/bar/baz/qux/quux/foo/bar/baz/qux/quux")
SIZE_AND_EXTANT_PATH_TESTS=(./r ./w ./owc ./orc)
SIZE_AND_NONEXTANT_PATH_TESTS=(./cwu)
JUST_NONEXTANT_PATH_TESTS=(./mkdir)

LAUNCHED_PID=0

background_run_sandbox() {
    "../../shill/sandbox/sandbox" $* >/dev/null &
    LAUNCHED_PID=$!
}

background_dont_run_sandbox() {
    shift # throw away the policy file
    COMMAND="$1"
    shift
    ${COMMAND} $* >/dev/null &
    LAUNCHED_PID=$!
}

foreground_run_sandbox() {
    "../../shill/sandbox/sandbox" $*
}

foreground_dont_run_sandbox() {
    shift # throw away the policy file
    COMMAND="$1"
    shift
    ${COMMAND} $* >/dev/null
}

case "${SANDBOXEDP}" in
    1) BACKGROUND_SANDBOX="background_run_sandbox"
       FOREGROUND_SANDBOX="foreground_run_sandbox" ;;
    0) BACKGROUND_SANDBOX="background_dont_run_sandbox"
       FOREGROUND_SANDBOX="foreground_dont_run_sandbox" ;;
esac

PAUSE_BETWEEN_SESSION_ALLOC_SECONDS="0.1"

ACTIVE_GLOBAL_KIDS=()
ACTIVE_LOCAL_KIDS=()

DELETE_TEMPORARY_POLICY_FILESP=1 # 1 is true; 0 is false

POLICY_TO_RUN_SLEEP=$(cat <<EOF
{ +lookup }
/
.

{ +lookup, +read, +stat, +exec }
./sleep

{ +lookup, +stat }
/etc
/usr

{ +read, +stat }
/etc/libmap.conf

{ +read }
/var/run/ld-elf.so.hints

{ +read, +exec }
/libexec/ld-elf.so.1

{ +read, +exec, +stat }
/lib/libc.so.7
/lib/libedit.so.7
/lib/libncurses.so.8

{ +write, +append, +stat }
&stdout
&stderr
EOF
)

POLICY_TO_RUN_TEST=$(cat <<EOF
{ +lookup }
/
.

{ +lookup, +read, +stat, +exec }
./w
./r
./owc
./orc
./cwu
./mkdir

{ +lookup, +stat }
/etc
/usr

{ +read, +stat }
/etc/libmap.conf

{ +read }
/var/run/ld-elf.so.hints

{ +read, +exec }
/libexec/ld-elf.so.1

{ +read, +exec, +stat }
/lib/libc.so.7
/lib/libedit.so.7
/lib/libncurses.so.8

{ +write, +append, +stat }
&stdout
&stderr
EOF
)

create_test_results_dirs ${SIZE_AND_EXTANT_PATH_TESTS[@]} \
                         ${SIZE_AND_NONEXTANT_PATH_TESTS[@]} \
                         ${JUST_NONEXTANT_PATH_TESTS[@]}

for SESSION_COUNT in ${SESSION_COUNTS[@]}
do
    for GLOBAL_CAP_COUNT in ${GLOBAL_CAP_COUNTS[@]}
    do
        GLOBAL_POLICY_FILE=$(mktemp "$0.global.policy.XXXXXX")
        export SHUF="bash shuffle.sh" # for generate-global-policy.sh
        bash generate-global-policy.sh ${GLOBAL_CAP_COUNT} > ${GLOBAL_POLICY_FILE}
        echo -e "${POLICY_TO_RUN_SLEEP}" >> ${GLOBAL_POLICY_FILE}

        # set up $SESSION_COUNT sessions each with $GLOBAL_CAP_COUNT caps on
        # random files in /usr, they'll be killed below
        for i in $(seq 1 ${SESSION_COUNT})
        do
            ${BACKGROUND_SANDBOX} ${GLOBAL_POLICY_FILE} ./sleep
            ACTIVE_GLOBAL_KIDS=("${ACTIVE_GLOBAL_KIDS[@]}" "${LAUNCHED_PID}")
        done

        for TARGET_PATH in ${PATHS[@]}
        do
            mkdir -p $(dirname "${TARGET_PATH}")

            SLASHES=$(echo ${TARGET_PATH} | sed 's:[^/]::g')
            PATH_LENGTH=${#SLASHES}

            for LOCAL_CAP_COUNT in ${LOCAL_CAP_COUNTS[@]}
            do
                for DATA_SIZE in ${DATA_SIZES[@]}
                do
                    for TEST in ${SIZE_AND_EXTANT_PATH_TESTS[@]}
                    do
                        setup_output_file
                        echo_current_test

                        rm -rf "${TARGET_PATH}" || die "Could not remove ${TARGET_PATH}"
                        touch "${TARGET_PATH}" || die "Could not create ${TARGET_PATH}"
                        dd if=/dev/zero of="${TARGET_PATH}" bs=${DATA_SIZE} count=1 2>/dev/null || die "Could not copy ${DATA_SIZE} bits into ${OUTPUT}"

                        # Set up a policy file which well use to hang
                        # capabilities off of the target path
                        LOCAL_POLICY_FILE=$(mktemp "$0.local.policy.XXXXXX")
                        echo -e "{ +stat, +lookup }\n${TARGET_PATH}" > ${LOCAL_POLICY_FILE}
                        echo -e "${POLICY_TO_RUN_SLEEP}" >> ${LOCAL_POLICY_FILE}

                        TEST_POLICY_FILE=$(mktemp "$0.test.policy.XXXXXX")
                        echo -e "{ $(caps_for_test $TEST) }\n${TARGET_PATH}" > ${TEST_POLICY_FILE}
                        echo -e "${POLICY_TO_RUN_TEST}" >> ${TEST_POLICY_FILE}

                        spawn_local_children

                        ${FOREGROUND_SANDBOX} ${TEST_POLICY_FILE} ${TEST} "${DATA_SIZE}" "${TARGET_PATH}" >> ${OUTPUT} || die "Test ${TEST} failed!"

                        kill_local_children
                        [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${LOCAL_POLICY_FILE}"
                        [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${TEST_POLICY_FILE}"
                    done

                    for TEST in ${SIZE_AND_NONEXTANT_PATH_TESTS[@]}
                    do
                        setup_output_file
                        echo_current_test

                        rm -rf "${TARGET_PATH}"

                        # Set up a policy file which well use to hang capabilities
                        # off of the target paths parent directory
                        LOCAL_POLICY_FILE=$(mktemp "$0.local.policy.XXXXXX")
                        echo -e "{ +stat, +lookup }\n$(dirname ${TARGET_PATH})" > ${LOCAL_POLICY_FILE}
                        echo -e "${POLICY_TO_RUN_SLEEP}" >> ${LOCAL_POLICY_FILE}

                        TEST_POLICY_FILE=$(mktemp "$0.test.policy.XXXXXX")
                        echo -e "{ $(caps_for_test $TEST) }\n$(dirname ${TARGET_PATH})" > ${TEST_POLICY_FILE}
                        echo -e "${POLICY_TO_RUN_TEST}" >> ${TEST_POLICY_FILE}

                        spawn_local_children

                        ${FOREGROUND_SANDBOX} ${TEST_POLICY_FILE} ${TEST} "${DATA_SIZE}" "${TARGET_PATH}" >> ${OUTPUT} || die "Test ${TEST} failed!"

                        kill_local_children
                        [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${LOCAL_POLICY_FILE}"
                        [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${TEST_POLICY_FILE}"
                    done
                done

                DATA_SIZE=0

                for TEST in ${JUST_NONEXTANT_PATH_TESTS[@]}
                do
                    setup_output_file
                    echo_current_test

                    [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${TARGET_PATH}"

                    # Set up a policy file which well use to hang capabilities
                    # off of the target paths parent directory
                    LOCAL_POLICY_FILE=$(mktemp "$0.local.policy.XXXXXX")
                    echo -e "{ +stat, +lookup }\n$(dirname ${TARGET_PATH})" > ${LOCAL_POLICY_FILE}
                    echo -e "${POLICY_TO_RUN_SLEEP}" >> ${LOCAL_POLICY_FILE}

                    TEST_POLICY_FILE=$(mktemp "$0.test.policy.XXXXXX")
                    echo -e "{ $(caps_for_test $TEST) }\n$(dirname ${TARGET_PATH})" > ${TEST_POLICY_FILE}
                    echo -e "${POLICY_TO_RUN_TEST}" >> ${TEST_POLICY_FILE}

                    spawn_local_children

                    ${FOREGROUND_SANDBOX} ${TEST_POLICY_FILE} ${TEST} "${TARGET_PATH}" >> ${OUTPUT} || die "Test ${TEST} failed!"

                    kill_local_children
                    [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${LOCAL_POLICY_FILE}"
                    [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${TEST_POLICY_FILE}"
                done
                # ensure target path and local policy file are deleted
                rm -rf "${TARGET_PATH}"
                # kill all global children
                for PID in "${ACTIVE_GLOBAL_KIDS[@]}"
                do
                    kill -9 ${PID}
                    wait ${PID}
                done
                ACTIVE_GLOBAL_KIDS=()
            done
        done
        [ "${DELETE_TEMPORARY_POLICY_FILESP}" -eq 1 ] && rm -rf "${GLOBAL_POLICY_FILE}"
    done
done

rm -rf "${TEST_PATHS_FOLDER}"
