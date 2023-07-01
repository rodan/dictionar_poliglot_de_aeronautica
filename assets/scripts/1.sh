#!/bin/bash

if [ $# -gt 0 ]; then
    files="$*"
fi

for i in ${files}; do
    f=$(basename "${i}")
    sed 's|\[|ă|g;s|\\|ț|g;s|\]|î|g;s|`|â|g;s|=|ș|g' "${i}" | sed "s|'|''|g"
done
    
echo 0

