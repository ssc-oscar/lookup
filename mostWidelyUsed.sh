#!/usr/bin/bash

i=$1
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
echo $i |~/lookup/getValues -f P2b | cut -d\; -f2 |/home/audris/bin/lsort 10G > $i.b
cat $i.b | ~/lookup/getValues b2ManyP | /home/audris/bin/lsort 10G -t\; -k2 -rn > $i.b2n
head $i.b2n
