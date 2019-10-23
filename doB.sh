#!/bin/bash
k=$1
ver=P
pre=list201910.$ver
#scp -p da3:/data/update//$i.todo withDnld$i

#n=$(zcat $ver.$k/todo |wc -l)
#ch=$(($n/16+1)); zcat $ver.$k/todo | split -l $ch -d -a 2 --filter='gzip > $FILE.gz' - $ver.$i/1.$i.olist.
cd $ver.$i
sed "s/NNN/$i/g" ~/lookup/rDN1.pbs | qsub
