#!/bin/csh

[ -f database.sqlite3 ] && echo 'database already exists! remove it first' && exit 255

cat schema.sql testdata.sql dump.sql | sqlite3 database.sqlite3
