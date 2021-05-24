#!/usr/bin/bash

i=$1
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
echo $i |~/lookup/getValues -f P2fb | cut -d\; -f2 |/home/audris/bin/lsort 10G > $i.fb
echo $i |~/lookup/getValues -f P2c | cut -d\; -f2 |/home/audris/bin/lsort 10G > $i.c
cat $i.c |~/lookup/getValues -f c2b | awk -F\; '{print $2";"$1}' | /home/audris/bin/lsort 10G > $i.b2c
cat $i.fb | ~/lookup/getValues b2BadDate | cut -d\; -f1 > $i.badfb
join -v1 $i.fb $i.badfb | ~/lookup/getValues b2ManyP | /home/audris/bin/lsort 10G -t\; -k2 -n | head | sort -t\; -k1 > $i.fb2n
join -t\; $i.fb2n $i.b2c | head | awk -F\; '{print $3";"$1";"$2}' | while IFS=\; read c b n
do echo $c | ~/lookup/cmputeDiff3.perl |grep $b | awk '{print $0";'$n'"}'
done
