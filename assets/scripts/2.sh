#!/bin/bash

BAD=$'\e[31;01m'
HILITE=$'\e[36;01m'
NORMAL=$'\e[0m'

if [ $# -gt 0 ]; then
    files="$*"
fi

for i in ${files}; do
    true > "${i}.sql"
    cat "${i}" | while read -r line; do
        if echo "${line}" | grep -q '^[0-9]'; then
            if [[ -n "${id}" && -n "${ek}" && -n "${ed}" && -n "${rk}" && -n "${rd}" && -n "${fk}" && -n "${ik}" && -n "${sk}" && -n "${gk}" ]]; then
                echo "insert into defs values('${id}','${ek}','${ed}','${rk}','${rpk}','${rd}','${fk}','${ik}','${sk}','${gk}');" >> "${i}.sql"
                echo -n "+"
            else 
                if [ -z "${id}" ] && [ -z "${ek}" ] && [ -z "${ed}" ] && [ -z "${rk}" ] && [ -z "${rd}" ] && [ -z "${fk}" ] && [ -z "${ik}" ] && [ -z "${sk}" ] && [ -z "${gk}" ]; then
                    :
                    # ignore if all values are null
                else
                    echo -e "\n${BAD}*${NORMAL} ${HILITE}${i}${NORMAL} incomplete data ${BAD}'${id}'${NORMAL},'${ek}','${ed}','${rk}','${rpk}','${rd}','${fk}','${ik}','${sk}','${gk}''"
                fi
            fi
            id=$(echo "${line}"| sed 's|\([0-9]*\).*;|\1|')
            ek=''; ed=''; rk=''; rpk=''; fk=''; ik=''; sk=''; gk=''
        elif echo "${line}" | grep -q '^(E)'; then
            ek=$(echo "${line}"| perl -pe 's|\(E\)\s*||;s|(.*?);(.*)$|\1|' | sed 's|[ ]\+| |g' )
            ed=$(echo "${line}"| perl -pe 's|\(E\)\s*||;s|(.*?);\s*(.*);$|\2|' | sed 's|[ ]\+| |g' )
        elif echo "${line}" | grep -q '^(R)'; then
            rk=$(echo "${line}"| perl -pe 's|\(R\)\s*||;s|(.*?);(.*)$|\1|' | sed 's|[ ]\+| |g')
            if echo "${rk}" | grep -q '^a '; then
                rpk=$(echo "${rk}" | sed 's|^a ||')
                rpk="${rpk} (a)"
            else
                rpk="${rk}"
            fi
            rd=$(echo "${line}"| perl -pe 's|\(R\)\s*||;s|(.*?);\s*(.*);$|\2|' | sed 's|[ ]\+| |g')
        elif echo "${line}" | grep -q '^(F)'; then
            fk=$(echo "${line}"| sed 's|^[ ]*(F)[ ]*\(.*\);$|\1|' | sed 's|[ ]\+| |g')
        elif echo "${line}" | grep -q '^(I)'; then
            ik=$(echo "${line}"| sed 's|^[ ]*(I)[ ]*\(.*\);$|\1|' | sed 's|[ ]\+| |g')
        elif echo "${line}" | grep -q '^(S)'; then
            sk=$(echo "${line}"| sed 's|^[ ]*(S)[ ]*\(.*\);$|\1|' | sed 's|[ ]\+| |g')
        elif echo "${line}" | grep -q '^(G)'; then
            gk=$(echo "${line}"| sed 's|^[ ]*(G)[ ]*\(.*\);$|\1|' | sed 's|[ ]\+| |g')
        else
            if [ -n "${line}" ]; then
                echo -e "\n${BAD}*${NORMAL} ${HILITE}${line}${NORMAL} does not match any filter"
                echo "values were '${id}','${ek}','${ed}','${rk}','${rd}','${fk}','${ik}','${sk}','${gk}'"
            fi
        fi
    done

done

