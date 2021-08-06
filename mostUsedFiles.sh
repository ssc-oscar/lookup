#!/usr/bin/bash

p=$1;

i=$p;
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
#get all blobs
echo $i |~/lookup/getValues -f P2b | cut -d\; -f2 |sort > $i
#get blobs originated
echo $i |~/lookup/getValues -f P2fb | cut -d\; -f2 |sort > $i.fb

rm $i.mostUsed 2>/dev/null;

zcat /da5_data/basemaps/gz/search.in | 
grep $p | 
sort -t\; -k7 -n | 
tail -5 | 
cut -d \; -f 1 |
while read line; do
	j=$line;
	j=$(echo $j |~/lookup/getValues p2P| cut -d\; -f2)
	#get all blobs
	echo $j |~/lookup/getValues -f P2b | cut -d\; -f2 |sort > $j
	#get blobs originated
	echo $j |~/lookup/getValues -f P2fb | cut -d\; -f2 |sort > $j.fb

	#list shared blobs created in $j and present in $i
	join $j.fb $i|~/lookup/getValues  b2f|cut -d\; -f1,2 >> $i.mostUsed
done;

cat $i.mostUsed |
cut -d\; -f2 | 
sed 's/.*\///' | 
grep '\.' | 
sed 's/.*\.//' | 
~/lookup/lsort 1G | 
uniq -c | 
sort -n | 
sed 's/ *//' |
tail;
