# Available maps/tables and their locations 
The tch are on da0:/data/basemaps/
The flat files are on da0:/data/basemaps/gz


The last letter denotes version (in alphabetical order)
Currently the last version is M

Notation in database names:
```
a - author
c - commit (cc - child commit)
f - file
b - blob
p - project (P - after fork normaliation)
t - time 
m - module


Full - means a complete set at that version

N - 0-31: the databasebased on prehash
```

1. author2commit: a2cFullM.N.tch
Grab a list of authors
```
echo "Audris Mockus <audris@utk.edu>" | /da3_data/lookup/Prj2CmtShow.perl /da0_data/basemaps/a2cFullM 1 32
```
2. author2file: a2fFullM.N.tch, tese are files for blobs created or deeted by the commit (see 6) - need to calculate for version M
```
echo "Audris Mockus <audris@utk.edu>" | /da3_data/lookup/Prj2FileShow.perl /da0_data/basemaps/a2fFullM.tch 1 32
```

3. blob2commit: b2cFullM.{0..31}.tch
```
echo 05fe634ca4c8386349ac519f899145c75fff4169 | /da3_data/lookup/Cmt2BlobShow.perl /da0_data/basemaps/b2cFullF 1 32
```

4. commit2blob: c2bFullF.{0..15}.tch  # need fix
```
echo e4af89166a17785c1d741b8b1d5775f3223f510f | /da3_data/lookup/Cmt2BlobShow.perl /data/basemaps/c2bFullF 1 32
```

5. commit2project: c2pFullM.{0..31}.tch 
```
echo e4af89166a17785c1d741b8b1d5775f3223f510f |/da3_data/lookup/Cmt2PrjShow.perl /da0_data/basemaps/c2pFullM 1 32
```

6. file2commit: f2cFullM.{0..31}.tch, tese are files for blobs created or deeted by the commit
```
echo main.c |/da3_data/lookup/Prj2CmtShow.perl /d0_data/basemaps/f2cFullF 1 8
```

7. project2commit: p2cFullM.{0..31}.tch
```
echo ArtiiQ_PocketMine-MP |/da3_data/lookup/Prj2CmtShow.perl /da0_data/basemaps/p2cFullM 1 32
```
8. Commit to child commit /da0_data/basemapsc2ccM.{0..31}.s
9. Commit to time+author: /da0_data/basemapsc2taFullM{0..31}.s
10. The extent of usage databases: for Go language in /da4_data/play/GothruMaps/m2nPMGo.s mo
Details for PY, for example, are in c2bPtaPkgMPY.{0..31}.gz
also on /lustre/haven/user/audris/basemaps
see grepNew.pbs for exact details.

