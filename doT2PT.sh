#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

cloneDir=/lustre/haven/user/audris/All.blobs
i=$1

tt=/tmp
cd $tt

echo START $(date +"%s") on $(hostname):$(pwd) TMPDIR="$TMPDIR"

fr=$i
to=$(($fr+15))

rm -f pids.$fr
for l in {0..15}
do i=$(($fr+$l))
   if [[ -f $cloneDir/tree_$i.bin ]] 
   then 
     (cp $cloneDir/tree_$i.{idx,bin} .; echo $i | perl -I $HOME/lib/perl5 $HOME/lookup/t2pt.perl $i $tt/tree_ $tt; cp -p t2pt$i.tch $cloneDir/; rm tree_$i.{idx,bin} t2pt$i.tch) &
     pid=$!
     echo "pid for $fr.$l is $pid" $(date +"%s")
     echo "$pid" >> pids.$fr
   fi
done

cat pids.$fr | while read pid
do echo "waiting  for $pid" $(date +"%s") 
  while [ -e /proc/$pid ]; do sleep 30; done
  free=$(df -k .|tail -1 | awk '{print $3/1e6}')
  echo "after waiting for $pid df=$free " $(date +"%s")
done
free=$(df -k .|tail -1 | awk '{print $3/1e6}')
echo "after waiting df=$free "  $(date +"%s")

free=$(df -k .|tail -1 | awk '{print $3/1e6}')
echo "after rm df=$free "  $(date +"%s")

echo DONE $(date +"%s")



