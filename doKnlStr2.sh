#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH
cloneDir=$1
m=$2



cd $cloneDir
cd /tmp
cp -p $cloneDir/authors.[0-9][0-9] .
rm -f pids.$m
echo starting "$m"
for l in {00..63}
do 
   ($cloneDir/jwm $m $l | gzip > $cloneDir/author.$m.$l.gz) &
   pid=$!
   echo "pid for $m.$n.$l is $pid" $(date +"%s")
   echo "$pid" >> pids.$m
done


cat pids.$m | while read pid
do echo "waiting  for $pid" $(date +"%s") 
  while [ -e /proc/$pid ]; do sleep 30; done
  free=$(df -k .|tail -1 | awk '{print $4/1e6}')
  echo "after waiting for $pid df=$free " $(date +"%s")
done
free=$(df -k .|tail -1 | awk '{print $4/1e6}')
echo "after waiting df=$free "  $(date +"%s")
rm /tmp/authors.*

echo DONE $(date +"%s")

