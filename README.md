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
1. Verify input is good
```
   for t in commit blob tree tag; do ls -f *.$t.idx | sed 's/\.idx$//' | while read i; do /da3_data/lookup/checkBin1in.perl $t $i; done; done
```
1. Update da4:/data/All.blobs

```
   ls -f *.commit.bin | /da3_data/lookup/AllUpdateObj.perl commit
   ls -f *.tree.bin | /da3_data/lookup/AllUpdateObj.perl tree
   ls -f *.blob.bin |  /da3_data/lookup/AllUpdateObj.perl blob
   ls -f *.tag.bin | /da3_data/lookup/AllUpdateObj.perl tag
```
1. Verify it worked (up to 4K (or more if needed) records
```		
   for i in {0..127}; do /da3_data/lookup/checkBin.perl commit /data/All.blobs/commit_$i 10000; done
   for i in {0..127}; do /da3_data/lookup/checkBin.perl tree /data/All.blobs/tree_$i 10000; done
   for i in {0..127}; do /da3_data/lookup/checkBin.perl tag /data/All.blobs/tag_$i 10000; done
   for i in {0..127}; do /da3_data/lookup/checkBin.perl blob /data/All.blobs/blob_$i 10000; done
```
1. Update All.sha1c commit and tree needed for c2fb and cmptDiff2.perl
```
   nmax=2000000
   #  1475976;
   for i in {0..127}; do /da3_data/lookup/Obj2ContUpdt.perl commit $i $nmax; done
   nmax=8227751
   for i in {0..127}; do /da3_data/lookup/Obj2ContUpdt.perl tree $i $nmax; done
```
1. Update All.sha1o needed for f2b tree-based stuff
```
for i in {0..127}; do /da3_data/lookup/BlobN2Off.perl $i; done
```
1. Extract c2p info from *.olist.gz
```
cd /data/update
for i in with withFrk withWch withIssues chris chrisB py
do cd /data/update/$i
   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /data/basemaps/Prj2CmtG 8 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 20G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 20G -u -t\; -k1b,2 | gzip > c2p.s
done
cd /data/update
lsort 20G -t\; -k1b,2 --merge <(gunzip -c with/p2c.s) <(gunzip -c withFrk/p2c.s) <(gunzip -c withWch/p2c.s) <(gunzip -c withIssues/p2c.s) <(gunzip -c chris/p2c.s) <(gunzip -c chrisB/p2c.s) <(gunzip -c py/p2c.s)  | uniq | /da3_data/lookup/splitSecCh.perl Inc20180510.p2c. 8

lsort 20G -t\; -k1b,2 --merge <(gunzip -c with/c2p.s) <(gunzip -c withFrk/c2p.s) <(gunzip -c withWch/c2p.s) <(gunzip -c withIssues/c2p.s) <(gunzip -c chris/c2p.s) <(gunzip -c chrisB/c2p.s) <(gunzip -c py/c2p.s)  | uniq | /da3_data/lookup/splitSec.perl Inc20180510.c2p. 8

for i in CRAN cve secure js with withFrk withWch
do gunzip -c $i/*.olist*.gz| cut -d\; -f1-3 | grep ';commit;' |\
   sed 's/;commit;/;/;s|/*;|;|;s|\.git;|;|;s|/*;|;|'  | \
   perl -ane 'chop();($p,$c)=split(/\;/,$_,-1);next if $c !~ m/^[a-f0-9]{40}$/; $p=~s/.*github.com_(.*_.*)/$1/;$p=~s/^bitbucket.org_/bb_/;$p=~s|\.git$||;$p=~s|/*$||;$p=~s/\;/SEMICOLON/g;$p = "EMPTY" if $p eq "";print "$c;$p\n";'\
   | lsort 20G -t\; -k1b,2 -u | gzip > $i/c2p.$i.gz 
done
lsort 10G -t\; -k1b,2 -u --merge <(gunzip -c CRAN/c2p.CRAN.gz)  <(gunzip -c secure/c2p.secure.gz) <(gunzip -c cve/c2p.cve.gz) <(gunzip -c js/c2p.js.gz) | /da3_data/lookup/splitSec.perl Inc20180213.c2p. 8
```
1. Create c2fb
```
cd /data/update

for i in CRAN cve secure js
do cd $i
  gunzip -c c2p.$i.gz | cut -d\; -f1 | lsort 10G -u | gzip > c.$i.cs
  gunzip -c c.$i.cs | /da3_data/lookup/splitSec.perl c.$i.cs. 8 
  cd ..
done
for j in {0..7}
do for i in CRAN cve secure js bbnew
  do gunzip -c $i/c.$i.cs.$j.gz
  done | lsort 10G -u  |gzip > Inc20180213.c2f.$j.gz
done
for j in {0..7}; do gunzip -c /data/basemaps/gz/c2fFullE$j.s | cut -d\; -f1 | uniq | join -v2 - <(gunzip -c Inc20180213.c2f.$j.gz) | gzip > Inc20180213.c2f.$j.todo & done
for j in {0..7} 
do gunzip -c Inc20180213.c2f.$j.todo | /da3_data/lookup/cmputeDiff2.perl 2> Inc20180213.c2f.$j.err | gzip > Inc20180213.c2f.$j.c2fb &
done

#get full list of stuff in the database
cut -d\; -f4 /data/All.blobs/commit_*.idx | lsort 40G | gzip > /data/basemaps/cmts.s1
gunzip -c /data/basemaps/cmts.s | join -v1 <(gunzip -c /data/basemaps/cmts.s1) - | gzip > /data/basemaps/cmts.s1.new

#check for/update empty/bad/missing in c2fb.err ({nc,npc,empty,bad}.cs nt.ts)
# empty.cs have no files changed, bad.cs have tree or parent missing, and nc.cs are simply missing and need to be extrcted null.cs are null (content is \x00'oes)
for j in {0..7}; do gunzip -c Inc20180213.c2f.$j.todo; done | lsort 10G -u > Inc20180213.c2f.new
gunzip -c Inc20180213.*.c2f  | cut -d\; -f1 | lsort 20G -u > Inc20180213.c2f.in
for j in {0..7}; do cat Inc20180213.c2f.$j.err; done > Inc20180213.err
#get missing commits
cat Inc20180213.err | grep '^no commit ' | sed 's/^no commit //;' |lsort 10g -u | join -v1 - Inc20180213.c2f.in > Inc20180213.nc 
# and missing parents
cat Inc20180213.err | grep '^no parent commit: ' | sed 's/no parent commit: //;s/.* for //'| lsort 10G -u | join -v1 - Inc20180213.nc  | join -v1 - Inc20180213.c2f.in > Inc20180213.ncs.par

#make sure newly aquired cs are excluded and new ones added
gunzip -c /data/basemaps/cmts.s | join -v2 - <((gunzip -c /data/basemaps/nc.cs; cat Inc20180213.nc Inc20180213.ncs.par) | lsort 10G -u) | gzip > /data/basemaps/nc.cs1
mv /data/basemaps/nc.cs1 /data/basemaps/nc.cs

cat Inc20180213.err | grep '^no parent commit: ' | awk '{print $6}' | lsort 10G -u > Inc20180213.npc 
cat Inc20180213.err | grep '^no tree:' | grep  parent | sed 's/^no tree:[0-9a-f]* for //;s/^parent //;s/ for .*//' | lsort 10G -u >  Inc20180213.c1
cat Inc20180213.err | grep '^no tree:' | grep  parent | sed 's/^no tree:[0-9a-f]* for //;s/^parent [^ ]* for //' | lsort 10G -u > Inc20180213.c2 
cat Inc20180213.err | grep '^no tree:' | grep -v 'for parent' | sed 's/.* for //;' | lsort 10G -u |  lsort 10G -u > Inc20180213.c3 
cat Inc20180213.err | grep '^no tree:' | sed 's/^no tree://;s/ .*//' | lsort 10G -u > Inc20180213.nt
cat Inc20180213.{nc,ncs.par,npc,c[1-3]} | lsort 10G -u | join -v1 - Inc20180213.c2f.in >  Inc20180213.c2f.bad
#double check these are really bad 
cat Inc20180213.c2f.bad | /da3_data/lookup/cmputeDiff2.perl 2> /dev/null >  Inc20180213.c2f.bad.c2fb
wc -l Inc20180213.c2f.bad.c2fb
join -v1 Inc20180213.c2f.new Inc20180213.c2f.in | join -v1 - Inc20180213.c2f.bad > Inc20180213.c2f.empty
#verify empty
cat Inc20180213.c2f.empty | /da3_data/lookup/cmputeDiff2.perl

#now update empty, nt, bad
#empty
lsort 10G -u --merge <(gunzip -c /data/basemaps/empty.cs) Inc20180213.c2f.empty | gzip > /data/basemaps/empty.cs1
mv /data/basemaps/empty.cs1 /data/basemaps/empty.cs

#nt
#did we find any new trees
gunzip -c /data/basemaps/nt.ts | /da3_data/lookup/showTree.perl -1 | sort -u > Inc20180213.c2f.ts
lsort 10G -u --merge <(gunzip -c /data/basemaps/nt.ts) Inc20180213.nt | join -v1 - Inc20180213.c2f.ts | gzip > /data/basemaps/nt.ts1
#make sure all are missing
gunzip -c /data/basemaps/nt.ts1 | /da3_data/lookup/showTree.perl -1
mv /data/basemaps/nt.ts1 /data/basemaps/nt.ts

# bad
lsort 10G -u --merge <(gunzip -c /data/basemaps/bad.cs) Inc20180213.c2f.bad | gzip > /data/basemaps/bad.cs1
gunzip -c  /data/basemaps/bad.cs1 | /da3_data/lookup/cmputeDiff2.perl 2> /dev/null > seeIfBad
cut -d\; -f1 seeIfBad | uniq | lsort 10G -u | join -v1 - Inc20180213.c2f.in > Inc20180213.c2f.in.extra
grep -Ff Inc20180213.c2f.in.extra seeIfBad | /da3_data/lookup/splitSec.perl Inc20180213.c2f.extra. 8

gunzip -c /data/basemaps/bad.cs1 | join -v1 - <(cut -d\; -f1 seeIfBad | uniq | lsort 10G -u) | gzip > /data/basemaps/bad.cs
rm  /data/basemaps/bad.cs1


#now create c2f and b2c
for j in {0..7}
do  gunzip -c Inc20180213.c2f.$j.c2fb bbnew/missed.$j.c2fb Inc20180213.c2f.extra.$j.gz | cut -d\; -f1,2 | sed 's|;/|;|' | lsort 10G -t\; -k1b,2 -u | gzip > Inc20180213.c2f.$j.c2f &
done

#exclude commmits deleting files grep -v '^;'
for j in {0..7}; do  
  gunzip -c Inc20180213.c2f.$j.c2fb bbnew/missed.$j.c2fb  Inc20180213.c2f.extra.$j.gz | cut -d\; -f1,3 | grep -v '^;' | awk -F\; '{ print $2";"$1}' 
done | lsort 10G -t\; -k1b,2 -u | /da3_data/lookup/splitSec.perl Inc20180213.b2c. 16 &


for j in {0..7}; do 
  lsort 10G --merge -u -t\; -k1b,2 <(gunzip -c /data/basemaps/gz/c2fFullE$j.s) \ 
    <(gunzip -c Inc20180213.c2f.$j.c2f) | gzip > /data/basemaps/gz/c2fFullF$j.s
done


```
1. Update various maps
```
/da3_data/lookup/Auth2Cmt.perl /data/basemaps/Auth2CmtNew.tch
# The above may be faster and more correct
# /da3_data/lookup/Auth2CmtUpdt.perl /data/basemaps/Auth2Cmt.tch
/da3_data/lookup/Cmt2Par.perl /data/basemaps/Cmt2Chld.tch
```
ls -l /da4_data/basemaps/{Auth2Cmt,Cmt2Chld,Auth2File}.tch

## Cmt2Blob.sh Blob to commit and inverse
```
ls -l /da4_data/basemaps/gz/f2cFullF[0-7].s
ls -l /da4_data/basemaps/f2cFullF.[0-7].tch


ls -l /da4_data/basemaps/gz/c2fFullF[0-7].s
ls -l /da4_data/basemaps/c2fFullF.[0-7].tch

ls -l /da4_data/basemaps/gz/b2cFullF*.s
ls -l /da4_data/basemaps/b2cFullF.*.tch

ls -f /da4_data/basemaps/gz/c2bFullF[0-7].gz
ls -l /da4_data/basemaps/c2bFullF.*.tch
```

## Prj2Cmt.sh Project to commit and inverse
```
ls -l /da4_data/basemaps/gz/Cmt2PrjG*.s
ls -l /da4_data/basemaps/Cmt2PrjG.*.tch
ls -l /da4_data/basemaps/gz/Prj2CmtG*.s
```

## f2b.md
describes mapping between trees/blobs and file/folder names. It
oprates off blob/tree/commit objects. The remaining maps utilize
c2fbp map split into 80 (1B line) chunks (see below).

# Update commit message map
```
cd /da3_data/delta
for i in {0..127}; do /da3_data/lookup/lstCmt.perl $i 1 |gzip > cmt.$i.lst; done
for i in {0..127}; do gunzip -c cmt.$i.lst; done | gzip > cmt.lst

gunzip -c /da4_data/update/Inc20180213.c2f.[0-7].gz |uniq | /da3_data/lookup/showCmt.perl 1 | gzip > Inc20180213.delta
#gunzip -c /da4_data/update/Inc20180213.c2p.[0-7].gz | cut -d\; -f1 | uniq | /da3_data/lookup/showCmt.perl 1 | gzip > Inc20180213.delta
gunzip -c Inc20180213.delta | perl -I ~/lib64/perl5/ deltaHash.perl
perl -I ~/lib64/perl5 /home/audris/bin/listTC.perl delta.tch 1 | gzip > delta.id2content.gz

cat delta.idx | perl -ane 'chop();@x=split(/\;/, $_,-1); $c=$x[2];next if length($c) != 40 || "$c" =~ /[^0-9a-f]/;print "$c;$x[0];$x[1]\n";' | uniq | lsort 130G -u -t\; -k1b,2 |gzip > delta.idx.37.c2mid
lsort 20G --merge -t\; -k1b,2 -u <(gunzip -c delta.idx.37.c2mid) <(gunzip -c delta.idx.c2mid) | gzip > delta.idx.c2mid1
mv delta.idx.c2mid1 delta.idx.c2mid

# ? gunzip -c /da3_data/delta/delta.idx.c2mid | sed 's/;/;;;/' | perl /da3_data/lookup/Cmt2PrjBinSorted.perl mid2cmt.tch 1
# ? gunzip -c /da3_data/delta/delta.idx.c2mid | awk -F\; '{print $2";"$1}' | /da3_data/lookup/File2CmtBin.perl delta.idx.mid2c 1
gunzip -c delta.id2content.gz | grep -iw cve > ALLCVEs
cut -d\; -f1 ALLCVEs | gzip > ALLCVEs.ids
gunzip -c delta.idx.c2mid | ~/bin/grepField.perl ALLCVEs.ids 2 | cut -d\; -f1 | gzip > ALLCVEs.cs
gunzip -c ALLCVEs.cs | /da3_data/lookup/showCmt.perl 2> CVEbadcmt | gzip > CVECommitInfo
gunzip -c ALLCVEs.cs | /da3_data/lookup/Cmt2PrjShow.perl /da4_data/basemaps/Cmt2PrjG 1 8 | gzip > ALLCVEs.c2p
gunzip -c ALLCVEs.cs | /da3_data/lookup/Cmt2PrjShow.perl /da4_data/basemaps/c2fFullF 1 8 | gzip > ALLCVEs.c2f
gunzip -c ALLCVEs.cs | /da3_data/lookup/Cmt2BlobShow.perl /da4_data/basemaps/c2bFullE 1 16 | gzip > ALLCVEs.c2b
#get file names without path and search of them in /da4_data/basemaps/f2cFullF
gunzip -c ALLCVEs.c2f| perl -ane 'chop();($c,$n,@fs)=split(/;/,$_,-1);for my $f (@fs){print "$f\n";}' | lsort 10G -u | gzip > ALLCVEs.fs
gunzip -c /da4_data/basemaps/f2cFullF.[0-7].lst | ~/bin/grepFile.perl ALLCVEs.fs 1 | cut -d\; -f1 | lsort 10G -u > ALLCVEs.fs.all

# seems like common names that need to be excluded to track vulnerable files
gunzip -c ALLCVEs.fs| awk -F/ '{print $NF}' | lsort 10G | uniq -c | sort -rn | head
  25351 Makefile
   8443 distinfo
   5546 pkg-descr
   3972 default.nix
   3617 pkg-plist
    823 Makefile.in
    777 index.html
    713 README
    682 Kconfig
    653 Pkgfile

cat ALLCVEs.fs.all| awk -F/ '{print $NF}' | lsort 10G | uniq -c | sort -rn | head
13923697 index.js
12497147 package.json
11913352 README.md
10694499 index.html
5715190 LICENSE
3657013 Makefile
3482778 .npmignore
2953876 __init__.py
2532450 description.txt
2208862 .travis.yml
```

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




