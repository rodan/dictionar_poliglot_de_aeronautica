#!/bin/bash

rm -f dpa.* s.txt s.txt.sql

bash ../scripts/1.sh source.txt > s.txt
bash ../scripts/2.sh s.txt
bash ../scripts/3.sh

rm 0.sql s.txt s.txt.sql dpa.sql

