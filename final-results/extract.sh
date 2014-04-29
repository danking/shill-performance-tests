#!/bin/bash

find . -name "times" -print -exec grep Test -A 1 {} \; | egrep "times|real" | sed 's/\.\/\(.*\)\/.*\/.*/\1/g' |
gawk 'BEGIN { FIELDWIDTHS = "6 6 40" } {
      if ($1 != "      ") { printf("\n%s", $0); }
      else { printf(",%s",$2); }
    }' 
