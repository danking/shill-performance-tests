#!/bin/bash

find . -type f -exec echo {} \; -exec awk -f compute-averages '{}' \;
