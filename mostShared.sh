#!/usr/bin/bash

i=$1
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
echo $i |~/lookup/getValues -f P2fb | cut -d\; -f2 |/home/audris/bin/lsort 10G > $i.fb
cat $i.fb | ~/lookup/getValues b2BadDate | cut -d\; -f1 > $i.badfb
join -v1 $i.fb $i.badfb | ~/lookup/getValues b2ManyP | /home/audris/bin/lsort 10G -t\; -k2 -rn > $i.fb2n
head $i.fb2n
