#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

cloneDir=/lustre/medusa/audris/All.blobs
i=$1

tt=$TMPDIR
cd $tt

cd $cloneDir/
echo START $(date +"%s") on $(hostname):$(pwd) TMPDIR="$TMPDIR"
tt=$cloneDir

fr=$i
to=$(($fr+15))

rm -f pids.$fr
for l in {0..15}
do i=$(($fr+$l))
   if [[ -f $cloneDir/tree_$i.bin ]] 
   then 
     #(cp $cloneDir/tree_$i.{idx,bin} .; echo $i | perl -I $HOME/lib/perl5 $HOME/lookup/f2b.perl $i $tt $tt; cp -p f2b$i.tch $cloneDir/; rm tree_$i.{idx,bin} f2b$i.tch) &
     (echo $i | perl -I $HOME/lib/perl5 $HOME/lookup/f2b.perl $i $tt/tree_ $tt) &
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



