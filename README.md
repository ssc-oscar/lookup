# Scripts to create various lookup tables

# Update process

1. select a sample of repos (da0:/data/github/YearlyUpdate.sh)

        i. the mongodb github-ghReposList2017/repos for overview
        i. github-ghUsers17/repos for detail on 61454771 repos
        i. Out of 67579431 repos on GH ghReposList2017
        i. 39247534 are not forks ghReposList2017.nofork
        i. 9774023 not seen before list2017.u
        i. 1287830 repos with detail in bbList2017
1. clone repos in the list (breatk into 400Gb chunks based on size github.github-ghUsers17.repos.values.full_name.id.size.private.fork.forks.forks_count.watchers.watchers_count.stargazers_count.has_downloads.has_pages.open_issues.hompage.language.created_at.updated_at.pushed_at.default_branch.description)
1. extract olist.gz for each chunk
1. extract blobs, commits, trees, tags based on the olist (see beacon scripts below)
1. Update da4:/data/All.blobs

```
   ls -f New*.commit.bin /da3_data/lookup/AllUpdateObj.perl commit
   ls -f New*.tree.bin /da3_data/lookup/AllUpdateObj.perl tree
   ls -f New*.blob.bin /da3_data/lookup/AllUpdateObj.perl blob
   ls -f New*.tag.bin /da3_data/lookup/AllUpdateObj.perl tag
```
1. Verify it worked
```		
   for i in {0..127}; do /da3_data/lookup/checkBin.perl commit /data/All.blobs/commit_$i 4000; done
   for i in {0..127}; do /da3_data/lookup/checkBin.perl tree /data/All.blobs/tree_$i 4000; done
   for i in {0..127}; do /da3_data/lookup/checkBin.perl tag /data/All.blobs/tag_$i 4000; done
   for i in {0..127}; do /da3_data/lookup/checkBin.perl blob /data/All.blobs/blob_$i 4000; done
```
1. Update All.sha1c commit and tree needed for c2fb and cmptDiff2.perl
```
   for i in {0..127}; do /da3_data/lookup/Obj2ContUpdt.perl commit $i; done
   for i in {0..127}; do /da3_data/lookup/Obj2ContUpdt.perl tree $i; done
```
1. Update All.sha1o needed for f2b tree-based stuff
```
for i in {0..127}; do ./BlobN2Off.perl $i; done
```
1. Extract c2p info from New*.olist.gz
```
gunzip -c New*.olist.gz| cut -d\; -f1-3 | grep ';commit;' | awk -F\; '{ print $3";"$1}' | lsort 10G -t\; -k1b,2 -u | gzip > c2p.gz
```
1. Create c2fb New*.olist.gz
```
gunzip -c New*.olist.gz| cut -d\; -f2-3 | grep '^commit;' | cut -d\; -f2 | lsort 10G -u | gzip > c.cs
gunzip -c c.cs | /da3_data/lookup/cmputeDiff2.perl 2> c2fb.err | gzip > c2fb.c2fb
#check for empty/bad/missing in c2fb.err ({nc,npc,empty,bad}.cs nt.ts)
gunzip -c  c2fb.c2fb | cut -d\; -f1,2 | lsort 10G -t\; -k1b,2 -u | gzip > c2f.gz
gunzip -c  c2fb.c2fb | cut -d\; -f1,3 | awk -F\; '{ print $2";"$1}' | lsort 10G -t\; -k1b,2 -u | gzip > b2c.gz
```


1. Update various maps
```
/da3_data/lookup/Auth2CmtUpdt.perl /data/basemaps/Auth2Cmt.tch
```

## Cmt2Blob.sh
Blob to commit and inverse

## Prj2Cmt.sh
Project to commit and inverse


## f2b.md
describes mapping between trees/blobs and file/folder names. It
oprates off blob/tree/commit objects. The remaining maps utilize
c2fbp map split into 80 (1B line) chunks (see below).



