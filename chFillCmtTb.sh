#!/usr/bin/zsh
for j in {0..4}
do da=da$j
  for i in $(eval echo "{$j..127..5}")
  do echo "start inserting $da file $i"
    time zcat /da?_data/basemaps/gz/c2chFullS$i.s | ~/lookup/chImportCmt.perl | clickhouse-client --max_partitions_per_insert_block=1000 --host=$da --query 'INSERT INTO commit_s FORMAT RowBinary'
  done
done 
