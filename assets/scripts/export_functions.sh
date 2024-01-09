#!/bin/bash

asset_dir='../../../assets'
db="${asset_dir}/db/dpa.db"

create_mobi()
{
    lang="${1}"

    cp "${asset_dir}/cover-${lang}.png" ./
    "${asset_dir}/scripts/tab2opf.py" "dictionar_poliglot_de_aeronautica-${lang}.tab"
    grep -B1000 '<metadata>' "dictionar_poliglot_de_aeronautica-${lang}.opf" > "_dictionar_poliglot_de_aeronautica-${lang}.opf"
    cat "${asset_dir}/dictionar_poliglot_de_aeronautica-${lang}_metadata.opf" >> "_dictionar_poliglot_de_aeronautica-${lang}.opf"
    grep -A1000 '</metadata>' "dictionar_poliglot_de_aeronautica-${lang}.opf" >> "_dictionar_poliglot_de_aeronautica-${lang}.opf"
    mv -f "_dictionar_poliglot_de_aeronautica-${lang}.opf" "dictionar_poliglot_de_aeronautica-${lang}.opf"
    wine /opt/bin/mobigen.exe "dictionar_poliglot_de_aeronautica-${lang}.opf"
}

en()
{
    lang='en'
    format="${1}"
    sqlite3 "${db}" 'select gk, ek, ed, sk, fk, ik, rk, rd from defs order by ek collate nocase ASC;' | while IFS='|' read -r gk ek ed sk fk ik rk rd; do
            if [ "${format}" == "dict" ]; then
                echo -e "%h ${ek}\n${ed}\n(de) ${gk}\n(es) ${sk}\n(fr) ${fk}\n(it) ${ik}\n(ro) ${rk}; ${rd}\n"
            elif [ "${format}" == "th" ]; then
                echo -e "${ek}\t${ed}<br><i>(de)</i>: ${gk}<br><i>(es)</i>: ${sk}<br><i>(fr)</i>: ${fk}<br><i>(it)</i>: ${ik}<br><i>(ro)</i>: ${rk}; ${rd}"
            fi
        done
}

ro()
{
    lang='ro'
    format="${1}"
    sqlite3 "${db}" 'select gk, ek, ed, sk, fk, ik, rpk, rd from defs order by rpk collate nocase ASC;' | while IFS='|' read -r gk ek ed sk fk ik rpk rd; do
            if [ "${format}" == "dict" ]; then
                echo -e "%h ${rpk}\n${rd}\n(de) ${gk}\n(en) ${ek}; ${ed}\n(es) ${sk}\n(fr) ${fk}\n(it) ${ik}"
            elif [ "${format}" == "th" ]; then
                echo -e "${rpk}\t${rd}<br><i>(de)</i>: ${gk}<br><i>(en)</i>: ${ek}; ${ed}<br><i>(es)</i>: ${sk}<br><i>(fr)</i>: ${fk}<br><i>(it)</i>: ${ik}"
            fi
        done
}


fr()
{
    lang='fr'
    format="${1}"
    sqlite3 "${db}" 'select gk, ek, ed, sk, fk, ik, rk, rd from defs order by fk collate nocase ASC;' | while IFS='|' read -r gk ek ed sk fk ik rk rd; do
            if [ "${format}" == "dict" ]; then
                echo -e "%h ${fk}\n(de) ${gk}\n(en) ${ek}; ${ed}\n(es) ${sk}\n(it) ${ik}\n(ro) ${rk}; ${rd}"
            elif [ "${format}" == "th" ]; then
                echo -e "${fk}\t<i>(de)</i>: ${gk}<br><i>(en)</i>: ${ek}; ${ed}<br><i>(es)</i>: ${sk}<br><i>(it)</i>: ${ik}<br><i>(ro)</i>: ${rk}; ${rd}"
            fi
        done
}

it()
{
    lang='it'
    format="${1}"
    sqlite3 "${db}" 'select gk, ek, ed, sk, fk, ik, rk, rd from defs order by ik collate nocase ASC;' | while IFS='|' read -r gk ek ed sk fk ik rk rd; do
            if [ "${format}" == "dict" ]; then
                echo -e "%h ${ik}\n(de) ${gk}\n(en) ${ek}; ${ed}\n(es) ${sk}\n(fr) ${fk}\n(ro) ${rk}; ${rd}"
            elif [ "${format}" == "th" ]; then
                echo -e "${ik}\t<i>(de)</i>: ${gk}<br><i>(en)</i>: ${ek}; ${ed}<br><i>(es)</i>: ${sk}<br><i>(fr)</i>: ${fk}<br><i>(ro)</i>: ${rk}; ${rd}"
            fi
        done
}

es()
{
    lang='es'
    format="${1}"
    sqlite3 "${db}" 'select gk, ek, ed, sk, fk, ik, rk, rd from defs order by sk collate nocase ASC;' | while IFS='|' read -r gk ek ed sk fk ik rk rd; do
            if [ "${format}" == "dict" ]; then
                echo -e "%h ${sk}\n(de) ${gk}\n(en) ${ek}; ${ed}\n(fr) ${fk}\n(it) ${ik}\n(ro) ${rk}; ${rd}"
            elif [ "${format}" == "th" ]; then
                echo -e "${sk}\t<i>(de)</i>: ${gk}<br><i>(en)</i>: ${ek}; ${ed}<br><i>(fr)</i>: ${fk}<br><i>(it)</i>: ${ik}<br><i>(ro)</i>: ${rk}; ${rd}"
            fi
        done
}

