#!/usr/local/bin/bash

find /usr/src -name "*.c" -print0 | xargs -0 grep -H "mac_" --