## (OLD stuff) c2fbp.[0-9][0-9].gz

There are various ways to construct the commit to filename, blob,  
project map: c2fbp.[0-9][0-9].gz

For example:

cmptDiff2.perl producess diff for a commit

# beacon scripts
```
cat /nics/b/home/audris/bin/doBeaconUp.sh
#!/bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

k=${2:-CRAN}
cloneDir=${3:-/lustre/haven/user/audris/$k}
Y=${4:-2018}
list=${5:-list}
base=${6:-New}
base=$base$Y$k
m=$1

tt=/tmp
cd $tt
echo START $(date +"%s") on $(hostname):$(pwd) 
ls -l . | grep audris | awk '{print $NF}' |grep -v All.sha1 | while read dd
do echo removing /tmp/$dd 
   find /tmp/$dd -delete
done

echo $(df -k .)
free=$(df -k .|tail -1 | awk '{print int($4/1000000)}')
#echo $(df -k . |tail -1)
echo "START df=$free " $(date +"%s") 
#exit
if [[ "$free" -lt 400 ]] 
then echo "not enough disk space $free, need 600+GB"
     exit
fi


cp -p $cloneDir/$list$Y.$k.$m .
echo $cloneDir/$list$Y.$k.$m $(wc -l $list$Y.$k.$m)

cat $list$Y.$k.$m  | while read l
do [[ -d $cloneDir/$l ]] && echo $l
done > CopyList.$k.$m 
echo CopyList.$k.$m $(wc -l CopyList.$k.$m)
nlines=$(cat CopyList.$k.$m |wc -l)
part=$(echo "$nlines/16 + 1"|bc)
cat CopyList.$k.$m | split -l $part --numeric-suffixes - CopyList.$k.$m.

echo "cp -pr /lustre/haven/user/audris/All.sha1 ."
mkdir -p All.sha1
rsync -a /lustre/haven/user/audris/All.sha1/* All.sha1/ 
free=$(df -k .|tail -1 | awk '{print int($4/1e6)}')
echo "COPIED df=$free " $(date +"%s")


rm -f pids.$m
echo starting "$m"
#cat CopyList.$k.$m | split -l $part --numeric-suffixes - CopyList.$k.$m.
for l in {00..15}
do
  if [[ -f CopyList.$k.$m.$l ]]; then 
     (cat CopyList.$k.$m.$l | while read repo; do [[ -d $cloneDir/$repo/ ]] && cp -pr $cloneDir/$repo/ .; $HOME/bin/gitList.sh $repo | $HOME/bin/classify $repo 2>> $cloneDir/$base.$m.$l.olist.err; done | gzip > $cloneDir/$base.$m.$l.olist.gz; gunzip -c $cloneDir/$base.$m.$l.olist.gz | perl -I $HOME/lib/perl5 $HOME/bin/grabGit.perl $cloneDir/$base.$m.$l 2> $cloneDir/$base.$m.$l.err;cat CopyList.$k.$m.$l | while read d; do find $d -delete; done) &
     pid=$!
     echo "pid for $m.$l is $pid" $(date +"%s")
     echo "$pid" >> pids.$m
  fi
done


cat pids.$m | while read pid
do echo "waiting  for $pid" $(date +"%s") 
  while [ -e /proc/$pid ]; do sleep 30; done
  free=$(df -k .|tail -1 | awk '{print $4/1e6}')
  echo "after waiting for $pid df=$free " $(date +"%s")
done
free=$(df -k .|tail -1 | awk '{print $4/1e6}')
echo "after waiting df=$free "  $(date +"%s")

#cat CopyList.$k.$m | while read d; do find $d -delete; done
rm CopyList.$k.$m 
#rm -rf All.sha1
#rm ${base}.$m.*

free=$(df -k .|tail -1 | awk '{print $4/1e6}')

echo "after rm df=$free "  $(date +"%s")

echo DONE $(date +"%s")
```




