#!/bin/bash
k=$1
ver=R
DT=202003
pre=list$DT.$ver
dir=$ver.$k 
cd $dir
tac $pre.$k | while read i; do j=$(echo $i|sed 's|^https://a:a@||;s|/|_|;s|/|_|;s/^gh://;s|^bitbucket.org_|bb_|'); [[ -d $j ]] || git clone --mirror $i $j; done &
tac $pre.$k | while read i; do j=$(echo $i|sed 's|^https://a:a@||;s|/|_|;s|/|_|;s/^gh://;s|^bitbucket.org_|bb_|'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|sed 's|^https://a:a@||;s|/|_|;s|/|_|;s/^gh://;s|^bitbucket.org_|bb_|'); [[ -d $j ]] || git clone --mirror $i $j; done &
cat $pre.$k | while read i; do j=$(echo $i|sed 's|^https://a:a@||;s|/|_|;s|/|_|;s/^gh://;s|^bitbucket.org_|bb_|'); [[ -d $j ]] || git clone --mirror $i $j; done &
wait
cd ..
cat $dir/$pre.$k | while read i; 
do r=$(echo $i|sed 's|^https://a:a@||;s|/|_|;s|/|_|;s/^gh://;s|^bitbucket.org_|bb_|'); [[ -d $dir/$r ]] && echo $r
done > $dir/${pre}1.$k
cd $dir
cat ${pre}1.$k | while read i; do [[ -f $i/packed-refs ]] && echo $i/packed-refs;done | cpio -o | gzip > ../${pre}1.$k.cpio.gz
