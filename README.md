# Available maps/tables and their locations 
In da4:/data/basemaps

The last letter denotes version (in alphabetical order)

1. author2commit: Auth2CmtF.tch
Grab a list of authors
```
echo "Audris Mockus <audris@utk.edu>" | /da3_data/lookup/Prj2CmtShow.perl /data/basemaps/Auth2CmtF.tch 1
```
2. author2file: Auth2File.tch, tese are files for blobs created or deeted by the commit (see 6)
```
echo "Audris Mockus <audris@utk.edu>" | /da3_data/lookup/Prj2FileShow.perl /data/basemaps/Auth2File.tch 1
```

3. blob2commit: b2cFullF.{0..15}.tch
```
echo 05fe634ca4c8386349ac519f899145c75fff4169 | /da3_data/lookup/Cmt2BlobShow.perl /data/basemaps/b2cFullF 1 16
```

4. commit2blob: c2bFullF.{0..15}.tch 
```
echo e4af89166a17785c1d741b8b1d5775f3223f510f | /da3_data/lookup/Cmt2BlobShow.perl /data/basemaps/c2bFullF 1 16
```

5. commit2project: Cmt2PrjG.{0..8}.tch  (A new version Cmt2PrjH exists, not sure it's complete)
```
echo e4af89166a17785c1d741b8b1d5775f3223f510f |/da3_data/lookup/Cmt2PrjShow.perl /data/basemaps/Cmt2PrjH 1 8
```

6. file2commit: f2cFullF.{0..8}.tch, tese are files for blobs created or deeted by the commit
```
echo main.c |/da3_data/lookup/Prj2CmtShow.perl /data/basemaps/f2cFullF 1 8
```

7. project2commit: Prj2CmtG.{0..8}.tch
```
echo ArtiiQ_PocketMine-MP |/da3_data/lookup/Prj2CmtShow.perl /data/basemaps/Prj2CmtG 1 8
```

## How to see a content of a commit
```
echo e4af89166a17785c1d741b8b1d5775f3223f510f | perl ~audris/bin/showCmt.perl 
```
## How to see a content of a tree
```
echo f1b66dcca490b5c4455af319bc961a34f69c72c2 | perl ~audris/bin/showTree.perl
```
## How to see conrent of a blob
```
echo 05fe634ca4c8386349ac519f899145c75fff4169 | perl ~audris/bin/showBlob.perl
```



##############################################

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
1. Extract c2p info from *.olist.gz, olist.gz is obtained first, then objects are extracted based on it
```


cd /data/update
# 20180801
for i in {0..7}
do lsort 5G -t\; -k1b,2 -u --merge --parallel=4 <(zcat Cmt2PrjH$i.s) <(zcat Inc20180710.c2p.$i.gz) <(zcat c2p1.s.$i.gz) | gzip > Cmt2PrjI$i.s 
lsort 10G -t\; -k1b,2 -u <(zcat Prj2CmtH$i.gz) | gzip > Prj2CmtH$i.s 
lsort 10G -t\; -k1b,2 -u --merge <(zcat Prj2CmtH$i.gz) <(zcat Inc20180710.p2c.$i.gz) <(zcat p2c1.s.$i.gz) | gzip > Prj2CmtI$i.s 
done
for i in {0..7}
do zcat Cmt2PrjI$i.s | perl $HOME/bin/splitSec.perl c2pFullI$i. 32 
do zcat Prj2CmtI$i.s | perl $HOME/bin/splitSecCh.perl p2cFullI$i. 32 
done

zcat Cmt2PrjI7.s | wc -l 
4595547866
zcat c2pFullI{7,15,23,314
}.s | wc -l 
4593889548



for i in {0..31}
zcat c2pFullI$i.gz | awk -F\; '{print $1";;;"$2}'| perl -I $HOME/lib/perl5 $HOME/lookup/Cmt2PrjBinSorted.perl c2pFullI.$i.tch 1
zcat c2pFullI$i.s | perl connectExportPre.perl | gzip > c2pFullI$i.p2p 
zcat c2pFullI$i.p2p | perl connectExportSrt.perl c2pFullI$i 
perl connectImport.perl c2pFullI$i | gzip > c2pFullI$i.map
done

zcat c2pFullI*.map | perl connectExportPre1.perl c2pFullI
zcat c2pFullI.versions |  ./connect | gzip > c2pFullI.clones
perl connectImport.perl c2pFullI | gzip > c2pFullI.forks

i=withNthng
cd /data/update/$i
gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl p2cFullI 32 | gzip > p2c.gz

# 20180710
for i in withDnld emr gl 
do cd /data/update/$i
   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /data/basemaps/Prj2CmtH 8 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   cut -d\; -f4 *.commit.idx | lsort 20G -u > cs
done
cd ../
zcat {emr,gl,withDnld}/cs | lsort 50G -u > cs.20180710
zcat /data/basemaps/cmts.s3 | lsort 10G -u --merge - <(zcat cs.20180710) | gzip > /data/basemaps/cmts.s4
zcat /data/basemaps/cmts.s3 | join -v2 - <(zcat cs.20180710) | gzip > /data/basemaps/cmts.s4.new
zcat /da4_data/basemaps/cmts.s4.new | split -l 2075511 -d -a 2 --filter="gzip ? $FILE.gz" - cmts.s4.new. 

lsort 20G -t\; -k1b,2 --merge <(gunzip -c emr/p2c.s) <(gunzip -c withDnld/p2c.s) <(gunzip -c gl/p2c.s|awk '{print "gl_"$0}') | uniq | /da3_data/lookup/splitSecCh.perl Inc20180710.p2c. 8
lsort 20G -t\; -k1b,2 --merge <(gunzip -c emr/c2p.s) <(gunzip -c withDnld/c2p.s) <(gunzip -c gl/c2p.s|sed 's/;/;gl_/') | uniq | /da3_data/lookup/splitSec.perl Inc20180710.c2p. 8


# 20180510
for i in bbnew # with withFrk withWch withIssues chris chrisB py
do cd /data/update/$i
   #use seen to avoid extracting the same object twice, as in runing iteratively, over multiple folders
   #zcat *.olist.gz | ~/bin/grepFieldv.perl ../seen 3 | perl -ane '@x=split(/;/);print if !defined $m{$x[2]}; $m{$x[2]}++' | ~/bin/hasObj.perl | gzip > 12-17.todo
   zcat *.olist.gz | perl -ane '@x=split(/;/);print if !defined $m{$x[2]}; $m{$x[2]}++' | ~/bin/grepFieldv.perl ../bbnew/olist.willextract 3 \
            | ~/bin/hasObj.perl | gzip > olist.todo
   for m in {00..14}; do for n in {00..01}; do zcat olist.todo | ~/bin/grepField.perl list2018.withDnld1.$m.$n.gz 1 | gzip > $m.$n.todo; done; done


   #zcat *.olist.gz | cut -d\; -f3 | perl -e 'while(<STDIN>){chop();$x{$_}++};while (($k,$v)=each %x){print "$k\n"}' | gzip > seen
   zcat olist.todo | cut -d\; -f3 |perl -e 'while(<STDIN>){chop();$x{$_}++};while (($k,$v)=each %x){print "$k\n"}' | gzip > olist.willextract
   #handle subfolders on knl by separating extraction by the folder in which repo resides in
   #for m in {00..25}; do zcat *.$m.[0-9][0-9].olist.gz |cut -d\; -f1 | lsort 3G -u | gzip > $m; done 
   #for m in {00..25}; do zcat olist.todo | ~/bin/grepField.perl $m 1 | gzip > olist.todo.$m; done

   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /data/basemaps/Prj2CmtH 8 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
done
cd /data/update
lsort 20G -t\; -k1b,2 --merge <(gunzip -c with/p2c.s) <(gunzip -c withFrk/p2c.s) <(gunzip -c withWch/p2c.s) <(gunzip -c withIssues/p2c.s) <(gunzip -c chris/p2c.s) <(gunzip -c chrisB/p2c.s) <(gunzip -c py/p2c.s)  | uniq | /da3_data/lookup/splitSecCh.perl Inc20180510.p2c. 8

lsort 20G -t\; -k1b,2 --merge <(gunzip -c with/c2p.s) <(gunzip -c withFrk/c2p.s) <(gunzip -c withWch/c2p.s) <(gunzip -c withIssues/c2p.s) <(gunzip -c chris/c2p.s) <(gunzip -c chrisB/c2p.s) <(gunzip -c py/c2p.s)  | uniq | /da3_data/lookup/splitSec.perl Inc20180510.c2p. 8

```
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
1. Update Author to commit map
```
#/da3_data/lookup/Auth2Cmt.perl /data/basemaps/Auth2CmtNew.tch
# The above may be more correct
# 394525: how much back to go from the end of All.blobs/commit_X.idx
#time /da3_data/lookup/Auth2CmtUpdt.perl Auth2CmtNew 394525
#time /da3_data/lookup/Auth2CmtMrg.perl Auth2CmtNew Auth2CmtNew.new Auth2CmtH
#Alternative
./lstCmt.perl 4 | awk -F\; '{print $2 ";" $1}' | lsort 200G -t\; -k1b,2  | gzip > a2c.s
gunzip -c a2c.s | ./Prj2CmtBinSorted.perl Auth2CmtH.tch

./lstCmt.perl -1  | gzip > c2t.gz

```
1. Create c2fb
```
cd /data/update/c2fb
#get full list of commits in the database
zcat cmts.s4.new.*.c2fb \
perl -I $HOME/lookup -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' |\
 /da3_data/lookup/splitSec.perl Inc20180710.c2f. 32

for j in {0..31}; do 
  zcat Inc20180710.c2f.$j.gz | lsort 30G -t\; -k1b,2 | gzip > Inc20180710.c2f.$j.s
  lsort 10G --merge -u -t\; -k1b,2 <(zcat c2fFullJ$j.s) \ 
  <(zcat Inc20180710.c2f.$j.s| cut -d\; -f1,2 | sed 's|;/|;|') | \
    gzip > c2fFullI$j.s
  zcat c2fFullI$j.s | /da3_data/lookup/Cmt2FileBinSorted.perl c2fFullI.$j.tch 1
done

zcat cmts.s4.new.*.c2fb | cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | 
  perl -I $HOME/lookup -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' |\
  awk -F\; '{ print $2";"$1}' | \
  perl $HOME/bin/splitSec.perl Inc20180710.b2c. 32
 
for j in {0..31}; do 
  zcat Inc20180710.b2c.$j.gz | lsort 30G -t\; -k1b,2 | gzip > Inc20180710.b2c.$j.s
  lsort 10G --merge -u -t\; -k1b,2 <(zcat b2cFullJ$j.s) \ 
  <(zcat Inc20180710.c2f.$j.s| cut -d\; -f1,2 | sed 's|;/|;|') | \
    gzip > c2fFullI$j.s

#fix missing blobs
zcat cmts.s.extra.c2fb.[0-7].gz |\
  cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | grep -v ';$'| \
  perl -I $HOME/lib64/perl5 -I $HOME/lookup/ -e 'use cmt; while(<STDIN>){ ($b, $c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' | \
  awk -F\; '{ print $2";"$1}' | \
  $HOME/bin/splitSec.perl cmts.s.extra.b2c. 32      

(j=0; lsort 10G --merge -u -t\; -k1b,2 <(zcat /data/basemaps/gz/c2fFullH$j.s)  <(zcat /da3_data/update/c2fb/cmts.s.extra.c2fb.$j.gz| cut -d\; -f1,2 | sed 's|;/|;|') |perl -I ~/lib64/perl5/ -I /da3_data/lookup/ -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' | gzip > /data/basemaps/gz/c2fFullJ$j.s) &
(j=0; lsort 10G --merge -u -t\; -k1b,2 <(zcat /data/basemaps/gz/b2cFullH$j.s)  <(zcat /da3_data/update/c2fb/cmts.s.extra.c2fb.$j.gz| awk -F\; '{print $2";"$1}' |lsort 2G -t\; -k1b,2) |perl -I ~/lib64/perl5/ -I /da3_data/lookup/ -e 'use cmt; while(<STDIN>){ ($b,$c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' | | gzip > /data/basemaps/gz/b2cFullJ$j.s) &


#cut -d\; -f4 /data/All.blobs/commit_*.idx | lsort 40G | gzip > /data/basemaps/cmts.s1
gunzip -c /data/basemaps/cmts.s | join -v1 <(gunzip -c /data/basemaps/cmts.s1) - | gzip > /data/basemaps/cmts.s1.new
gunzip -c cmts.s1.new | split -l 2075511 -d -a2 --filter='gzip > $FILE.gz' - cmts.s1.new.
#this takes a while and requires All.sha1c/{commit,tree}_{0..127}.tch
for i in {00..99}
do gunzip -c cmts.s1.new.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> cmts.s1.new.$i.err | gzip > cmts.s1.new.$i.c2fb
done

#now put all of that good into one place
zcat cmts.s[1-3].new.*.c2fb | /da3_data/lookup/splitSec.perl /data/update/Inc20180510.c2f. 8 
cd /data/update

#now create c2f and b2c (potentially using debugging from below)
for j in {0..7}; do 
  zcat Inc20180510.c2f.$j.gz | lsort 80G -t\; -k1b,2 | gzip > Inc20180510.c2f.$j.s
  lsort 10G --merge -u -t\; -k1b,2 <(zcat /data/basemaps/gz/c2fFullF$j.s) \ 
    <(zcat Inc20180510.c2f.$j.s| cut -d\; -f1,2 | sed 's|;/|;|') | gzip > /data/basemaps/gz/c2fFullH$j.s
  zcat /da4_data/basemaps/gz/c2fFullH$j.s | /da3_data/lookup/Cmt2FileBin.perl /da4_data/basemaps/c2fFullH.$j.tch 1
done

zcat cmts.s[1-3].new.*.c2fb | cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | awk -F\; '{ print $2";"$1}' | \
  /da3_data/lookup/splitSec.perl /data/update/Inc20180510.b2c. 16 
for j in {0..15}; do
   zcat /data/update/Inc20180510.b2c.$j.gz| grep -v '^;' | grep -v '^$' | lsort 20G -t\; -k1b,2 | gzip > /data/update/Inc20180510.b2c.$j.s
   lsort 10G --merge -u -t\; -k1b,2 <(zcat /da4_data/basemaps/gz/b2cFullF$j.s) <(zcat /da4_data/update/Inc20180510.b2c.$j.s) |
     gzip > /data/basemaps/gz/b2cFullH$j.s
   zcat /data/basemaps/gz/b2cFullH$j.s | awk -F\; '{print $1";;"$2}'| /da3_data/lookup/Cmt2BlobBin.perl /da4_data/basemaps/b2cFullH.$j.tch 1 
done

#finally invert c2f to f2c and b2c to c2b
for i in {0..7}; do 
  gunzip -c /da4_data/update/Inc20180510.c2f.$i.s
done | perl -I /da3_data/lookup -I ~/lib64/perl5 -ane 'use cmt;@x=split(/\;/);next if defined $badCmt{$x[0]}; print;' |\
  awk -F\; '{print $2";"$1}' | /da3_data/lookup/splitSecCh.perl Inc20180213.f2c. 8 &

for i in {0..7}; do zcat /da4_data/update/Inc20180510.c2f.$i.s; done | perl -I /da3_data/lookup -I ~/lib64/perl5 \
   -ane 'use cmt;s|;/|;|;@x=split(/\;/);next if defined $badCmt{$x[0]}; print;' | \
   awk -F\; '{print $2";"$1}' | /da3_data/lookup/splitSecCh.perl Inc20180510.f2c. 8 &
for i in {0..7}; do   lsort 30G --merge -u -t\; -k1b,2 <(zcat Inc20180510.f2c.$i.gz|lsort 5G -u  -t\; -k1b,2) \
      <(zcat /da4_data/basemaps/gz/f2cFullF$i.s) | \
    gzip > f2cFullH$i.s
    gunzip -c f2cFullH$i.s | awk -F\; '{print $2";"$1}' | /da3_data/lookup/File2CmtBin.perl f2cFullH.$i.tch 1 
done

for i in {0..15}; do gunzip -c /da4_data/basemaps/gz/b2cFullH$i.s; done | perl -I /da3_data/lookup -I ~/lib64/perl5 \
   -ane 'use cmt;@x=split(/\;/);next if defined $badCmt{$x[1]} || defined $badBlob{$x[0]}; print;' | \
  awk -F\; '{print $2";"$1}' | /da3_data/lookup/splitSec.perl c2bFullH 16
for i in {0..15}; do gunzip -c c2bFullH$i.gz | awk -F\; '{print $1";;"$2}'| /da3_data/lookup/Cmt2BlobBin.perl c2bFullH.$i.tch 1
done

```

1. Update various maps
```
cd /data/basemaps
/da3_data/lookup/Auth2File.perl Auth2CmtH.tch /fast1/All.sha1c/c2fFullH Auth2FileH.tch 

#the following is slow: needs > 250G of ram
/da3_data/lookup/Cmt2Par.perl /data/basemaps/Cmt2Chld.tch

ls -l /da4_data/basemaps/{Auth2Cmt,Cmt2Chld,Auth2File}.tch

## Cmt2Blob.sh Blob to commit and inverse

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
ls -l /da4_data/basemaps/gz/Cmt2PrjH*.s
ls -l /da4_data/basemaps/Cmt2PrjH.*.tch
ls -l /da4_data/basemaps/gz/Prj2CmtH*.s
```



1. Historic stuff below

```
# 20180213
for i in CRAN cve secure js with withFrk withWch
do gunzip -c $i/*.olist*.gz| cut -d\; -f1-3 | grep ';commit;' |\
   sed 's/;commit;/;/;s|/*;|;|;s|\.git;|;|;s|/*;|;|'  | \
   perl -ane 'chop();($p,$c)=split(/\;/,$_,-1);next if $c !~ m/^[a-f0-9]{40}$/; $p=~s/.*github.com_(.*_.*)/$1/;$p=~s/^bitbucket.org_/bb_/;$p=~s|\.git$||;$p=~s|/*$||;$p=~s/\;/SEMICOLON/g;$p = "EMPTY" if $p eq "";print "$c;$p\n";'\
   | lsort 20G -t\; -k1b,2 -u | gzip > $i/c2p.$i.gz 
done
lsort 10G -t\; -k1b,2 -u --merge <(gunzip -c CRAN/c2p.CRAN.gz)  <(gunzip -c secure/c2p.secure.gz) <(gunzip -c cve/c2p.cve.gz) <(gunzip -c js/c2p.js.gz) | /da3_data/lookup/splitSec.perl Inc20180213.c2p. 8


#debug: look for missing commits/trees

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

## f2b.md
describes mapping between trees/blobs and file/folder names. It
oprates off blob/tree/commit objects. The remaining maps utilize
c2fbp map split into 80 (1B line) chunks (see below).

# Update commit message map
```
cd /da3_data/delta
/da3_data/lookup/lstCmt.perl 1 | gzip > /da3_data/delta/cmt.lst


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




