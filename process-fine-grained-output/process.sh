#!/bin/bash

function die() { echo "process.sh: $@" 1>&2 ; exit 1; }

TARGET_DIR=$1

[ "$#" -eq 1 ] || die "1 argument required"

[ ! -e ${TARGET_DIR}/summary ] || die "Ensure that ${TARGET_DIR}/summary does not exist"
echo "vm_startup ambient pkg_native shill_sandbox \
exec c_sandbox total_real_time total_user_time \
total_sys_time" > ${TARGET_DIR}/summary

for file in ${TARGET_DIR}/info.*
do
    [[ "$file" =~ .*info\.(.*) ]] || die "$file is not of the form info.(.*)"
    i="${BASH_REMATCH[1]}"

    INFO_FILE=$file
    LOG_FILE=${TARGET_DIR}/log.$i

    [ -e "${LOG_FILE}" ] || die "Ensure that log.$i exists"

    grep "^Test $i\$" -A 1 ${TARGET_DIR}/times | tail -n 1 | awk '{ print "total-real-time:" , $1 * 1000 ; \
print "total-user-time:" , $3 * 1000 ; \
print "total-sys-time:" , $5 * 1000 }' | cat - $INFO_FILE $LOG_FILE | awk -f extract-stats.awk >> ${TARGET_DIR}/summary
done
