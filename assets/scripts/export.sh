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
    mkdir -p dict
    pushd dict
    for lang in en ro fr it es de; do
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
        zip "dictionar_poliglot_de_aeronautica-${lang}-dict.zip" "dictionar_poliglot_de_aeronautica-${lang}.dict.dz" "dictionar_poliglot_de_aeronautica-${lang}.index"
    done
    popd
}

do_mobi()
{
    mkdir -p mobi
    pushd mobi
    for lang in en ro fr it es de; do
        ${lang} th > "dictionar_poliglot_de_aeronautica-${lang}.tab"
        create_mobi "${lang}"
    done
    popd
}

do_stardict()
{
    make -C ../
    for lang in en ro fr it es de; do
        mkdir -p "stardict/dictionar_poliglot_de_aeronautica-${lang}"
    done

    pushd stardict/dictionar_poliglot_de_aeronautica-en
    ../../../stardict-sqlfile -d "../${db}" -l 'ek, ed, gk, sk, fk, ik, rk, rd'
    popd
    pushd stardict/dictionar_poliglot_de_aeronautica-de
    ../../../stardict-sqlfile -d "../${db}" -l 'gk, ek, ed, sk, fk, ik, rk, rd'
    popd
    pushd stardict/dictionar_poliglot_de_aeronautica-es
    ../../../stardict-sqlfile -d "../${db}" -l 'sk, gk, ek, ed, fk, ik, rk, rd'
    popd
    pushd stardict/dictionar_poliglot_de_aeronautica-fr
    ../../../stardict-sqlfile -d "../${db}" -l 'fk, gk, ek, ed, sk, ik, rk, rd'
    popd
    pushd stardict/dictionar_poliglot_de_aeronautica-it
    ../../../stardict-sqlfile -d "../${db}" -l 'ik, gk, ek, ed, sk, fk, rk, rd'
    popd
    pushd stardict/dictionar_poliglot_de_aeronautica-ro
    ../../../stardict-sqlfile -d "../${db}" -l 'rpk, rd, gk, ek, ed, sk, fk, ik'
    popd

    pushd stardict
    for lang in en ro fr it es de; do
        zip  "dictionar_poliglot_de_aeronautica-${lang}-stardict.zip" "dictionar_poliglot_de_aeronautica-${lang}"/*
    done
    popd
}

#do_dict
do_stardict
#do_mobi

