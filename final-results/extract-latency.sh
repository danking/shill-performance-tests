#!/bin/bash

find . -name "apache-*" -print -exec grep -Rhe "Time per request.*(mean)" {} \; |
sed 's/\.\///g' |
gawk '{ if ($1 != "Time") { printf("\n%s", $0); }
        else { printf(",%s", $4); } }'

