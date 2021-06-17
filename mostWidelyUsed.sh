#!/usr/bin/bash

i=$1
#get canonical form for a project
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
#list associated blobs
echo $i |~/lookup/getValues -f P2b | cut -d\; -f2 |/home/audris/bin/lsort 10G > $i.b
cat $i.b | ~/lookup/getValues b2fa | awk -F\; '{print $4";"$1}'  > $i.fc2b
cat $i.fc2b |~/lookup/getValues c2P |awk -F\; '{print $2";"$3}' | uniq |/home/audris/bin/lsort 10G -t\; -k1,2 -u > $i.b2P
#count number of projects that have each blob
cat $i.b | ~/lookup/getValues b2ManyP | lsort 10G -t\; -k1,1 | join -t\; - $i.b2P | ~/lookup/getValues b2f | cut -d\; -f1-4 |\
  /home/audris/bin/lsort 10G -t\; -k2 -rn > $i.b2n
#list few blobs with most projects
echo "blob;in#Projects;originatinReo;filname"
head $i.b2n
