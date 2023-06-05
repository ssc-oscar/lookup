#!/bin/bash

c=/nics/b/home/audris/work
k=$1

cd $c
for p in {0..9}
do if [[ -f $c/ght.$k/stage.$p ]]
  then
  st=$(cat $c/ght.$k/stage.$p)
  [[ $st == "rm" ]] || [[ $st == "delete"  ]] || $HOME/bin/check.sh $k $p
  fi
done 
