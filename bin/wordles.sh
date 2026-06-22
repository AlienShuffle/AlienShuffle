#!/bin/bash
#
# example extended regexp patterns for optional parameter
#
# 3rd letter is not a or b - '^[a-z]{2}[^ab][a-z]{2}$'
# 1st letter is a or b - '^[ab][a-z]{4}$'
# 1st letter is a or b and 3rd letter is not a or b - '^[ab][a-z][^ab][a-z]{2}$'
default_pattern='^[a-z]{5}$'
pattern="${1:-$default_pattern}"
# Quote the pattern to prevent bash glob expansion when supplied as $1
grep -E -- "$pattern" /usr/share/dict/words