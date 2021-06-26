#!/usr/bin/bash

i=$1
#get canonical form of the repo in case non-canonical form is provided as argument
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
echo $i |~/lookup/getValues -f P2fb | cut -d\; -f2 |~/lookup/lsort 10G > $i.fb
#now get all commits
echo $i |~/lookup/getValues -f P2c | cut -d\; -f2 | ~/lookup/lsort 10G > $i.c
#finally get all blobs
cat $i.c |~/lookup/getValues -f c2b | awk -F\; '{print $2";"$1}' | ~/lookup/lsort 10G > $i.b2c
#exclude blobs created via commits that have invalid date
cat $i.fb | ~/lookup/getValues b2BadDate | cut -d\; -f1 > $i.badfb
#count Ps for each blob
join -v1 $i.fb $i.badfb | ~/lookup/getValues b2ManyP | ~/lookup/lsort 10G -t\; -k2 -n | head | sort -t\; -k1 > $i.fb2n

#now run diffs for all commits and join with #projects for that commit
echo "commit;file;blob;oldBlob;NumberOfProjectsUsingThatCommit"
join -t\; $i.fb2n $i.b2c | head | awk -F\; '{print $3";"$1";"$2}' | while IFS=\; read c b n
do echo $c | ssh -p443 da5 ~/lookup/cmputeDiff3.perl |grep $b | awk '{print $0";'$n'"}'
done
