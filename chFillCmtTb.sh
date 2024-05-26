#!/usr/bin/zsh
ver=$1
v=$(echo $ver|tr '[A-Z]' '[a-z]')

for j in {0..4}
do da=da$j
  for i in $(eval echo "{$j..31..5}")
  do echo "start inserting $da file $i"
    time /da?_data/basemaps/gz/Pkg2stat$i.gz | ~/lookup/chImportPkg.perl | clickhouse-client --max_partitions_per_insert_block=1000 --host=$da --query 'INSERT INTO api_u FORMAT RowBinary'
  done
  for i in $(eval echo "{$j..127..5}")
  do echo "start inserting $da file $i"
    time zcat /da?_data/basemaps/gz/c2chFullU$i.s | ~/lookup/chImportCmt.perl | clickhouse-client --max_partitions_per_insert_block=1000 --host=$da --query 'INSERT INTO commit_u FORMAT RowBinary'
  done
done 
