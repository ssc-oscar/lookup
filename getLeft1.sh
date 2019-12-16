#!/bin/bash
export LC_ALL=C 
export LANG=C  
cloneDir=/lustre/haven/user/audris/c2fbp
i=$1
k=$2
gunzip -c $cloneDir/cNot.$i.$k.c2fb.good $cloneDir/cNot.$i.$k.c2fb.good1 | cut -d\; -f1 | uniq | grep -v '[^0-9a-f]' | grep -v '^$' | lsort 3G -u > $cloneDir/cNotInC2fbp.$i.$k.done
gunzip -c $cloneDir/cNotInC2fbp.$i.$k.gz | join -v1 - $cloneDir/cNotInC2fbp.$i.$k.done | gzip > $cloneDir/cNotInC2fbp.$i.$k.left
n=$(gunzip -c $cloneDir/cNotInC2fbp.$i.$k.left | wc -l)
echo $n
