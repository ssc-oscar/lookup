#!/usr/bin/bash

i=$1
j=$2
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
j=$(echo $j |~/lookup/getValues p2P| cut -d\; -f2)
#get all blobs in each
echo $i |~/lookup/getValues -f P2b | cut -d\; -f2 |sort > $i
echo $j |~/lookup/getValues -f P2b | cut -d\; -f2 |sort > $j
#get blobs originated in each
echo $i |~/lookup/getValues -f P2fb | cut -d\; -f2 |sort > $i.fb
echo $j |~/lookup/getValues -f P2fb | cut -d\; -f2 |sort > $j.fb

#output summary
echo $i $j $(join $i.fb $j|wc -l) $(join $i $j.fb|wc -l) $(join $i $j|wc -l) $(join -v1 $i $j|wc -l) $(join -v2 $i $j|wc -l) 
#list shared blobs
join $i $j