## How to see a content of a commit
```
echo e4af89166a17785c1d741b8b1d5775f3223f510f | perl ~audris/bin/showCmt.perl [parameter]
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
# 201813
for r in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1
do cd $r 
  time ls -f *.tag.bin | /da3_data/lookup/AllUpdateObj.perl tag
  time ls -f *.commit.bin | /da3_data/lookup/AllUpdateObj.perl commit
  time ls -f *.tree.bin | /da3_data/lookup/AllUpdateObj.perl tree
  time ls -f *.blob.bin |  /da3_data/lookup/AllUpdateObj.perl blob
  cd ..
done

for r in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1
do cd /data/update/$r
   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /da0_data/basemaps/p2cFullK 32 ../p2cL 32 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | /da3_data/lookup/splitSec.perl c2p. 32
   zcat p2c.s | /da3_data/lookup/splitSecCh.perl p2c. 32   
   zcat c2p.s | cut -d\; -f1 | uniq | ~/bin/hasObj1.perl commit | gzip > cs.gz1
   cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs.gz
done

for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1; do str="$str <(zcat $i/p2c.$j.gz)"; done; eval $str | gzip > p2cM$j.s; done &
for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1; do str="$str <(zcat $i/c2p.$j.gz)"; done; eval $str | gzip > c2pM$j.s; done &
wait
cd /data/update/c2fb
zcat ../{BB.02,L.BB.03,L.18,L.19,L.20,L.21,L.22,L.23,L.24,L.GL.0,L.GL.1,L.SF,L.SF.1}/cs.gz | lsort 100G -u | ~/lookup/splitSec.perl s9. 32
for i in {0..15..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {1..15..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {2..15..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {3..15..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&

for i in {16..31..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {17..31..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {18..31..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {19..31..4}; do zcat s9.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
#do empty commit stuff

#this is comprehensive and quite fast 
ver=M
for j in {0..31}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFull$ver$j.s & done
wait
for j in {32..63}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFull$ver$j.s & done
wait
for j in {64..95}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFull$ver$j.s & done
wait
for j in {96..127}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFull$ver$j.s & done
wait
for j in {0..31}; do zcat c2taFull$ver$j.s | lsort 50G -t\; -k1b,2 --merge - <(zcat c2taFull$ver$(($j+32)).s) <(zcat c2taFull$ver$(($j+64)).s) <(zcat c2taFull$ver$(($j+96)).s) | gzip > c2taF$ver.$j.s; done 

for j in {0..31}; do zcat c2taFull$ver$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFull$ver$j.s & done
wait
for j in {32..63}; do zcat c2taFull$ver$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFull$ver$j.s & done
wait
for j in {64..95}; do zcat c2taFull$ver$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFull$ver$j.s & done
wait
for j in {96..127}; do zcat c2taFull$ver$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFull$ver$j.s & done
wait
str="$HOME/bin/lsort 50G -u --merge -t\; -k1b,2"
for j in {0..127}; do str="$str <(zcat a2cFull$ver$j.s)"; done
eval $str | perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/splitSecCh.perl a2cFull$ver 32
for j in {0..31..4}; do zcat a2cFull$ver$j.gz |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &
for j in {1..31..4}; do zcat a2cFull$ver$j.gz |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &
for j in {2..31..4}; do zcat a2cFull$ver$j.gz |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &
for j in {3..31..4}; do zcat a2cFull$ver$j.gz |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &

for i in {0..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl c2ccM $i | gzip > cnpM.$i; done &
for i in {1..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl c2ccM $i | gzip > cnpM.$i; done &
for i in {2..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl c2ccM $i | gzip > cnpM.$i; done &
for i in {3..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl c2ccM $i | gzip > cnpM.$i; done &


for j in {0..31..4}; do zcat c2pFullM$j.s | join -t\; - <(zcat c2taFM.$j.s) | awk -F\; '{ print $4";"$2}' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1b,2 -u | gzip > a2pM$j.s; done &
for j in {0..31}; do zcat a2pM$j.s | perl -I$HOME/lookup -I $HOME/lib/perl5 $HOME/lookup/splitSecCh.perl a2pM.$j. 32 & done
for j in {0..31}; do str="$HOME/bin/lsort ${maxM}M -t\; -k1b,2 --merge -u";   for i in {0..31};   do  str="$str <(zcat a2pM.$i.$j.gz)";   done;   eval $str > a2pM.$j.gz; done

for j in {0..31}; do zcat a2pM$j.s |  awk -F\; '{ print $2";"$1}' | perl -I$HOME/lookup -I $HOME/lib/perl5 $HOME/lookup/splitSecCh.perl p2aM.$j. 32 & done
wait
for j in {0..31}; do for i in {0..31};   do $HOME/bin/lsort ${maxM}M -t\; -k1b,2 <(zcat p2aM.$i.$j.gz) | gzip > p2aM.$i.$j.s &   done;   wait; done
for j in {0..31}; do str="lsort 8G -t\; -k1b,2 -u --merge"; for i in {0..31}; do str="$str <(zcat p2aM.$i.$j.s)"; done; eval $str | gzip > p2aM$j.s & done

for j in {0..31}; do zcat a2pM$j.s |  perl ~/lookup/mp.perl 1 c2pFullM.forks | lsort 30G -t\; -k1b,2 -u | gzip > a2PM$j.s; done

for j in {0..31}; do zcat p2aM$j.s |  perl ~/lookup/mp.perl 0 c2pFullM.forks | perl -I$HOME/lookup -I $HOME/lib/perl5 $HOME/lookup/splitSecCh.perl P2aM.$j. 32; done
for j in {0..31}; do for i in {0..31};   do $HOME/bin/lsort ${maxM}M -t\; -k1b,2 <(zcat P2aM.$i.$j.gz) | gzip > P2aM.$i.$j.s &   done;   wait; done
for j in {0..31}; do str="lsort 8G -t\; -k1b,2 -u --merge"; for i in {0..31}; do str="$str <(zcat P2aM.$i.$j.s)"; done; eval $str | gzip > P2aM$j.s & done


# 201812
cd /da0_data/head201812/

#get all repos from bb+gh+gl+sf - grab container run.sh
#get all the heads - libgit2 container
grep -v '^/' ghReposList201812.nofork.$i | awk '{print "https://github.com/"$0}' | ~/bin/get_last 2> ghReposList201812.nofork.$i.err | gzip > ghReposList201812.nofork.$i.heads &
grep -v '^/' bbList201812.$j | awk '{print "https://bitbucket.org/"$0}' | ~/bin/get_last 2> bbList201812.00.err | gzip > bbList201812.$j.heads
#get updates on da4
zcat ghReposList201812.nofork.$j.heads | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ~/bin/hasObj1.perl commit | cut -d\; -f3 | uniq | gzip > ghReposList201812.nofork.$j.update
zcat bbList201812.$j.heads | grep -v 'could not connect' | perl -ane 'chop(); ($u, @h) = split (/\;/, $_, -1); for $h0 (@h){print "$h0;$#h;$u\n" if $h0=~m|^[0-f]{40}$|}' | ~/bin/hasObj1.perl commit | cut -d\; -f3 | uniq | gzip > bbList201812.$j.update
#retrieve repos on NICS
L.{00..15}
bb?
for i in {00..17} 
do cd /data/update/L.$i
   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /da0_data/basemaps/p2cFullJK 32 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | /da3_data/lookup/splitSec.perl c2p. 32
   zcat p2c.s | /da3_data/lookup/splitSecCh.perl p2c. 32   
   zcat c2p.s | cut -d\; -f1 | uniq | ~/bin/hasObj1.perl commit | gzip > cs.gz1
   cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs.gz
done

for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in $(ls -fd L.[01][0-9] BB.00 BB.01); do str="$str <(zcat $i/p2c.$j.gz)"; done; eval $str | gzip > p2cL$j.s; done &
for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in $(ls -fd L.[01][0-9] BB.00 BB.01); do str="$str <(zcat $i/c2p.$j.gz)"; done; eval $str | gzip > c2pL$j.s; done &


cd ../c2fb
zcat ../L.0[0-5]/cs.gz | lsort 100G -u | ~/lookup/splitSec.perl s8a. 32

zcat ../L.{0[6-9],1[0-7]}/cs.gz | lsort 100G -u | ~/lookup/splitSec.perl s8b. 32
for i in {00..31}
do zcat s8a.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s8a.new.$i.err | gzip > s8a.$i.c2fb
   zcat s8b.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s8b.new.$i.err | gzip > s8b.$i.c2fb
   zcat s8c.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s8c.new.$i.err | gzip > s8c.$i.c2fb
   zcat s8d.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> s8d.new.$i.err | gzip > s8d.$i.c2fb
done
#do empty commit stuff
for i in {0..31}
do zcat s8[abcd].$i.gz |lsort 20G -u| gzip > aa1.$i.gz
   zcat s8[abcd].$i.c2fb | cut -d\; -f1 | uniq |lsort 20G -u| gzip > aa2.$i.gz
   zcat aa1.$i.gz | join -v1 - <(zcat aa2.$i.gz) | gzip > aa3.$i.gz
   zcat aa3.$i.gz| ~/lookup/cmputeDiff2.perl 2> err.$i
   cat err.$i | grep '^ident' | sed 's/.* for //;s/ .*//' | lsort 10G -u  | gzip > s8.$i.nochange
   cat err.$i | grep -v '^ident' |grep -v ^mdir | sed 's/.* for //;s/ .*//' | lsort 10G -u  | gzip > s8.$i.bad   
done
for i in {0..31}
do lsort 50G -u --merge <(zcat /da0_data/basemaps/gz/badcs.$i.gz) <(zcat s8.$i.bad) | gzip > /da0_data/basemaps/gz/badcsL.$i.gz
  lsort 70G -u --merge <(zcat /da0_data/basemaps/gz/emptycs.$i.gz) <(zcat s8.$i.nochange) | gzip > /da0_data/basemaps/gz/emptycsL.$i.gz
done

#this is comprehensive and quite fast 
for j in {0..31}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullL$j.s & done
wait
for j in {32..63}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullL$j.s & done
wait
for j in {64..95}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullL$j.s & done
wait
for j in {96..127}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullL$j.s & done
wait
for j in {0..31}; do zcat c2taFullL$j.s | lsort 85G -t\; -k1b,2 --merge - <(zcat c2taFullL$(($j+32)).s) <(zcat c2taFullL$(($j+64)).s) <(zcat c2taFullL$(($j+96)).s) | gzip > c2taFL.$j.s; done 

for j in {0..31}; do zcat c2taFullL$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullL$j.s & done
wait
for j in {32..63}; do zcat c2taFullL$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullL$j.s & done
wait
for j in {64..95}; do zcat c2taFullL$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullL$j.s & done
wait
for j in {96..127}; do zcat c2taFullL$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullL$j.s & done
wait
str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"
for j in {0..127}; do str="$str <(zcat a2cFullL$j.s)"; done
eval $str | ~/lookup/splitSecCh.perl a2cFullL 32
for j in {0..31..4}; do zcat a2cFullL$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullL.$j.tch; done &
for j in {1..31..4}; do zcat a2cFullL$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullL.$j.tch; done &
for j in {2..31..4}; do zcat a2cFullL$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullL.$j.tch; done &
for j in {3..31..4}; do zcat a2cFullL$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullL.$j.tch; done &

pVer=K
ver=L
LA=R
for j in {0..127}; do zcat b$pVer${LA}.$j.gz | lsort 1G -u | join -v2 - <(zcat b$ver$LA.$j.gz | lsort 1G -u) | gzip > b$ver$LA.$j.s1; done
for int in "{0..31}" "{32..63}" "{64..95}" "{96..127}" 
do for j in $(eval "echo $int"); do zcat b$ver${LA}.$j.s1 | ./b2pkgsFast${LA}.perl $j 2> /dev/null |gzip > b$ver${LA}pkgs.$j.s1 & 
done
wait
done
for j in {0..127}; do lsort 2G -t\; -k1b,2 <(zcat b$pVer${LA}pkgs.$j.gz) <(zcat b$ver${LA}pkgs.$j.s1) | gzip > b$ver${LA}pkgs.$j.gz1; done


#plot languages
for LA in JS java PY C php Lisp Rust Scala rb Swift Go Lua Sql Cs R F Cob
do zcat c2taK$LA.*.gz|awk -F\; '{print int($2/3600/24/365.25+1970)}' | lsort 10G | uniq -c > ${LA}K.trend
zcat c2taK$LA.*.gz|awk -F\; '{print int($2/3600/24/365.25+1970)";"$3}' | lsort 10G | uniq | cut -d\; -f1 | uniq -c > ${LA}K.trendA
done
s="year";for LA in JS java PY C php Lisp Rust Scala rb Swift Go Lua Sql Cs R F Cob; do s="$s;$LA";done; echo $s > cmtsK.lng
for y in {2010..2018}; do s="$y";for LA in JS java PY C php Lisp Rust Scala rb Swift Go Lua Sql Cs R F
do n=$(grep " $y$" ${LA}K.trend | awk '{print $1}'); s="$s;$n"; done; echo $s; done >> cmtsK.lng
s="year";for LA in JS java PY C php Lisp Rust Scala rb Swift Go Lua Sql Cs R F Cob; do s="$s;$LA";done; echo $s > cmtsK.lng1
for y in {2010..2018}; do s="$y";for LA in JS java PY C php Lisp Rust Scala rb Swift Go Lua Sql Cs R F
do n=$(grep " $y$" ${LA}K.trendA | awk '{print $1}'); s="$s;$n"; done; echo $s; done >> cmtsK.lng1
x=read.table("../../../cmts.lng1",sep=";",header=T)
png("trndA.png",width=1000,height=750);matplot(x[,1],x[,-1],type="o",lwd=1:3,lty=1:7,col=1:5,log="y",pch="0123456789abcdefghi",xlab="Years",ylab="Authors");off()
png("trndPrd.png",width=1000,height=750);
matplot(x[,1],y[,-1]/x[,-1],type="o",lwd=1:3,lty=1:7,col=1:5,log="y",pch="0123456789abcdefghi",xlab="Years",ylab="Cmghi");
dev.off()

#nost frequent reuse:
for LA in R C Cs Go Rust java; do  zcat m2nPK$LA |lsort 10G -rn -t\; -k2  | head -10 > m2npK$LA.10; done




#fix blob.bin,idx,vs
for i in {1..127..4}
do 
line=$(cut -d\; -f1 05.$i.f1)
off=$(cut -d\; -f2 05.$i.f1)
echo $i $line $off
mv /data/All.blobs/blob_$i.idx /data/All.blobs/blob_$i.idx2  
head -$line /data/All.blobs/blob_$i.idx2 > /data/All.blobs/blob_$i.idx
mv /data/All.blobs/blob_$i.vs /data/All.blobs/blob_$i.vs2
grep -v New201812L1.05 /data/All.blobs/blob_$i.vs2 | awk -F\; '{ if (NF==7) print $0 }' >  /data/All.blobs/blob_$i.vs
perl -e 'truncate "/data/All.blobs/blob_'$i'.bin", '$off';'
done


# 20181110
#see verify input below, 
#see Update da4:/data/All.blobs  below, 
#see Update All.sha1c commit and tree  below, 
for i in {00..13} 
do cd /data/update/updt.$i
   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /data/basemaps/p2cFullJ 32 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | /da3_data/lookup/splitSec.perl c2p. 32
   zcat p2c.s | /da3_data/lookup/splitSecCh.perl p2c. 32   
   cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs.gz
done
for i in {00..11} 
do cd /data/update/new.$i
   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /data/basemaps/p2cFullJ 32 ../p2cKb | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | /da3_data/lookup/splitSec.perl c2p. 32
   zcat p2c.s | /da3_data/lookup/splitSecCh.perl p2c. 32
   #extract commits from  c2p.$i.s next time 
   cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs.gz
done


for j in {0..31}; do str="$HOME/bin/lsort 12G -u --merge -t\; -k1b,2"; for i in $(ls -fd updt.[01][0-9]) new.00 new.01 new.02 new.03; do str="$str <(zcat $i/p2c.$j.gz)"; done; eval $str | gzip > p2cKa$j.s & done
for j in {0..31}; do str="$HOME/bin/lsort 12G -u --merge -t\; -k1b,2"; for i in $(ls -fd updt.[01][0-9]) new.00 new.01 new.02 new.03; do str="$str <(zcat $i/c2p.$j.gz)"; done; eval $str | gzip > c2pKa$j.s & done
#
for j in {0..31}; do str="$HOME/bin/lsort 12G -u --merge -t\; -k1b,2 <(zcat p2cKa$j.s)"; for i in $(ls -fd new.04 new.05 new.06); do str="$str <(zcat $i/p2c.$j.gz)"; done; eval $str | gzip > p2cKb$j.s & done
for j in {0..31}; do str="$HOME/bin/lsort 12G -u --merge -t\; -k1b,2 <(zcat c2pKa$j.s)"; for i in $(ls -fd new.04 new.05 new.06); do str="$str <(zcat $i/c2p.$j.gz)"; done; eval $str | gzip > c2pKb$j.s & done
# final
for j in {0..31}; do str="$HOME/bin/lsort 12G -u --merge -t\; -k1b,2 <(zcat p2cKb$j.s)"; for i in $(ls -fd new.07 new.08 new.09 new.10 new.11); do str="$str <(zcat $i/p2c.$j.gz)"; done; eval $str | gzip > p2cK$j.s & done
for j in {0..31}; do str="$HOME/bin/lsort 12G -u --merge -t\; -k1b,2 <(zcat c2pKb$j.s)"; for i in $(ls -fd new.07 new.08 new.09 new.10 new.11); do str="$str <(zcat $i/c2p.$j.gz)"; done; eval $str | gzip > c2pK$j.s & done


for j in {0..31}; do zcat p2cK$j.s | awk -F\; '{print $2";;;"$1}'| perl -I $HOME/lib/perl5 $HOME/lookup/Prj2CmtBin.perl p2cK.$j.tch 1; done


#start diff early
for i in {00..07}; do zcat updt.$i/cs.gz; done |  lsort 20G -u |gzip > cs.20181110.a
zcat /data/basemaps/cmts.s5 | lsort 10G -u --merge - <(zcat cs.20181110.a) | gzip > cmts.s6a
zcat /data/basemaps/cmts.s5 | join -v2 - <(zcat cs.20181110.a) | gzip > cmts.s6a.new
zcat cmts.s6a.new | split -l 2075511 -d -a 2 --filter='gzip > $FILE.gz' - /data/update/c2fb/cmts.s6a.new. 
cd /data/update/c2fb/
for i in {00..22}
do zcat cmts.s6a.new.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> cmts.s6a.new.$i.err | gzip > cmts.s6a.new.$i.c2fb
done
# See  Create c2fb below using cmts.s6a and Inc20181110
for i in updt.08 updt.09 updt.10 updt.11 updt.12 updt.13 new.00 new.01; do zcat $i/cs.gz; done |  lsort 20G -u |gzip > cs.20181110.b
zcat cmts.s6a | lsort 10G -u --merge - <(zcat cs.20181110.b) | gzip > cmts.s6b
zcat cmts.s6a | join -v2 - <(zcat cs.20181110.b) | gzip > cmts.s6b.new
zcat cmts.s6b.new | split -l 2075511 -d -a 2 --filter='gzip > $FILE.gz' - /data/update/c2fb/cmts.s6b.new. 
cd /data/update/c2fb/
for i in {00..22}
do zcat cmts.s6b.new.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> cmts.s6b.new.$i.err | gzip > cmts.s6b.new.$i.c2fb
done

for i in new.02 new.03 new.04 new.05 new.06; do zcat $i/cs.gz; done |  lsort 30G -u |gzip > cs.20181110.c
zcat cmts.s6b | lsort 100G -u --merge - <(zcat cs.20181110.c) | gzip > cmts.s6c &
zcat cmts.s6b | join -v2 - <(zcat cs.20181110.c) | gzip > cmts.s6c.new
zcat cmts.s6c.new | split -l 2075511 -d -a 2 --filter='gzip > $FILE.gz' - /data/update/c2fb/cmts.s6c.new. 

for i in new.07 new.08 new.09 new.10 new.11; do zcat $i/cs.gz; done |  lsort 20G -u |gzip > cs.20181110.d
zcat cmts.s6c | lsort 100G -u --merge - <(zcat cs.20181110.d) | gzip > cmts.s6 &
zcat cmts.s6c | join -v2 - <(zcat cs.20181110.d) | gzip > cmts.s6d.new
zcat cmts.s6d.new | split -l 2075511 -d -a 2 --filter='gzip > $FILE.gz' - /data/update/c2fb/cmts.s6d.new.
zcat cmts.s6 | ~/lookup/splitSec.perl cmts.s6. 32

#update old errors

zcat /da4_data/basemaps/gz/emptycs.* | ~/lookup/cmputeDiff2.perl 2> emptycs.err | gzip > emptycs.c2fb 
zcat /da4_data/basemaps/gz/badcs.* | ~/lookup/cmputeDiff2.perl 2> badcs.err | gzip > badcs.c2fb 

#extra commit from c2p

for i in {0..31}; do zcat cmts.s6.$i.gz | join -v2 - <(zcat /da0_data/basemaps/gz/c2pK$i.s|cut -d\; -f1|uniq) | ~/lookup/cmputeDiff2.perl 2> s6.p.$i.err | gzip > s6.p.$i.c2fb; done 
#extra commits that were in 00-81 database 
for i in {0..31}; do zcat cmts.s6.$i.gz | lsort 10G --merge -u - <(zcat /da0_data/basemaps/gz/c2pK$i.s|cut -d\; -f1|uniq) <(zcat c2fFullJ$i.s.extra.withCmt1 |cut -d\; -f1|uniq) | gzip > /da0_data/basemaps/gz/cmts.s6.$i.gz & done


cat s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no tree:' | grep -v 'for parent' | sed 's/.* for //;' | lsort 10G -u | gzip > s6.cnt &
cat s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no tree:' | grep 'for parent' | sed 's/.* for //;' | lsort 10G -u | gzip > s6.cnpt &
cat s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no parent commit: ' | sed 's/.* for //;' | lsort 10G -u  | gzip > s6.cnpc &
cat s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^nasty' | sed 's/^nasty test commit //;s/:.*//' | lsort 10G -u | gzip  > s6.cnasty &
cat s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no commit' | sed 's/.* for //;' | lsort 10G -u  | gzip > s6.cnoc &
cat s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^ident' | sed 's/.* for //;' | lsort 10G -u  | gzip > s6.cnochange &
zcat s6.{cnoc,cnasty,cnpc,cnpt,cnt} | lsort 5G -u | gzip > s6.badcs
zcat s6.cnochange | lsort 5G -u | gzip > s6.emptycs


#prep the remainder
zcat s6.p.*.c2fb s6.notExtr.*.c2fb badcs.c2fb emptycs.c2fb ../c2fFullJ*.s.extra.withCmt1 | perl -I ~/lookup -I ~/lib64/perl5 -ane 'use cmt; @x=split(/\;/); print "$_" if !defined $badCmt{$x[0]}' | sed 's|;/|;|' | ~/lookup/splitSec.perl s6e.c2f. 32


#do some cleaning
cd /lustre/haven/user/audris/basemaps
for j in {0..31}
do zcat cmts.s6.$j.s | join -v1 - <(zcat ../basemaps/csC2PK$j.s) | gzip > csNoP$j.s &
done
wait
for j in {0..31}
do zcat cmts.s6.$j.s | join -v1 - <(zcat csC2FK$j.s) | join -v1 - <(zcat emptycs.$j.gz) | join -v1 - <(zcat badcs.$j.gz) | \
     gzip > csNoF$j.s &
done
wait
for j in {0..31}
do zcat c2pFullK$j.s | grep ';EMPTY$' | cut -d\; -f1 | uniq | gzip > csC2EmptyPK$j.s & 
done
wait
for j in {0..31}
do zcat c2pFullK$j.s | cut -d\; -f1 | uniq | gzip > csC2PK$j.s &
done
wait
cd /lustre/haven/user/audris/c2fb
for j in {0..31}
do zcat c2bFullK$j.s | cut -d\; -f1 | uniq | gzip > csC2BK$j.s &
done
wait
for j in {0..31}
do zcat c2fFullK$j.s | cut -d\; -f1 | uniq | gzip > csC2FK$j.s &
done
wait


#use this to capture missing blobs
zcat csC2BK$j.s | join -v2 - <(zcat csC2FK$j.s) > fNoB$j

#Clean c2f: determine whats up with missuing commits

perl join.perl b2fFullJ$j.s /da0_data/c2fbp/b2f.s.$j.s | gzip > /data/update/b2fFullJ$j.s.extra #need to finish b2c


perl join.perl c2fFullJ$j.s /da0_data/c2fbp/c2f.s.$j.s | gzip > /data/update/c2fFullJ$j.s.extra
zcat c2fFullJ$i.s.extra | ~/bin/hasObj1.perl commit | gzip > c2fFullJ$i.s.extra.noCmt
zcat c2fFullJ$j.s.extra.noCmt|cut -d\; -f1 | uniq | join -t\; -v2 - <(zcat c2fFullJ$j.s.extra) | gzip > c2fFullJ$j.s.extra.withCmt
zcat c2fFullJ$j.s.extra.withCmt | cut -d\; -f1 | uniq | ~/lookup/cmputeDiff2.perl 2> /dev/null | gzip > c2fFullJ$j.s.extra.withCmt

# first cmts.s6 is missing some
for j in {0..31}
do $HOME/bin/lsort 6G --merge -u <(zcat ../basemaps/csC2PK$j.s) <(zcat ../basemaps/c2taFK.$j.s | cut -d\; -f1 | uniq) \
    <(zcat cmts.s6.$j.gz) | gzip > cmts.s6.$j.s
done
 
 
cat s6.p.*.err csNoF*.err s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no tree:' | grep -v 'for parent' | sed 's/.* for //;' | lsort 10G -u | gzip > s6.cnt &
cat s6.p.*.err csNoF*.err  s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no tree:' | grep 'for parent' | sed 's/.* for //;' | lsort 10G -u | gzip > s6.cnpt &
cat s6.p.*.err csNoF*.err  s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no parent commit: ' | sed 's/.* for //;' | lsort 10G -u  | gzip > s6.cnpc &
cat s6.p.*.err csNoF*.err  s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^nasty' | sed 's/^nasty test commit //;s/:.*//' | lsort 10G -u | gzip  > s6.cnasty &
cat s6.p.*.err csNoF*.err  s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^no commit' | sed 's/.* for //;' | lsort 10G -u  | gzip > s6.cnoc &
cat s6.p.*.err csNoF*.err  s6.notExtr.*.err badcs.err emptycs.err s6.p.*.err| grep '^ident' | sed 's/.* for //;' | lsort 10G -u  | gzip > s6.cnochange &
wait
zcat s6.{cnoc,cnasty,cnpc,cnpt,cnt} csNoF*.nc | lsort 5G -u | gzip > s6.badcs
zcat s6.cnochange | lsort 5G -u | gzip > s6.emptycs
zcat  s6.emptycs | ~/lookup/splitSec.perl /da0_data/basemaps/gz/emptycs. 32 &
zcat  s6.badcs | ~/lookup/splitSec.perl /da0_data/basemaps/gz/badcs. 32 &

for j in {0..31}; do (zcat /da0_data/basemaps/gz/cmts.s6.$j.s | join -v1 - <(zcat /da0_data/basemaps/gz/badcs.$j.gz) | join -v1 - <(zcat /da0_data/basemaps/gz/emptycs.$j.gz) | gzip > goodcs.$j.gz; zcat goodcs.$j.gz | join -v1 - <(zcat /da0_data/basemaps/gz/csC2FK$j.s) | gzip > restcs.$j.gz) & done
for j in {0..31} ; do zcat restcs.$j.gz | ~/lookup/cmputeDiff2.perl 2> restcs.$j.err | gzip > restcs.$j.c2fb & done
for i in {0..31}; do zcat /da0_data/basemaps/gz/emptycs.$i.gz | awk '{print $1}' | lsort 5G --merge -u - <(zcat restcs.$i.gz) | gzip > emptycs.$i.gz & done
for i in {0..31}; do scp -p emptycs.$i.gz da0:/data/basemaps/gz; done


###
# get author info

#for i in {0..31}; do zcat /da0_data/basemaps/gz/cmts.s6.$i.gz | join -v1 - <(zcat /data/basemaps/gz/cmts.s5.$i.gz); done | ~/lookup/splitSec.perl s6. 127
#for i in {0..63}; do zcat s6.$i.gz |~/lookup/showCmt.perl 2 $i | cut -d\; -f1-3 | gzip > c2atK$i.gz & done
#wait
#for i in {64..127}; do zcat s6.$i.gz |~/lookup/showCmt.perl 2 $i | cut -d\; -f1-3 | gzip > c2atK$i.gz & done
#wait

zcat c2atK*.gz | awk -F\; '{print $2 ";" $1}' | lsort 100G -t\; -k1b,2 | gzip > a2cK.gz
zcat /data/basemaps/gz/a2cJ.s | lsort 10G -t\; -k1b,2 --merge - <(zcat a2cK.gz) | gzip > a2cFullK.s
zcat a2cFullK.s|cut -d\; -f1 | uniq | wc -l

#this is comprehensive and quite fast 
for j in {0..31}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullK$j.s & done
wait
for j in {32..63}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullK$j.s & done
wait
for j in {64..95}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullK$j.s & done
wait
for j in {96..127}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 5G -t\; -k1b,2 | gzip > c2taFullK$j.s & done
wait
for j in {0..31}; do zcat c2taFullK$j.s | lsort 85G -t\; -k1b,2 --merge - <(zcat c2taFullK$(($j+32)).s) <(zcat c2taFullK$(($j+64)).s) <(zcat c2taFullK$(($j+96)).s) | gzip > c2taFK.$j.s; done 
for j in {0..31}; do zcat c2taFullK$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullK$j.s & done
wait
for j in {32..63}; do zcat c2taFullK$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullK$j.s & done
wait
for j in {64..95}; do zcat c2taFullK$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullK$j.s & done
wait
for j in {96..127}; do zcat c2taFullK$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cFullK$j.s & done
wait
str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"
for j in {0..127}; do str="$str <(zcat a2cFullK$j.s); done
eval $str | gzip > a2cFullK.s
zcat a2cFullK.s | ~/lookup/splitSecCh.perl a2cFullK 32
for j in {0..31..4}; do zcat a2cFullK$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullK.$j.tch; done &
for j in {1..31..4}; do zcat a2cFullK$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullK.$j.tch; done &
for j in {2..31..4}; do zcat a2cFullK$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullK.$j.tch; done &
for j in {3..31..4}; do zcat a2cFullK$j.gz |~/lookup/Prj2CmtBinSorted.perl a2cFullK.$j.tch; done &

#do a2f
# perhaps by joining?
for j in {0..31};do zcat c2taFK.$j.s | join -t\; - <(zcat /da0_data/basemaps/gz/c2fFullK$j.s) | cut -d\; -f3-4 | uniq | gzip > a2fK.$j.s; done 
for j in {0..31..4};do zcat a2fK.$j.s | lsort 30G -t\; -k1b,2 -u | gzip > a2fK.$j.s1; done 
for j in {1..31..4};do zcat a2fK.$j.s | lsort 30G -t\; -k1b,2 -u | gzip > a2fK.$j.s1; done 
for j in {2..31..4};do zcat a2fK.$j.s | lsort 30G -t\; -k1b,2 -u | gzip > a2fK.$j.s1; done 
for j in {3..31..4};do zcat a2fK.$j.s | lsort 30G -t\; -k1b,2 -u | gzip > a2fK.$j.s1; done 
str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"
for j in {0..31}; do str="$str <(zcat a2fK.$j.s1)"; done
eval $str | gzip > a2fFullK.s
zcat a2fFullK.s | ~/lookup/splitSecCh.perl a2fFullK 32

#perhaps a2c+c2f?


# see doFiles201812.pbs, tchNew201812.pbs for the latest approach, new split bi filename

#new split for projects
#PBS -N p2c
#PBS -A ACF-UTK0011
#PBS -l feature=monster
#PBS -l partition=monster
#PBS -l nodes=1,walltime=23:50:00
#PBS -j oe
#PBS -S /bin/bash
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH
c=/lustre/haven/user/audris/basemaps
cd $c
for j in {0..31}
do zcat c2pFullK$j.s | perl -ane 'print if m|^[0-f]{40};.|' | awk -F\; '{ print $2";"$1}' |\
   perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl p2cFullK.$j. 32 &
done
wait
for j in {0..31}
do for i in {0..31}
  do zcat p2cFullK.$i.$j.gz | $HOME/bin/lsort 20G -t\; -k1b,2 | gzip > p2cFullK.$i.$j.s &
  done
  wait
done
wait
for j in {0..31}
  do str="$HOME/bin/lsort 20G -t\; -k1b,2 --merge"
  for i in {0..31}
    do str="$str <(zcat p2cFullK.$i.$j.s)"
  done
  eval $str | gzip > p2cFullK.$j.s &
done
wait


#clean c2p/p2c
#zcat csC2FK$j.s | join -v2 - <(zcat ../basemaps/csC2PK0.s) > pNoF0

#find cs absent ps
for j in {0..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csNoP.$j.gz 4| cut -d\; -f4-6 > csNoP.$j.p & done
wait
for j in {1..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csNoP.$j.gz 4| cut -d\; -f4-6 > csNoP.$j.p & done
wait
for j in {2..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csNoP.$j.gz 4| cut -d\; -f4-6 > csNoP.$j.p & done
wait
for j in {3..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csNoP.$j.gz 4| cut -d\; -f4-6 > csNoP.$j.p & done
wait
for j in {0..31}; do cat csNoP.$j.p | lsort 20G -t\; -k1b,2 --merge - <(cat csNoP.$(($j+32)).p) <(cat csNoP.$(($j+64)).p) <(cat csNoP.$(($j+96)).p) | gzip > csNoP32.$j.p &done

#find cs with EMPTY ps
for j in {0..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csC2EmptyPK.$j.gz 4| cut -d\; -f4-6 > csC2EmptyPK.$j.p & done
wait
for j in {1..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csC2EmptyPK.$j.gz 4| cut -d\; -f4-6 > csC2EmptyPK.$j.p & done
wait
for j in {2..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csC2EmptyPK.$j.gz 4| cut -d\; -f4-6 > csC2EmptyPK.$j.p & done
wait
for j in {3..127..4}; do cat /data/All.blobs/commit_$j.vs | perl ~/bin/grepField.perl csC2EmptyPK.$j.gz 4| cut -d\; -f4-6 > csC2EmptyPK.$j.p & done
wait
for j in {0..31}; do cat csC2EmptyPK.$j.p | lsort 10G -t\; -k1b,2 --merge - <(cat csC2EmptyPK.$(($j+32)).p) <(cat csC2EmptyPK.$(($j+64)).p) <(cat csC2EmptyPK.$(($j+96)).p) |awk -F\; '{ print $1";"$3}' | sed 's|;github.com_|;|;s|\.git$||' | lsort 10G -t\; -k1b,2 -u - | gzip > csC2EmptyPK.$j.p &done


# get commits with no parents
~/lookup/Cmt2NPar.perl | gzip > /da0_data/basemaps/gz/nParK.gz



# 20180810
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



for j in {0..31}
zcat p2cFullJ$j.gz | awk -F\; '{print $2";;;"$1}'| perl -I $HOME/lib/perl5 $HOME/lookup/Prj2CmtBin.perl p2cFullI.$j.tch 1
#zcat c2pFullI$i.gz | awk -F\; '{print $1";;;"$2}'| perl -I $HOME/lib/perl5 $HOME/lookup/Cmt2PrjBinSorted.perl c2pFullI.$i.tch 1
zcat c2pFullJ$j.s | perl $HOME/lookup/connectExportPre.perl | gzip > c2pFullJ$j.p2p 
zcat c2pFullJ$j.p2p | awk '{print "id;"$0}' | perl $HOME/lookup/connectExportSrt.perl c2pFullJ$j
zcat c2pFullJ$j.versions | $HOME/lookup/connectPrune.perl  | gzip > c2pFullJ$j.versions1
zcat c2pFullJ$j.versions1 | $HOME/lookup/connect  | gzip > c2pFullJ$j.clones
perl $HOME/lookup/connectImport.perl c2pFullJ$j | gzip > c2pFullJ$j.map
done

zcat c2pFullJ*.map | perl $HOME/lookup/connectExportPre1.perl c2pFullJ
zcat c2pFullJ.versions |  ./connect | gzip > c2pFullJ.clones
perl connectImport.perl c2pFullJ | gzip > c2pFullJ.forks

i=withNthng
cd /data/update/$i
gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl p2cFullI 32 | gzip > p2c.gz
gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs
cd ../

(zcat withNthng/cs; cut -d\; -f4 withDnld/New2018withDnld1.{7[1-9],8[0-9]}*.commit.idx) | lsort 20G -u |gzip > cs.20180810
zcat /data/basemaps/cmts.s4 | lsort 10G -u --merge - <(zcat cs.20180810) | gzip > /data/basemaps/cmts.s5
zcat /data/basemaps/cmts.s4 | join -v2 - <(zcat cs.20180810) | gzip > /data/basemaps/cmts.s5.new
zcat /data/basemaps/cmts.s5.new | split -l 2075511 -d -a 2 --filter='gzip > $FILE.gz' - cmts.s5.new. 


# 20180710
for i in withDnld emr gl 
do cd /data/update/$i
   gunzip -c *.olist.gz | /da3_data/lookup/Prj2CmtChk.perl /data/basemaps/Prj2CmtH 8 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   cut -d\; -f4 *.commit.idx | lsort 20G -u > cs
done
cd ../
zcat {emr,gl,withDnld}/cs | lsort 50G -u | gzip > cs.20180710
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
gunzip -c a2c.s | ./Prj2CmtBinSorted.perl a2cFullI.tch

./lstCmt.perl -1  | gzip > c2t.gz

```
1. Create c2fb
```
cd /data/update/c2fb
#get full list of commits in the database
#c2f
for i in {00..41}
do zcat cmts.s5.new.$i.c2fb | \
perl -I $HOME/lib/perl5 -I $HOME/lookup -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' |\
$HOME/lookup/splitSec.perl Inc20180810.c2f.$i. 32 &
done
wait

for i in {00..41}
 do for j in {0..31}
 do zcat Inc20180810.c2f.$i.$j.gz | sed 's|;/|;|g'| $HOME/bin/lsort 1G -t\; -k1b,2 | gzip > Inc20180810.c2f.$i.$j.s &
 done
 wait
done
wait

for j in {0..31}
do str="$HOME/bin/lsort 3G -t\; -k1b,2 --merge"
 for i in {00..41}
   do str="$str <(zcat Inc20180810.c2f.$i.$j.s)"
 done
 eval $str | gzip > Inc20180810.c2f.$j.s &
done 
wait

for j in {0..31}
do $HOME/bin/lsort 3G -t\; -k1b,2 --merge <(zcat c2fFullI$j.s) <(zcat Inc20180810.c2f.$j.s|cut -d\; -f1,2) |gzip > c2fFullJ$j.s &
done

for j in {0..31}
do zcat Inc20180810.c2f.$j.s | cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | grep -v ';$'| \
   gzip > Inc20180810.c2b.$j.s &
done
wait

for j in {0..31}
do $HOME/bin/lsort 3G -t\; -k1b,2 --merge <(zcat c2bFullI$j.s) <(zcat Inc20180810.c2b.$j.s) |gzip > c2bFullJ$j.s &
done
wait

for i in {00..41}
do for j in {0..31}
 do zcat Inc20180810.c2f.$i.$j.gz
 done | cut -d\; -f1,2 | grep -v '^;'| grep -v '^$' | grep -v ';$'| \
awk -F\; '{ print $2";"$1}' | \
perl $HOME/bin/splitSecCh.perl Inc20180810.f2c.$i. 32 &
done 
wait

for i in {00..41}
 do for j in {0..31}
 do zcat Inc20180810.f2c.$i.$j.gz | $HOME/bin/lsort 1G -t\; -k1b,2 | gzip > Inc20180810.f2c.$i.$j.s &
 done
 wait
done
wait

for j in {0..31}
do str="$HOME/bin/lsort 3G -t\; -k1b,2 --merge"
 for i in {00..31}
   do str="$str <(zcat Inc20180810.f2c.$i.$j.s)"
 done
 eval $str | gzip > Inc20180810.f2c.$j.s &
done 
wait

for j in {0..31}
do $HOME/bin/lsort 3G -t\; -k1b,2 --merge <(zcat ff2cFullI$j.s) <(zcat Inc20180810.f2c.$j.s) |gzip > f2cFullJ$j.s &
done
wait

for i in {00..41}
do for j in {0..31}
 do zcat Inc20180810.c2f.$i.$j.gz
 done | cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | grep -v ';$'| \
awk -F\; '{ print $2";"$1}' | \
perl $HOME/bin/splitSec.perl Inc20180810.b2c.$i. 32 &
done
wait

for i in {00..41}
 do for j in {0..31}
 do zcat Inc20180810.b2c.$i.$j.gz | $HOME/bin/lsort 1G -t\; -k1b,2 | gzip > Inc20180810.b2c.$i.$j.s &
 done
 wait
done
wait

for j in {0..31}
do str="$HOME/bin/lsort 3G -t\; -k1b,2 --merge"
 for i in {00..41}
   do str="$str <(zcat Inc20180810.b2c.$i.$j.s)"
 done
 eval $str | gzip > Inc20180810.b2c.$j.s &
done 
wait

for j in {0..31}
do $HOME/bin/lsort 3G -t\; -k1b,2 --merge <(zcat b2cFullI$j.s) <(zcat Inc20180810.b2c.$j.s) |gzip > b2cFullJ$i.s &
done
wait


################
cd /data/update/c2fb
#get full list of commits in the database
#c2f
zcat cmts.s4.new.*.c2fb \
perl -I $HOME/lookup -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' |\
 /da3_data/lookup/splitSec.perl Inc20180710.c2f. 32

#J contains extra (see below)
for j in {0..31}; do 
  zcat Inc20180710.c2f.$j.gz |sed 's|;/|;|' | lsort 30G -t\; -k1b,2 | gzip > Inc20180710.c2f.$j.s
  lsort 10G --merge -u -t\; -k1b,2 <(zcat c2fFullJ$j.s) \ 
  <(zcat Inc20180710.c2f.$j.s| cut -d\; -f1,2 | uniq) | \
    gzip > c2fFullI$j.s
  zcat c2fFullI$j.s | /da3_data/lookup/Cmt2FileBinSorted.perl c2fFullI.$j.tch 1
done

#b2c 
zcat cmts.s4.new.*.c2fb | cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | 
  perl -I $HOME/lookup -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' |\
  awk -F\; '{ print $2";"$1}' | \
  perl $HOME/bin/splitSec.perl Inc20180710.b2c. 32
#fix missing blobs
zcat cmts.s.extra.c2fb.[0-7].gz |\
  cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | grep -v ';$'| \
  perl -I $HOME/lib64/perl5 -I $HOME/lookup/ -e 'use cmt; while(<STDIN>){ ($b, $c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' | \
  awk -F\; '{ print $2";"$1}' | \
  $HOME/bin/splitSec.perl cmts.s.extra.b2c. 32 
for j in {0..31}; do 
  zcat cmts.s.extra.b2c.$i.gz | $HOME/bin/lsort 1G -t\; -k1b,2 |gzip > cmts.s.extra.b2c.$i.s
  zcat Inc20180710.b2c.$j.gz | lsort 30G -t\; -k1b,2 | gzip > Inc20180710.b2c.$j.s
  lsort 10G --merge -u -t\; -k1b,2 <(zcat cmts.s.extra.b2c.$i.s) <(zcat b2cFullH$j.s) \ 
  <(zcat Inc20180710.b2c.$j.s) | \
    gzip > b2cFullI$j.s

#finally invert c2f to f2c and b2c to c2b
for i in {0..31}; do 
  gunzip -c c2fFullI.$i.s
done |  awk -F\; '{print $2";"$1}' | $HOME/lookup/splitSecCh.perl f2cFullI. 32 &
for i in {0..31}; do gunzip -c b2cFullI$i.s; done | \
perl -I $HOME/lookup | \
   -ane 'use cmt;@x=split(/\;/);next if defined $badBlob{$x[0]}; print;' | \
  awk -F\; '{print $2";"$1}' | $HOME/bin/splitSec.perl c2bFullI 32

for i in {0..32}; do gunzip -c c2bFullI$i.gz | awk -F\; '{print $1";;"$2}'| $HOME/lookup/Cmt2BlobBin.perl c2bFullI.$i.tch 1
done

#fix missing for c2f
(j=0; lsort 10G --merge -u -t\; -k1b,2 <(zcat /data/basemaps/gz/c2fFullH$j.s)  <(zcat /da3_data/update/c2fb/cmts.s.extra.c2fb.$j.gz| cut -d\; -f1,2 | sed 's|;/|;|') |perl -I ~/lib64/perl5/ -I /da3_data/lookup/ -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' | gzip > /data/basemaps/gz/c2fFullJ$j.s) &

##################################
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




