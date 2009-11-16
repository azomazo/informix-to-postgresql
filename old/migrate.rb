#!/usr/bin/ruby

require 'postgres'

conn = PGconn.open('dbname' => 'tur')
res = conn.exec('select * from pg_catalog.pg_group;')
print res.status
