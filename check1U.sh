#!/bin/bash

c=/nics/b/home/audris/work
k=$1
ver=U

cd $c
for p in {0..9}
do if [[ -f $c/$ver.$k/stage.$p ]]
  then
  st=$(cat $c/$ver.$k/stage.$p)
  [[ $st == "rm" ]] || [[ $st == "delete"  ]] || $HOME/bin/check${ver}.sh $k $p
  fi
done 
