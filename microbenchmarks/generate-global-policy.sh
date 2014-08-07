#!/usr/local/bin/bash

function die() { echo "$(basename ${0}): $@" 1>&2 ; exit 1; }

# arguments

N=$1

[ "$#" -eq 1 ] || die "Exactly 1 argument required, $# provided. Valid invocation:

  bash generate-global-policy.sh N

  - N -- the number of random files to place capabilities on
"

[ -n "$SHUF" ] || die "Ensure the variable SHUF is set to the gshuf/shuf executable"

# executable portion

FILES=`find /usr -type f | head -n $(expr $N '*' 10) | ${SHUF} | head -n $N`
ALL_CAPS="+exec
+stat
+lookup
+read
+stat
+write
+append"

POLICY=""
for FILE in ${FILES}
do
    CAP=$(echo "${ALL_CAPS}" | ${SHUF} | head -n 1)
    POLICY+="{ $CAP }\n"
    POLICY+=${FILE}"\n\n"
done

echo -e ${POLICY}
