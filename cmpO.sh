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
echo comparing $i and $j 
echo $(join $i.fb $j|wc -l) blobs created in $i used in $j
echo $(join $i $j.fb|wc -l) blobs created in $j used in $i
echo $(join $i $j|wc -l) shared  between $i and $j
echo $(join -v1 $i $j|wc -l) blobs unique to $i
echo $(join -v2 $i $j|wc -l) blobs unique to $j
#list shared blobs
echo created in $i and present in $j
join $i.fb $j|~/lookup/getValues  b2f|cut -d\; -f1,2
echo created in $j and present in $i
join $j.fb $i|~/lookup/getValues  b2f|cut -d\; -f1,2
