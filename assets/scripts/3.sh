#!/bin/bash
rm -f dpa.db dpa.sql

echo 'PRAGMA encoding = "UTF-8";' > 0.sql
echo "create table defs(id INTEGER, ek TEXT, ed TEXT, rk TEXT, rpk TEXT, rd TEXT, fk TEXT, ik TEXT, sk TEXT, gk TEXT);" >> 0.sql

for i in *.sql; do 
    cat "${i}" >> dpa.sql
done

sqlite3 dpa.db < dpa.sql
