#!/bin/bash

c=/nics/b/home/audris/work
k=$1
p=$2
ver=U
DT=New202109
cd $c
if [[ -f $c/$ver.$k/stage.$p ]]
then
  st=$(cat $c/$ver.$k/stage.$p)
  if [[ $st == "list" ]]; then 
    started=$(/usr/local/bin/qstat |grep  "$ver\.$k\.$p\."|grep -v ' C '|wc -l)
    if [[ $started -gt 0 ]]
    then cmd="check if running then start others started=$started startedr=$startedr"
    else cmd="cd $c/$ver.$k; sed \"s|NNN|$k.$p|;s|MMM|00|;s|ppn=1|ppn=2|;s|23|23|\" ../runU.pbs |/usr/local/bin/qsub"  
    fi
  else
    if [[ $st == "olist" ]]; then
      cmd="check if olist started, if not start"
      started=$(/usr/local/bin/qstat |grep  "$ver\.$k\.$p\."|grep -v ' C '|wc -l)
      startedr=$(/usr/local/bin/qstat |grep  "$ver\.$k\.$p\."|grep ' R '|wc -l)
      cmd="olist $started $startedr"
      if [[ -f $c/$ver.$k/CopyList.${ver}1.$k.$p.15 ]]; then
        logFile=$(ls $c/$ver.$k/$ver.$k.$p.15.o* 2> /dev/null)
        if [[ $started -eq 1 && ! -f $logFile ]]; then
          cmd="cd $c/$ver.$k; for i in {01..15}; do sed \"s|NNN|$k.$p|;s|MMM|\$i|;s|ppn=1|ppn=2|;s|23|23|\" ../runU.pbs |/usr/local/bin/qsub; done"
        else
          logFile=$(ls $c/$ver.$k/$ver.$k.$p.15.o* 2> /dev/null)
          if [[ $started -eq 0 && -f $logFile ]]; then
            startedE=$(/usr/local/bin/qstat |grep  "$ver$k\.$p\."|grep -v ' C '|wc -l)
            if [[ $startedE -eq 0 ]]; then cmd="cd $c/$ver.$k; sed \"s|NNN|$k.$p|;s|MMM|00|;s|ppn=1|ppn=1|;s|23|23|\" ../runU1.pbs |/usr/local/bin/qsub"
            else cmd="wait0 for all olist to finish started=$started startedr=$startedr startedE=$startedE"
            fi
          else
            cmd="wait1 for all olist to finish started=$started startedr=$startedr"
          fi
        fi
      else
        cmd="wait until 00 starts"
      fi
    else
      if [[ $st == "extract" ]]; then
        started=$(/usr/local/bin/qstat |grep  "$ver$k\.$p\."|grep -v ' C '|wc -l)
        startedr=$(/usr/local/bin/qstat |grep  "$ver$k\.$p\."|grep ' R '|wc -l)
        if [[ -f $c/$ver.$k/$DT${ver}1.$k.$p.olist.15.gz ]]; then
          if [[ -f $c/$ver.$k/$DT${ver}1.$k.$p.15.blob.idx ]]; then 
            if [[ $started -eq 0 ]]; then
              echo rsync > $c/$ver.$k/stage.$p 
              cmd="cd $c/$ver.$k; rsync -av *.olist.gz *.{tag,tree,blob,commit}.{idx,bin} bb1:/data/update/$ver.$k"    
            else
              cmd='wait0 for extract to finish'
            fi
          else
            if [[ $started -eq 1 ]]; then
              cmd="cd $c/$ver.$k; for i in {01..15}; do sed \"s|NNN|$k.$p|;s|MMM|\$i|;s|ppn=1|ppn=1|;s|23|23|\" ../runU1.pbs |/usr/local/bin/qsub;done"
            else
              cmd="wait1 until all are extracted"
            fi
          fi
        else
          cmd="wait until todo is processed to $c/$ver.$k/New$DT${ver}1.$k.$p.olist.15.gz"
        fi
      else
        if [[ $st == "rm" ]]; then
          #cmd="cd $c/$ver.$k; rm todo.* *.olist.*.gz *.err *.olist.gz *.{tag,tree,blob,commit}.{idx,bin}"
          echo delete > $c/$ver.$k/stage.$p
          #cd $c/$ver.$k; cat list$DT.${ver}1.$k.2 | while read r; do [[ -d "$r" ]] && find "$r" -delete; done
          cmd="removed"
        else
          if [[ $st == "clone" ]]; then
            cmd="wait until cloning completes"
          else
            if [[ $st == "delete" ]]; then
              #cmd="cd $c/$ver.$k; cat list$DT.${ver}1.$k.$p | while read r; do [[ -d "$r" ]] && find "$r" -delete; done"
              cmd="deleted"
            fi
          fi
        fi
      fi
    fi
  fi
else
  cmd="./do$ver.sh $k $p"
fi

echo $cmd $k $p $(date) >> $HOME/cronlog
if [[ $(echo $cmd |grep rsync |wc -l) -eq 1 ]]; then
  echo $(eval $cmd)
  if [ $? -eq 0 ]; then echo rm > $c/$ver.$k/stage.$p; fi
fi
if [[ $(echo $cmd |grep qsub |wc -l) -eq 1 ]]; then
  echo in qsub $k $p 
  if [[ $(echo $cmd |grep runU1.pbs |wc -l) -eq 1 ]]; then
    echo $(eval $cmd)
  else
    echo "initial stage"
    echo $(eval $cmd)
  fi
fi