de()
{
    lang='de'
    format="${1}"
    sqlite3 "${db}" 'select gk, ek, ed, sk, fk, ik, rk, rd from defs order by gk collate nocase ASC;' | while IFS='|' read -r gk ek ed sk fk ik rk rd; do
            if [ "${format}" == "dict" ]; then
                echo -e "%h ${gk}\n(en) ${ek}; ${ed}\n(es) ${sk}\n(fr) ${fk}\n(it) ${ik}\n(ro) ${rk}; ${rd}"
            elif [ "${format}" == "th" ]; then
                echo -e "${gk}\t<i>(en)</i>: ${ek}; ${ed}<br><i>(es)</i>: ${sk}<br><i>(fr)</i>: ${fk}<br><i>(it)</i>: ${ik}<br><i>(ro)</i>: ${rk}; ${rd}"
            fi
        done
}

do_dict()
{
    opt_lang="$@"
    lang="en ro fr it es de"
    [ -n "${opt_lang}" ] && lang="${opt_lang}"

    mkdir -p dict
    pushd dict
    for lang in ${lang}; do
        cat << EOF > "dictionar_poliglot_de_aeronautica-${lang}.txt"
%h about
  Dicționar poliglot de aeronautică (${lang})

               Autori
           Cornel Oprișiu
              Dan Pantazopol
         Gheorghe Rodan
        Dan-Mihai Ștefănescu

           Tehnoredactori
         Marilena Ghemuleț
             Anca Rodan
            Petre Rodan

           Programator
            Mihai Radu
EOF
        ${lang} dict >> "dictionar_poliglot_de_aeronautica-${lang}.txt"
        < "dictionar_poliglot_de_aeronautica-${lang}.txt" dictfmt -s "Dicționar poliglot de aeronautică (${lang})" --utf8 -p "dictionar_poliglot_de_aeronautica-${lang}"
        dictzip "dictionar_poliglot_de_aeronautica-${lang}.dict"
        [ -z "${DO_NOT_ZIP}" ] && zip "dictionar_poliglot_de_aeronautica-${lang}-dict.zip" "dictionar_poliglot_de_aeronautica-${lang}.dict.dz" "dictionar_poliglot_de_aeronautica-${lang}.index"
    done
    popd
    return 0
}

do_mobi()
{
    opt_lang="$@"
    lang="en ro fr it es de"
    [ -n "${opt_lang}" ] && lang="${opt_lang}"

    mkdir -p mobi
    pushd mobi
    for lang in ${lang}; do
        ${lang} th > "dictionar_poliglot_de_aeronautica-${lang}.tab"
        create_mobi "${lang}"
    done
    popd
    return 0
}

do_stardict()
{
    opt_lang="$@"
    lang="en ro fr it es de"
    [ -n "${opt_lang}" ] && lang="${opt_lang}"

    for lang in ${lang}; do
        mkdir -p "stardict/dictionar_poliglot_de_aeronautica-${lang}"

        echo "${lang}" | grep -q 'en' && {
            pushd stardict/dictionar_poliglot_de_aeronautica-en
            ../../../stardict-sqlfile -d "../${db}" -l 'ek, ed, gk, sk, fk, ik, rk, rd'
            popd
            [ -z "${DO_NOT_ZIP}" ] && zip  "dictionar_poliglot_de_aeronautica-en-stardict.zip" "dictionar_poliglot_de_aeronautica-en"/*
        }
        echo "${lang}" | grep -q 'de' && {
            pushd stardict/dictionar_poliglot_de_aeronautica-de
            ../../../stardict-sqlfile -d "../${db}" -l 'gk, ek, ed, sk, fk, ik, rk, rd'
            popd
            [ -z "${DO_NOT_ZIP}" ] && zip  "dictionar_poliglot_de_aeronautica-de-stardict.zip" "dictionar_poliglot_de_aeronautica-de"/*
        }
        echo "${lang}" | grep -q 'es' && {
            pushd stardict/dictionar_poliglot_de_aeronautica-es
            ../../../stardict-sqlfile -d "../${db}" -l 'sk, gk, ek, ed, fk, ik, rk, rd'
            popd
            [ -z "${DO_NOT_ZIP}" ] && zip  "dictionar_poliglot_de_aeronautica-es-stardict.zip" "dictionar_poliglot_de_aeronautica-es"/*
        }
        echo "${lang}" | grep -q 'fr' && {
            pushd stardict/dictionar_poliglot_de_aeronautica-fr
            ../../../stardict-sqlfile -d "../${db}" -l 'fk, gk, ek, ed, sk, ik, rk, rd'
            popd
            [ -z "${DO_NOT_ZIP}" ] && zip  "dictionar_poliglot_de_aeronautica-fr-stardict.zip" "dictionar_poliglot_de_aeronautica-fr"/*
        }
        echo "${lang}" | grep -q 'it' && {
            pushd stardict/dictionar_poliglot_de_aeronautica-it
            ../../../stardict-sqlfile -d "../${db}" -l 'ik, gk, ek, ed, sk, fk, rk, rd'
            popd
            [ -z "${DO_NOT_ZIP}" ] && zip  "dictionar_poliglot_de_aeronautica-it-stardict.zip" "dictionar_poliglot_de_aeronautica-it"/*
        }
        echo "${lang}" | grep -q 'ro' && {
            pushd stardict/dictionar_poliglot_de_aeronautica-ro
            ../../../stardict-sqlfile -d "../${db}" -l 'rpk, rd, gk, ek, ed, sk, fk, ik'
            popd
            [ -z "${DO_NOT_ZIP}" ] && zip  "dictionar_poliglot_de_aeronautica-ro-stardict.zip" "dictionar_poliglot_de_aeronautica-ro"/*
        }
    done

    return 0
}

