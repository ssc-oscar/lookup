#!/bin/bash
cloneDir=/lustre/haven/user/audris/c2fbp
i=$1
k=$2
n=$(gunzip -c $cloneDir/cNot.$i.$k.c2fb | wc -l)
n1=$(($n-1))
gunzip -c $cloneDir/cNot.$i.$k.c2fb | head -$n1 | gzip > $cloneDir/cNot.$i.$k.c2fb.good2
gunzip -c $cloneDir/cNot.$i.$k.c2fb.{good,good[12]} | cut -d\; -f1 | uniq | grep -v '[^0-9a-f]' | grep -v '^$' | lsort 3G -u > $cloneDir/cNotInC2fbp.$i.$k.done
gunzip -c $cloneDir/cNotInC2fbp.$i.$k.gz | join -v1 - $cloneDir/cNotInC2fbp.$i.$k.done | gzip > $cloneDir/cNotInC2fbp.$i.$k.left
n=$(gunzip -c $cloneDir/cNotInC2fbp.$i.$k.left | wc -l)
echo $n
