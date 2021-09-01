# Python APIs
are in github.com/ssc-oscar/oscar.py

Some rough info  on the structure and different update tasks is
below

# Available maps/tables and their locations 
The tch are on da0:/data/basemaps/
The flat files are on da0:/data/basemaps/gz


The last letter denotes version (in alphabetical order)
Currently 'P' is the latest version

Notation in database names:
```
a - author
c - commit (cc - child commit)
f - file
b - blob
p - project (P - after fork normalization)
t - time 
m - module
tr - torvalds index (For DRE)

Full - means a complete set at that version

N - 0-31: the database based on prehash
```


# Commands for Information Retrieval 

### 1. How to get a list of commits made by an author 
#### author2commit formatting: a2cFullP.{0..31}.tch
------------
```
This prints the total number of commit ID/Hash the author has made.

Command:
   * echo "git-commit-ID" | ~/lookup/getValues a2c

Examples: 
   * echo "Audris Mockus <audris@utk.edu>" | ~/lookup/getValues a2c
   * echo "Adam Tutko <atutko@vols.utk.edu>" | ~/lookup/getValues a2c

Output:
   Formatting: ;CommitId0;...
   Example: ;3ea51a41a5e6f85ce695d4ea56e789a10c9817e9;7c637bbfe419a71df5de89f358aeebf92a096129;
            c21fb159cd8fcb2c1674d353b0a0aaad1f7ed822;c2c65a39879bf443a430ba056ea892c51f0ff12d;
            d2ee19fffa494a1f75333c89c09fb2137444f203

```
-------------

### 2. How to get a list of files made by an author
#### author2file: a2fFullP.{0..31}.tch
------------
```
This prints the file names of blobs (files) created or deleted by an author's commit.

Command:
   * echo "git-commit-ID" | ~/lookup/getValues a2f
   
Examples:
   * echo "Audris Mockus <audris@utk.edu>" | ~/lookup/getValues a2f
   * echo "Adam Tutko <atutko@vols.utk.edu>" | ~/lookup/getValues a2f

Output:
   Formatting: ;FileNames
   Example: Adam Tutko <atutko@vols.utk.edu>;Adam Tutko <atutko@vols.utk.edu>;atutko.md;diffences.md;diffences.txt;proposal.md
   
```
-------------

### 3. How to get a list of commit-IDs associated with a Blob-ID 
#### blob2commit: b2cFullO.{0..31}.tch
------------
```
This prints out the commits associated with a file based on it's Blob-ID.

Command:
   * echo "Blob-ID" (no quotes) | ~/lookup/getValues b2c

Examples: 
   * echo 05fe634ca4c8386349ac519f899145c75fff4169 | ~/lookup/getValues b2c
   * echo a7081031fc8f4fea0d35dd8486f8900febd2347e | ~/lookup/getValues b2c

Output:
   Formatting: "Blob-ID";"Commit-IDs"
   Example: a7081031fc8f4fea0d35dd8486f8900febd2347e;415feccd753c7f974dd94725eaad1e98e3743375;
            7365d601788017bb065c960cde2235f8ced27082;fe1ce9e5e8ebe83569c53ebe1f05f0688136ef2c
   
```
------------

### 4. How to get a Blob-ID from a Commit-ID
#### commit2blob: c2bFullO.{0..31}.tch   
------------
```
This prints out the Blob-ID associated with the Commit-ID given. 

Command:
   * echo "Commit-ID" (no quotes) | ~/lookup/getValues c2b
   
Examples:
   * echo e4af89166a17785c1d741b8b1d5775f3223f510f | ~/lookup/getValues c2b
   * echo fe1ce9e5e8ebe83569c53ebe1f05f0688136ef2c | ~/lookup/getValues c2b

Output:
   Formatting: Blob-ID;Blob-ID
   Example: fe1ce9e5e8ebe83569c53ebe1f05f0688136ef2c;a7081031fc8f4fea0d35dd8486f8900febd2347e

```
-----------

### 5. How to get the project names associated with a Commit-ID
#### commit2project: c2pFullO.{0..31}.tch 
------------
```
This prints out the names of the projects assoicuated with the given Commit-ID.

Command:
   * echo "Commit-ID" (no quotes) | ~/lookup/getValues c2p
Examples:
   * echo e4af89166a17785c1d741b8b1d5775f3223f510f | ~/lookup/getValues c2p
   * echo fe1ce9e5e8ebe83569c53ebe1f05f0688136ef2c | ~/lookup/getValues c2p
   
Output: 
   Formatting: "Commit-ID";ProjectNames
   Example: e4af89166a17785c1d741b8b1d5775f3223f510f;W4D3_news;chumekaboom_news;fdac15_news;
            fdac_syllabus;igorwiese_syllabus;jaredmichaelsmith_news;jking018_news;milanjpatel_news;
            rroper1_news;tapjdey_news;taurytang_syllabus;tennisjohn21_news
```
------------

### 6. How to get the Commit-IDs associated with a file
#### file2commit: f2cFullO.{0..31}.tch
-----------
```
This prints out the Commit-IDs associated with a file name.

Command:
   * echo "File Name" (no quotes) | ~/lookup/getValues f2c

Examples:
   * echo main.c | ~/lookup/getValues f2c
   * echo atutko.md | ~/lookup/getValues f2c
   
Output:
   Formatting: "File Name";Commit-IDs
   Example: atutko.md;0a26e5acd9444f97f1a9e903117d957772a59c1d;3fc5c3db76306440a43460ab0fb52b27a01a2ab9;
            6176db8cb561292c5f0fdcd7d52eb3f1bca23b36;c21fb159cd8fcb2c1674d353b0a0aaad1f7ed822;
            c9ec77f6434319f9f9c417cf7f9c95ff64540223
            
```
------------

### 7. How to get the Commit-IDs associated with a project
#### project2commit: p2cFullP.{0..31}.tch  
------------
```
This print out the Commit-IDs associated with a project name.

Command:
   * echo "Project Name" (no quotes) | ~/lookup/getValues p2c 
   
Examples:
   * echo ArtiiQ_PocketMine-MP | ~/lookup/getValues p2c 
   
Output: 
   Formatting: "Project Name";Commit-IDs
   Example: ArtiiQ_PocketMine-MP;0000000bab11354f9a759332065be5f066c3398f;000a0dedd9364072cb0e64bc48f1fba82c9fba65;
   000ba5de528b3ea9680124f4fbe670867eafd2f8;000dfc860134262a46d8942a3c3b453528d99da9;.......
   
```
------------

### 8. How to get the Child-Commit-IDs associated with a Commit-ID
#### Commit2ChildCommit: /da0_data/basemaps/c2ccO.{0..31}.s
-----------
```
This prints the Child-Commit-ID of a given Commit-ID.

Command:
   * echo "Commit-ID" (no quotes) | ~/lookup/getValues c2cc
   
Examples:
   * echo e4af89166a17785c1d741b8b1d5775f3223f510f | ~/lookup/getValues c2cc
   * echo fe1ce9e5e8ebe83569c53ebe1f05f0688136ef2c | ~/lookup/getValues c2cc

Output:
   Formatting: "Commit-ID";"Child-Commit-ID"
   Example: fe1ce9e5e8ebe83569c53ebe1f05f0688136ef2c;65d49eee6fb6f0fa1d3a69af14ae43311da54907
   
```
----------

### 9. How to get the exact .tch file a Blob-ID, Commit-ID, or Tree-ID is located in
-----------
```
This prints the file number of the .tch file associated with the passed ID.

Command:
   * echo "Blob, Commit, or Tree-ID" (no quotes) | ~/lookup/splitSec.perl a 32 1

Examples: 
   Commit-IDs:
      * echo 000000000001b58ef4d6727f61f4d7f8625feb72 | ~/lookup/splitSec.perl a 32 1
      * echo e4af89166a17785c1d741b8b1d5775f3223f510f | /da3_data/lookup/splitSec.perl a 32 1
   Tree-IDs:
      * echo f1b66dcca490b5c4455af319bc961a34f69c72c2 | ~/lookup/splitSec.perl a 32 1
      * echo 0f8d572eb262b0510788d3ee7445099a256be5cb | ~/lookup/splitSec.perl a 32 1
   Blob-IDs:
      * echo 05fe634ca4c8386349ac519f899145c75fff4169 | ~/lookup/splitSec.perl a 32 1
      * echo a7081031fc8f4fea0d35dd8486f8900febd2347e | ~/lookup/splitSec.perl a 32 1

Output:
   Formatting: #of.tchfile;ID
   Output: 5;05fe634ca4c8386349ac519f899145c75fff4169
   
   
```
------------

### 10. How to get the Author and Time from Commit-ID
#### Commit to time+author: /da0_data/basemaps/c2taFullP.{0..31}.s
-----------
```
This command prints out the Author and Time of a commit based on Commit-ID.

This command requires you to know the exact .tch file that will be used to pull the information.
In order to get the number of the .tch file, run command 9. The output will resemble 4;e4af89166a17785c1d741b8b1d5775f3223f510f.
Take the number before the ( ; ) and replace the #oftchfile in "da0_data/basemaps/c2taFullP.#oftchfile.tch".

Command:
   * echo "Commit-ID" (no quotes) | ~/lookup/getValues c2ta

Examples:
   * echo 000000000001b58ef4d6727f61f4d7f8625feb72 | ~/lookup/getValues c2ta
   * echo e4af89166a17785c1d741b8b1d5775f3223f510f | ~/lookup/getValues c2ta
   
Output:
   Formatting: "Commit-ID";UnixTimestamp;"Author-ID"
   Example: e4af89166a17785c1d741b8b1d5775f3223f510f;1410029988;Audris Mockus <audris@utk.edu>


```
------------

### 11. How to determine what code dependencies are in a Blob
#### The extent of usage databases: for Go language in /da0_data/play/GothruMaps/m2nPMGo.s mo
----------
```
These are summaries that specify the specific language dependencies a blob has.
For example, for Python a file that has the statement "import pandas" will specify that the Blob depends on pandas in c2bPta.

Details for PY, for example, are in c2bPtaPkgOPY.{0..31}.gz
also on /lustre/haven/user/audris/basemaps
see grepNew.pbs for exact details.

```
-----------

### 12. How to see the content of a Commit-ID
----------
```
This command prints out the content of a given Commit-ID.

This command has an additional optional paremter that can be added to change the formatting of the output. 

This command can only be run on servers with SSDS. To run this command, use the da4 server.

Command:
   * echo "Commit-ID" (no quotes) | ~/lookup/showCnt commit

Examples:
      * echo e4af89166a17785c1d741b8b1d5775f3223f510f | ~/lookup/showCnt commit
      * echo fe1ce9e5e8ebe83569c53ebe1f05f0688136ef2c | ~/lookup/showCnt commit

Output:
   Formatting:
      No Formatting Parameter: 
         * "Commit-ID";"Tree-ID";"Parent-ID";"Author";"Committer";"Author Time";"Comitter Time"
      Parameter 1: 
         * "Commit-ID";"Commit Time No TZ";"Comitter"
      Parameter 2: 
         * "Commit-ID";"Comitter";"Commit Time";"Commit Message"
      Parameter 3: 
         * tree "Tree-ID"
           parent "Parent-ID"
           author "Author-ID"
           committer "Committer-ID"
                    
           "Commit Message"
           "Commit Message";"Commit-ID"
      Parameter 4:
         * "Commit-ID";"Comitter"
      Parameter 5:
         * "Commit-ID";"Parent-ID"
      Parameter 6:
         * "Commit-ID";"Commit Time No TZ";"Comitter";"Tree-ID";"Parent-ID"
      
   Examples:
      * No Formatting: 
         * e4af89166a17785c1d741b8b1d5775f3223f510f;f1b66dcca490b5c4455af319bc961a34f69c72c2;c19ff598808b181f1ab2383ff0214520cb3ec659;Audris Mockus <audris@utk.edu>;Audris Mockus <audris@utk.edu>;1410029988 -0400;1410029988 -0400
      * Parameter 1: 
         * e4af89166a17785c1d741b8b1d5775f3223f510f;1410029988;Audris Mockus <audris@utk.edu>
      * Parameter 2: 
         * e4af89166a17785c1d741b8b1d5775f3223f510f;Audris Mockus <audris@utk.edu>;1410029988 -0400;News for Sep 5
      * Parameter 3: 
         *  tree f1b66dcca490b5c4455af319bc961a34f69c72c2
            parent c19ff598808b181f1ab2383ff0214520cb3ec659
            author Audris Mockus <audris@utk.edu> 1410029988 -0400
            committer Audris Mockus <audris@utk.edu> 1410029988 -0400

            News for Sep 5
      * Parameter 4: 
         * e4af89166a17785c1d741b8b1d5775f3223f510f;Audris Mockus <audris@utk.edu>
      * Parameter 5:
         * e4af89166a17785c1d741b8b1d5775f3223f510f;c19ff598808b181f1ab2383ff0214520cb3ec659
      * Parameter 6:  
         * e4af89166a17785c1d741b8b1d5775f3223f510f;1410029988;Audris Mockus <audris@utk.edu>;f1b66dcca490b5c4455af319bc961a34f69c72c2;c19ff598808b181f1ab2383ff0214520cb3ec659
```
------------

### 13. How to see the content of a Tree-ID
---------
```
This command prints out the Blob-IDs and File Names of a given Tree-ID.

Command:
   * echo "Tree-ID" (no quotes) | ~/lookup/showCnt tree

Examples:
   * echo f1b66dcca490b5c4455af319bc961a34f69c72c2 | ~/lookup/showCnt tree
   * echo 0f8d572eb262b0510788d3ee7445099a256be5cb | ~/lookup/showCnt tree
   
Output:
   Formatting: "Mode";"Blob-ID";"FileName"
   Example: 100644;05fe634ca4c8386349ac519f899145c75fff4169;README.md
            100644;dfcd0359bfb5140b096f69d5fad3c7066f101389;course.pdf

```
----------

### 14. How to see the content of a Blob-ID 

-----------
```
This command prints out the content of a giver Blob-ID.

Command:
   * echo "Blob-ID" (no quotes) | ~/lookup/showCnt blob

Examples:
   * echo 05fe634ca4c8386349ac519f899145c75fff4169 | ~/lookup/showCnt blob
   * echo a7081031fc8f4fea0d35dd8486f8900febd2347e | ~/lookup/showCnt blob
   
Output:
   Formatting:
      No Formatting Parameter: 
         * "Content of the blob"
      Parameter 1:
         * "Content of the blob with new lines replaced with \n"
   Examples:
      No Formatting Parameter: 
         * # Syllabus for "Fundamentals of Digital Archeology"
            ## News
               * Assignment1 due Monday Sep 8 before 2:30PM
               * Be ready to present your findings from Assignment1 on Monday
               * Project 1 teams are formed! You should see Team? where ? is 1-5 in your github page (on the right)
               * Lecture slides are at [Data Discovery](https://github.com/fdac/presentations/dd.pdf)
               * Sep 5 lecture recording failed as 323Link (host for the recording) went down
               ......
      Parameter 1:
         *  # Syllabus for "Fundamentals of Digital Archeology"\n\n## News\n\n* Assignment1 due Monday Sep 8 before 2:30PM\n* Be ready to present your findings from Assignment1 on Monday\n* Project 1 teams are formed! You should see Team? where ? is 1-5 in your github page (on the right)\n* Lecture slides are at [Data Discovery](https://github.com/fdac/presentations/dd.pdf)\n* Sep 5 lecture recording failed as 323Link (host for the recording) went down\n
   
```
-----------

# How to gather information
```
The below commands were all run on the da4 server due to SSDS requirements.


Run Command 2 to get a list of File Names made by an Author:
   echo "Adam Tutko <atutko@vols.utk.edu>" | ~/lookup/Prj2FileShow.perl /da0_data/basemaps/a2fFullO 1 32
Output: 
Adam Tutko <atutko@vols.utk.edu>;4;diffences.md;diffences.txt;proposal.md;atutko.md


Run Command 6 with one of the File Names to get Commit-IDs associated with the chosen File Name:
   echo atutko.md |~/lookup/Prj2CmtShow.perl /da0_data/basemaps/f2cFullO 1 32
Output: 
atutko.md;5;0a26e5acd9444f97f1a9e903117d957772a59c1d;3fc5c3db76306440a43460ab0fb52b27a01a2ab9;
6176db8cb561292c5f0fdcd7d52eb3f1bca23b36;c21fb159cd8fcb2c1674d353b0a0aaad1f7ed822;
c9ec77f6434319f9f9c417cf7f9c95ff64540223


Run Command 5 using any of the Commit-IDs to get the Project Name associated with the Commit:
   echo 0a26e5acd9444f97f1a9e903117d957772a59c1d | ~/lookup/Cmt2PrjShow.perl /da0_data/basemaps/c2pFullP 1 32
Output: 
0a26e5acd9444f97f1a9e903117d957772a59c1d;1;CS340-19_students


Run Command 12 to see the content of the Commit-ID:
   echo 0a26e5acd9444f97f1a9e903117d957772a59c1d | perl /home/audris/bin/showCmt.perl 2
Output:
tree 8bd497df9b762ac0be8be0850089b9f915b31c7a
parent fd422df135c11d927c9f54e656bc053879560092
parent 43ca88b1f0cd438377c6cf4168995add79d35ce8
author Audris Mockus <audris@utk.edu> 1550146565 -0500
committer GitHub <noreply@github.com> 1550146565 -0500
gpgsig -----BEGIN PGP SIGNATURE-----

wsBcBAABCAAQBQJcZVwFCRBK7hj4Ov3rIwAAdHIIAE92LDq5k8AZnTyG0qxOQifn
6PkW5hlfEdElM7WHKqkSnTPYtjIKGUeYdmycbUgtr19XwmoOIOORhnWtpdectK5/
TnC61rLaT8uN9k4w788zGaxKylCi+Bgw44XxXSGq+7B3a9Kru+6iLQU1ftwAGIwf
hXTs5WYKtAeKu/1dmx6+t7uyXc9QXnHF9as6BiAEndx97oZPpfIXdNffFa/JBPDb
Ci3s34CzNADshyJXPTv0zWLwWNwAzNtMyi1VhsWtcixCccbCW9oyHoBnRepSO3wQ
FuUVo9bRL6ysWkCS8qURh8pnJvcr+CtSfyFz48NfBQlV3PctXq4Wm2KukRv8i1o=
=cy8t
-----END PGP SIGNATURE-----

Merge branch 'master' into master
Merge branch 'master' into master;0a26e5acd9444f97f1a9e903117d957772a59c1d


```


##############################################

# Scripts to create various lookup tables

# Update process
1. select a sample of repos (da0:/data/github/YearlyUpdate.sh)

        i. the mongodb githb-ghReposList2017/repos for overview
        i. github-ghUsers17/repos for detail on 61454771 repos
        i. Out of 67579431 repos on GH ghReposList2017
        i. 39247534 are not forks ghReposList2017.nofork
        i. 9774023 not seen before list2017.u
        i. 1287830 repos with detail in bbList2017
1. clone repos in the list (break into 400Gb chunks based on size github.github-ghUsers17.repos.values.full_name.id.size.private.fork.forks.forks_count.watchers.watchers_count.stargazers_count.has_downloads.has_pages.open_issues.hompage.language.created_at.updated_at.pushed_at.default_branch.description)
1. extract olist.gz for each chunk
1. extract blobs, commits, trees, tags based on the olist (see beacon scripts below)
1. Extract c2p info from *.olist.gz, olist.gz is obtained first, then objects are extracted based on it


### Version S

- use gather/run2009.sh to discover repos
- use libgit2/handleOtherForges.sh to extract objects
- use beacon/gcp doS.sh/doS1.sh/doS1gcp.sh/run.pbs/run1.pbs to do massive cloning
- rsync back
```
(nn=74; cd ../S.$nn; rsync -av *.olist.gz list2020* New*.{commit,tag,tree,blob}.{idx,bin} *.err da1:/data/update/S.$nn/)
```
- check
```
(nn=78; cd ../S.${nn}; for t in tag commit tree;do ls -f  *$t.bin  | sed 's/\.bin$//' | while read i; do (echo $i; perl -I ~/lib64/perl5/ ~/lookup/checkBin1in.perl $t $i) &>> ../S.$nn.$t.err; done; done)
ls ../S.76/*.idx | sed 's|\.idx$||'| while read i; do ss=$(tail -1 $i.idx|cut -d\; -f1,2|sed 's|;|+|'|bc); res=$(($ss - $(stat -c '%s' $i.bin))); [[ $res != 0 ]] && echo $i; done
```
- add
```
for type in tag commit tree blob
do echo S.78 | while read r; do cd $r; ls -f *.$type.bin |  ~/lookup/AllUpdateObj.perl $type; cd /data/home/audris/update; done
done
```
- unusual sizes
```
ls S.78/New202*blob.idx | while read i; do awk -F\; '{ p[$5]+=$2} END {for (a in p){print a";"p[a]}}' $i; done |gzip > S.sizesb
ls S.78/New202*tree.idx | while read i; do awk -F\; '{ p[$5]+=$2} END {for (a in p){print a";"p[a]}}' $i; done |gzip> S.sizest
zcat S.sizesb |  awk -F\; '{print $1";"int($2) }'  | lsort 1G -t\; -k2 -rn | sed 's|^|"|;s|;|" => |;s|$|,|' | head -60
zcat S.sizest |  awk -F\; '{print $1";"int($2) }'  | lsort 1G -t\; -k2 -rn | sed 's|^|"|;s|;|" => |;s|$|,|' | head -60
```
create project link p2c
```
for nn in 79; do mkdir -p $ver.$nn; ssh da1 "cd /data/update/$ver.$nn;  zcat *.olist.gz | grep ';commit;' | sed 's|/;|;|;s|\.git;|;|'" | $HOME/lookup/Prj2CmtChk.perl /fast/p2cFullR 32 | lsort 60G -u -t\; -k1,2| gzip > $ver.$nn/New$DT.${ver}1.$nn.p2c; done
ls */*.p2c | cut -d/ -f1 | while read i; do rsync -av $i/*.p2c bb1:/da2_data/update/$i/; done
```

#on beacon update c2p/p2c to ${ver} (move to 128 databases for p2c/c2p
#lookup/updatePrj${ver}.pbs
#get forks sed "s/VER/${ver}/;s/MACHINE/monster/;s/=23/=23/" ~/lookup/fork.pbs | qsub

#create databases for c2p/p2c
for i in {0..31}; do zcat p2cFull$ver{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s | ~/lookup/s2hBinSorted.perl ../p2cFull$ver.$i.tch; done &
for i in {0..31}; do zcat c2pFull$ver{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s | ~/lookup/h2sBinSorted.perl ../c2pFull$ver.$i.tch; done &


- Update content
```
#backup existing tail
for t in blob commit tag tree; do for i in {0..127}; do tail -1 /data/All.blobs/${t}_$i.idx; done; done > /data/All.blobs.$ver
~/lookup/cnt.sh

for i in {0..127}; do time ~/lookup/Obj2ContUpdt.perl commit $i 2380392; done &
for i in {0..127}; do time ~/lookup/Obj2ContUpdt.perl tree $i 9336997; done &
for i in {0..127}; do ~/lookup/TreeN2Off.perl $i; done
for i in {0..127}; do ~/lookup/CmtN2Off.perl $i; done
--
for i in {0..127}; do ~/lookup/BlobN2Off.perl $i; done
```

new commits
```
cd c2fb
for i in {0..127}; do cut -d\; -f4 /data/All.blobs/commit_$i.idx| lsort 50G -u | join -v1 - <(ssh da4 'cut -d\; -f4 /data/All.blobs/commit_'$i'.idx' < /dev/null | lsort 50G -u) | gzip > RS$i.cs; done
--
for i in {0..127}; do time zcat RS$i.cs  | perl -I ~/lookup -I ~/lib64/perl5 ~/lookup/cmputeDiff3.perl 2> errRS.$i | gzip > RS$i.gz; done  &

(i=0;zcat RS$i.gz|perl -I $HOME/lib64/perl5 -I $HOME/lookup -e 'use cmt; while(<STDIN>){ chop (); s|;/|;|g; @r = split(/;/); $r[$#r] = "long" if $r[$#r] =~ / /&& length($r[$#r]) > 300; print "".(join ";", @r)."\n" if ! defined $badCmt{$r[0]};}' | lsort 5G | gzip > RS$i.s)

(i=0; lsort 3G -t\; -k1,1 --merge <(zcat c2fbbFullR$i.s) <(zcat RS$i.s) | gzip > c2fbbFullS$i.s) &
````

#on dad2 (also in c2ta.pbs)
#do Authors
```
ver=S
cd /store/cmts

for i in {0..31}; do sed "s|WHAT|c2dat|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub ; sleep 1; done

for i in {0..15}; do sed "s|WHAT|c2tasplit|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub ; sleep 1; done
for i in {0..7}; do sed "s|WHAT|a2cmerge|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub ; sleep 1; done
sed "s|WHAT|as|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub

for i in {0..15}; do sed "s|WHAT|pc2csplit|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub ; sleep 1; done
for i in {0..15}; do sed "s|WHAT|t2csplit|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub ; sleep 1; done

for i in {0..7}; do sed "s|WHAT|t2cmerge|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub ; sleep 1; done
for i in {0..7}; do sed "s|WHAT|c2ccmerge|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/c2ta.pbs  | qsub ; sleep 1; done


scp -p a$ver.s c2datFull${ver}{[0-9],[1-9][0-9],1[0-9][0-9]}.s {a2c,t2c,c2cc}Full${ver}{[0-9],[12][0-9],3[01]}.s da3:/data/basemaps/gz

# create databases a2c, c2ta, t2c, c2cc, c2pc

for j in {0..31}; do zcat a2cFull$ver$j.s | ~/lookup/s2hBinSorted.perl ../a2cFull$ver.$j.tch; done &
for i in {0..31}; do zcat c2datFull$ver$i.s c2datFull$ver$(($i+32)).s c2datFull$ver$(($i+64)).s c2datFull$ver$(($i+96)).s  | ~/lookup/Cmt2taBin.perl /fast/c2taFull$ver.$i.tch 1; done &
for i in {0..31}; do zcat t2cFull$ver$i.s | ~/lookup/h2hBinSorted.perl ../t2cFull$ver.$i.tch 1; done &

scp -p ../{a2c,t2c,c2ta}Full$ver.{[0-9],[1-3][0-9]}.tch da0:/data/basemaps/


# create from scratch
for j in {0..31}; do zcat c2ccFull$ver$j.s | ~/lookup/h2hBinSorted.perl ../c2ccFull$ver.$j.tch 0; done &
for j in {0..31}; do zcat c2datFull$ver$j.s c2datFull$ver$(($j+32)).s c2datFull$ver$(($j+64)).s c2datFull$ver$(($j+96)).s  | perl -ane 'chop();($c,$ti,$a,$t,$pp)=split(/;/,$_,-1);for $p (split(/:/,$pp,-1)){print "$c;$p\n" if $p=~/^[0-9a-f]{40}$/}'  | ~/lookup/h2hBinSorted.perl ../c2pcFull$ver.$j.tch 0; done &

# or update c2pc/c2cc
for i in {0..127}; do to=$(tail -1 /data/All.blobs/commit_$i.idx | cut -d\; -f1); fr=$(head -$((1+$i)) /data/All.commits.$pVer|tail -1| cut -d\; -f1); tail -$(($to-$fr+1)) /data/All.blobs/commit_$i.idx | ~/lookup/c2pc.perl /data/All.blobs/commit_$i.bin /fast/c2pcFullS.$((i%32)).tch; done # >> /data/cnpFull$pVer-$ver.$i
for i in {0..127}; do to=$(tail -1 /data/All.blobs/commit_$i.idx | cut -d\; -f1); fr=$(head -$((1+$i)) /data/All.commits.$pVer|tail -1| cut -d\; -f1); tail -$(($to-$fr+1)) /data/All.blobs/commit_$i.idx | ~/lookup/c2cc.perl /data/All.blobs/commit_$i.bin $ver; done 



# c2r may change if the formerly undefined commit is retrieved and
# has a parent
# first seed with roots/leaves up to 10th-level
time for k in {0..9}; do ~/lookup/Cmt2RootNew.perl S $k; done
#218m21.025s
time for i in {0..31}; do echo $i; time ~/lookup/Cmt2Root.perl $i ${ver}; done
0-th 13354m; 1-2286m; 2-3643m, 3-983m,...6-257m, ...28-213m

time for i in {0..31}; do ~/lookup/Cmt2HeadNew.perl $ver $i; done
#996m
time for i in {0..31}; do echo $i; time ~/lookup/Cmt2Head.perl $i ${ver}; done
#0-th 18357m 1-2341m 2-1242m, 4-609m, ..., 7-341m

# now deal with the remaining commits
time for i in {0..31}; do echo $i; ~/lookup/Cmt2Root.perl $i ${ver}; done 
time for i in {0..31}; do time ~/lookup/Cmt2Head.perl $i ${ver}; done
# 6926m on i=0, 758m on i=1 481m on i=2 347m on i=3 262m on i=4 221m on i=5...117m on i=10 79m i=19 65m i=30

for i in {0..127}; do sed "s/VER/S/g;s|WHAT|p2p|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/fork.pbs  | qsub ; sleep 1; done
for i in {0..15}; do sed "s/VER/S/g;s|WHAT|MERGE|g;s|FROM|$i|g;s|MACHINE|beacon|" ~/lookup/fork.pbs  | qsub ; sleep 1; done
sed "s/VER/S/g;s|WHAT|MERGEM|g;s|FROM|$i|g;s|MACHINE|beacon|;s|ppn=1|ppn=2|" ~/lookup/fork.pbs  | qsub ; sleep 1

# once community detection is done: defork (c2P, P2c)
#produces c2P
for i in {0..63}; do sed "s|WHAT|defork|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|;s|ppn=1|ppn=2|" ~/lookup/fork.pbs  | qsub ; sleep 1; done
#produces P2c (P2p2c may be too slow)
for i in {0..15}; do sed "s|WHAT|deforkP|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/fork.pbs  | qsub ; sleep 1; done
for i in {0..15}; do sed "s|WHAT|deforkPm|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/fork.pbs  | qsub ; sleep 1; done


#create project-based social network (needs c2P and c2dat), produces .na2a.s
#produces P2a
for i in {0..15}; do sed "s|WHAT|P2asplit|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
for i in {0..15}; do sed "s|WHAT|P2amerge|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 

#produces .na2a. needs P2amerge
for i in {0..31}; do sed "s|WHAT|a2a|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done
sed "s|WHAT|a2amerge|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|;s|ppn=1|ppn=2|" ~/lookup/a2p.pbs | qsub

#produces a2P, needs P2amerge
for i in {0..3}; do sed "s|WHAT|a2Pmerge|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
for i in {0..15}; do sed "s|WHAT|a2A|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
for i in {0..15}; do sed "s|WHAT|a2Asrt|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
for i in {0..3}; do sed "s|WHAT|A2Pmerge|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 


#clean by cut
sed "s|WHAT|top|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub


for cut in 1000 100 10
do for i in {0..7}; do sed "s|WHAT|A2Acut|g;s|CUT|$cut|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done
done
for cut in 1000 100 10
do sed "s|WHAT|A2Acutm|g;s|CUT|$cut|g;s|VER|S|;s|MACHINE|beacon|;s|ppn=1|ppn=2|" ~/lookup/a2p.pbs | qsub
done

scp -p P2AFull$ver.nA2A*.s da5:/data/play/forks

zcat pS.s| awk -F\; '{print $1";"$1}' | perl ~/lookup/mp.perl 1 c2pFullS.np2pu.PLMmap.forks  | gzip > p2PS.s
zcat p2PS.s | awk -F\; '{print $2"\;"$1}' | lsort 5G -t\; -k1,2 | gzip > P2pS.s 
scp -p P2pS.s p2PS.s {a2P,P2a}Full${ver}{[0-9],[12][0-9],3[01]}.s da3:/data/basemaps/gz
scp -p {P2c,c2P}Full${ver}{[0-9],[1-9][0-9],1[0-2][0-9]}.s da3:/data/basemaps/gz

# p2a/a2p
for i in {0..127}; do sed "s|WHAT|split|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
for i in {0..31}; do sed "s|WHAT|merge|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
for i in {0..7}; do sed "s|WHAT|a2psplit|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
for i in {0..31}; do sed "s|WHAT|a2pmerge|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/a2p.pbs | qsub; sleep 1; done 
scp -p {a2p,p2a}Full${ver}{[0-9],[12][0-9],3[01]}.s da3:/data/basemaps/gz


#produce a2p, p2a, p2P, P2p, a2P, P2a, c2P, P2c
for j in {0..31}; do zcat a2pFull$ver$j.s | ~/lookup/s2sBinSorted.perl ../a2pFull$ver.$j.tch; done &
for j in {0..31}; do zcat p2aFull$ver$j.s | ~/lookup/s2sBinSorted.perl ../p2aFull$ver.$j.tch; done &

for j in {0..31}; do zcat a2PFull$ver$j.s | ~/lookup/s2sBinSorted.perl ../a2PFull$ver.$j.tch; done &
for j in {0..31}; do zcat P2aFull$ver$j.s | ~/lookup/s2sBinSorted.perl ../P2aFull$ver.$j.tch; done &
zcat p2P$ver.s | ~/lookup/s2sBinSorted.perl ../p2PFull$ver.tch 1 &
zcat P2p$ver.s | ~/lookup/s2sBinSorted.perl ../P2pFull$ver.tch 1 &
for i in {0..31}; do zcat c2PFull$ver{$i,$(($i+32)),$(($i+64)),$(($i+96)).s | ~/lookup/h2sBinSorted.perl ../c2PFull$ver.$i.tch; done &
for i in {0..31}; do zcat P2cFull${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s  | ~/lookup/s2hBinSorted.perl ../P2cFull$ver.$i.tch; done &


#do ctags
for i in {0..127}
do mkdir -p /fast/tags$i; 
cd /fast/tags$i; 
lst=$(head -$((i+1)) /da4_data/All.blobs.R | tail -1|cut -d\; -f1)
tot=$(tail -1 /da4_data/All.blobs/blob_$i.idx|cut -d\; -f1)
tail -$(($tot-$lst)) /da4_data/All.blobs/blob_$i.idx | awk -F\; '{if(NF>5){print $5";"$2";"$3}else{print $4";"$2";"$3}}' | perl -I ~/lookup/ -I ~/lib64/perl5 ~/lookup/ctags2.perl $i tkns$i

| ~/lookup/lstShow.perl /fast/b2ffFull${ver}.$i.tch h s 2> /data/basemaps/gz/blob_$i.idx.noFname | gzip > /data/basemaps/gz/blob_$i.idx.fname
time zcat /data/basemaps/gz/blob_$i.idx.fname | perl -I ~/lookup/ -I ~/lib64/perl5 ~/lookup/ctags1.perl $i tkns$i 2> tkns$i.err
done


#after the diffs do b/f maps

for i in {0..63}; do sed "s|WHAT|prep|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done
wait
for t in c2b b2f c2f b2ta b2ob ob2b; do for i in {0..63}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done
#after b2ta, b2ob, b2f, ob2b, 
for t in b2fm  b2tam b2obm ob2bm; do for i in {0..63}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done
#after b2tam, c2f, c2b
for t in P2b b2P a2f P2f b2fa; do for i in {0..15}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done
#after b2fa
for t in a2fb; do for i in {0..15}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done
#after b2fm and c2f c2b
for t in f2b b2c f2c; do for i in {0..63}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done
#after f2c, f2b
for t in f2cm f2bm b2cm; do for i in {0..63}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done
#after a2f a2fb, P2b, P2f
for t in a2fbm a2fm P2bm b2Pm P2fm; do for i in {0..15}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done

#map files to idx
for t in addf; do for i in {0..63}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done
for t in addf1; do for i in {0..63}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done

#get tokens and imports (requires corresponding blob_*.bin)
for fr in {0..127}; do for t in ctags; do for j in {0..31}; do sed "s|WHAT|$t|g;s|FROM|$fr|g;s|PRT|$j|;s|VER|S|;s|MACHINE|beacon|;s|:ppn=1|:ppn=1|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; donefor t in ; do for j in {0..31}; do sed "s|WHAT|$t|g;s|FROM|$fr|g;s|PRT|$j|;s|VER|S|;s|MACHINE|beacon|;s|:ppn=1|:ppn=1|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done; done
#depends on the $fr being complete on the previous stage				      
for fr in {0..127}; do for t in toparse; do for j in {0..31}; do sed "s|WHAT|$t|g;s|FROM|$fr|g;s|PRT|$j|;s|VER|S|;s|MACHINE|beacon|;s|:ppn=1|:ppn=1|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done; done

b2tk  | b2P b2c b2ta b2fa b2f b2ob ob2b 
f2a? | f2b f2c
| a2f a2fb 
| b2P P2f P2b
c2td | c2b c2f
td2c td2f


#run on da5
ver=S
where=/data/basemaps/gz
cvt=h2h
for w in c2b b2c ob2b b2ob #b2ob and ob2b are on ssh da2
do for o in {0..3}
  do for i in $(eval echo "{$o..31..4}"); do ssh -p443 da3.local "zcat $where/${w}Full${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch; done &
  done
done
cvt=h2s
for w in c2f b2f 
do for o in {0..3}
  do for i in $(eval echo "{$o..31..4}"); do ssh -p443 da3.local  "zcat $where/${w}Full${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch; done &
  done
done
(cvt=h2s; w=b2P; for i in {0..31}; do time ssh -p443 da3.local  "zcat $where/${w}Full${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch;done) &
# c2ta, b2fa
(cvt=b2fac; w=b2fa; for i in {0..31}; do time ssh -p443 da3.local  "zcat $where/${w}Full${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch;done) &
(w=c2dat; for i in {0..31}; do ssh -p443 da3.local  "zcat $where/${w}Full${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null | ~/lookup/Cmt2FieldsBinSorted.perl /fast/${w}Full${ver}.$i.tch 1;done) &
(cvt=s2s; w=a2f; for i in {0..31}; do time ssh -p443 da3.local  "zcat $where/${w}Full${ver}$i.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch;done) &
(cvt=s2s; w=P2f; for i in {0..31}; do time ssh -p443 da3.local  "zcat $where/${w}Full${ver}$i.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch;done) &
(cvt=s2h; w=P2b; for i in {0..31}; do time ssh -p443 da3.local  "zcat $where/${w}Full${ver}$i.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch;done) &
cvt=s2h
for w in f2b f2c 
do for o in {0..3}
   do for i in $(eval echo "{$o..31..4}"); do ssh -p443 da3.local  "zcat $where/${w}Full${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null | ~/lookup/${cvt}BinSorted.perl /fast/${w}Full${ver}.$i.tch; done &
  done
done
#f2a? no longer relevant?

#prep data for mongodb
for i in {0..127}; do zcat c2PFullS$i.s | join -t\; - <(zcat c2datFullS$i.s) | cut -d\; -f2,3; done | perl -e 'while (<STDIN>){chop();($p,$t)=split(/;/,$_,-1);$pmi{$p}=$t if ($pmi{$p}>$t || !defined $pmi{$p}) && $t > 100000000;$pma{$p}=$t if $pma{$p}<$t || !defined $pma{$p}} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}'  | gzip > P2tspanFullS.s
for i in {0..127}; do zcat c2datFullS$i.s | cut -d\; -f2,3; done | perl -e 'while (<STDIN>){chop();($t,$p)=split(/;/,$_,-1);$pmi{$p}=$t if ($pmi{$p}>$t || !defined $pmi{$p}) && $t > 100000000;$pma{$p}=$t if $pma{$p}<$t || !defined $pma{$p}} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}'  | gzip > a2tspanFullS.s
zcat P2tspanFullS.s| ~/lookup/splitSecCh.perl P2tspanFullS 32 
zcat a2tspanFullS.s| ~/lookup/splitSecCh.perl a2tspanFullS 32 
for i in {0..31}; do zcat P2tspanFullS$i.s | join -t\; - <(zcat P2summFullS$i.s | lsort 40G -t\; -k1,1) | perl ~/lookup/prjToMongo.perl; done 
for i in {0..31}; do zcat a2tspanFullS$i.gz | join -t\; - <(zcat a2summFullS$i.s | lsort 40G -t\; -k1,1) | perl ~/lookup/authToMongo.perl; done 


zcat a2tspanFullS.s| ~/lookup/splitSecCh.perl a2tspanFullS 32
for i in {0..31}; do time perl ~/lookup/prjSummary.perl S $i | gzip > P2summFullS$i.s; done &
for i in {0..31}; do time perl ~/lookup/authSummary.perl S $i | gzip > a2summFullS$i.s; done &


(w=b2tk; for i in {0..31}; do ssh -p443 da3.local  "zzcat $where/${w}Full${ver}{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null  | ~/lookup/Cmt2FieldsBinSorted.perl /fast/${w}Full${ver}.$i.tch 1;done) &

# a2fb lookup/updateCFBR.pbs
for i in {0..31}; do ssh -p443 da3.local  "zcat  $where/a2fbFull$ver{$i,$(($i+32)),$(($i+64)),$(($i+96))}.s" < /dev/null | ~/lookup/s2hBinSorted.perl /fast/a2fbFull$ver.$i.tch; done &

#no new aliasing since version Q
zcat /da?_data/basemaps/gz/a2AQ.s | ~/lookup/s2sBinSorted.perl /da0_data/basemaps/a2AS.tch 1
```




### Version R

- use gather/run2003.sh to discover repos
- use libgit2/handleOtherForges.sh to extract objects
- use beacon doR.sh/runR.pbs/run1R.pbs/runOR.pbs/runO1R.pbs to do massive cloning
- rsync back
```
for i in 52 53; do nn=$i; cd ../$ver.$nn; rsync -av *.olist.gz *.err list202003* *.{blob,commit,tree,tag}.{idx,bin} da5:/data/home/audris/update/$ver.$nn/; done
```
- todo/check/merge/backup traces to bb1
```
(k=53;cd ../$ver.$k; for i in {00..15}; do zcat New202003*.$i.olist.gz | ~/lookup/cleanBlb.perl | ~/bin/hasObj.perl | gzip > todo.$i & done; wait; for i in {00..15}; do zcat todo.$i; done | gzip > todo) &
(nn=53; cd ../$ver.$nn; for t in blob tag commit tree;do ls -f  *$t.bin  | sed 's/\.bin$//' | while read i; do (echo $i; perl -I ~/lib64/perl5/ ~/lookup/checkBin1in.perl $t $i) &>> ../${ver}.$nn.$t.err; done; done) &
(nn=53; cd ../${ver}.$nn;for type in tag commit tree blob; do time ls -f *.$type.bin | ~/lookup/AllUpdateObj.perl $type; done)
(nn=53; cd ../${ver}.$nn; zcat *.olist.gz | grep ';commit;' | $HOME/lookup/Prj2CmtChk.perl /fast/p2cFull$pVer 32  | lsort 30G -u -t\; -k1b,2| gzip > New$DT.${ver}1.$nn.p2c)
for i in 51 52 53; do rsync -av ../${ver}.$i/*.{err,idx,tag.bin,commit.bin,olist.gz,$i,p2c} ../${ver}.$i/BigChunks.* bb1:/da4_data/update/${ver}.$i/; done &
#on beacon update c2p/p2c to ${ver}
#lookup/updatePrj${ver}.pbs
#get forks sed "s/VER/${ver}/;s/MACHINE/monster/;s/=23/=23/" ~/lookup/fork.pbs | qsub
```


- Update content
```
for i in {0..127}; do time ~/lookup/Obj2ContUpdt.perl commit $i 1709375; done &
for i in {0..127}; do time ~/lookup/Obj2ContUpdt.perl tree $i 5709375; done &
for i in {0..127}; do ~/lookup/BlobN2Off.perl $i; done
for i in {0..127}; do ~/lookup/TreeN2Off.perl $i; done
for i in {0..127}; do ~/lookup/CmtN2Off.perl $i; done
```
- Calc diffs 
```
grep commit /data/basemaps/gz/All.blobs.Q| cut -d\; -f2,3 | while IFS=\; read s n c; do rn=$(( $(tail -1 /data/All.blobs/commit_$s.idx|cut -d\; -f1) - $n + 1)); tail -$rn /data/All.blobs/commit_$s.idx | lsort 1G | cut -d\; -f4 | gzip > QR$s.cs; done &
for i in {0..127}; do time zcat QR$i.cs  | perl -I ~/lookup -I ~/lib64/perl5 ~/lookup/cmputeDiff3.perl 2> errQR.$i | gzip > QR$i.gz; done  &
for i in {0..127}; do lsort 100G -t\; -k1,3 --merge <(zcat c2fbbFullQ$i.s) <(zcat QR$i.gz|perl -I $HOME/lib64/perl5 -I $HOME/lookup -e 'use cmt; while(<STDIN>){ chop (); s|;/|;|; @r = split(/;/); $r[$#r] = "long" if $r[$#r] =~ / /&& length($r[$#r]) > 300; print "".(join ";", @r)."\n" if ! defined $badCmt{$r[0]};}') | gzip > c2fbbFullR$i.s; done &
#put them in bin format


for i in {0..127..4}; do  ssh da0 "zcat /data/basemaps/gz/c2fbbFullQ$i.s" < /dev/null | perl -ane 'chop();($c,$f,$bn,$bo)=split(/;/,$_,-1);if ($bo ne ""&& $bo =~ /^[0-9a-f]{40}$/){print "$bn;$bo;$c;$f\n";}' | gzip > bbcfFullQ$i.gz; done &
...
wait
for i in {0..127}; do zcat bbcfFullQ$i.gz; done | perl ~/lookup/splitSec.perl bbcfFullQ. 128
for i in {0..127}; do zcat bbcfFullQ.$i.gz | lsort 100G -t\; -k1,3 | gzip > bbcfFullQ$i.s; done
for i in {0..127}; do zcat bbcfFullQ$j.s | cut -d\; -f1,2 | uniq | perl -ane 'print if m/^[0-9a-f]{40};[0-9a-f]{40}$/' | ~/lookup/h2hBinSorted.perl  /fast/b2obFullQ.$i.tch; done #all ways a blob came into existence
#for i in {0..127}; do bbcfFullQ$j.s | uniq | perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/hh2hsBinSorted.perl /fast/bbcfFullQ.$i.tch; done

#add new c2fbb 

```

- get authors
```
#on dad2
ver=R
cd /store/cmts
#fix timestamp to sort properly and make nonsense (11 digit) time zero
for j in {0..127}; do $HOME/lookup/lstCmt.perl 1 $j | perl -ane '@x=split(/;/, $_, -1); $x[1] = 0 if length($x[1]) > 10; $x[1] = sprintf "%.10d", $x[1]; print "".(join ";", @x);' | lsort 30G -t\; -k1,2 | gzip > c2taFull$ver$j.s; done &
wait
for j in {0..31}; do zcat c2taFull$ver$j.s | lsort 30G -t\; -k1,2 --merge - <(zcat c2taFull$ver$(($j+32)).s) <(zcat c2taFull$ver$(($j+64)).s) <(zcat c2taFull$ver$(($j+96)).s) | gzip > c2taFull$ver.$j.s;done& 
wait
for j in {0..31}; do zcat c2taFull$ver.$j.s | awk -F\; '{print $3";"$1}' | ~/lookup/splitSecCh.perl a2cFull$ver.$j. 32 & done
wait
for j in {0..31}
do for i in {0..31}
  do zcat a2cFull$ver.$i.$j.gz | lsort 4G -t\; -k1,2 | gzip > a2cFull$ver.$i.$j.s &
  done
  wait
  echo done $j
done
for j in {0..31}; do str="lsort 30G -u --merge -t\; -k1,2"; for i in {0..31}; do str="$str <(zcat a2cFull$ver.$i.$j.s)"; done; eval $str | gzip > a2cFull$ver.$j.s; done &
wait
for j in {0..31}; do zcat a2cFull$ver.$j.s | cut -d\; -f1 | uniq | gzip > a$ver$j.s & done
wait
str="lsort 30G -u --merge -t\; -k1,1"
for i in {0..31}; do str="$str <(zcat a$ver$i.s)"; done; 
eval $str | gzip > a$ver.s

#create databases
for j in {0..31}; do zcat a2cFull$ver.$j.s | ~/lookup/s2hBinSorted.perl /fast/a2cFull$ver.$j.tch; done &
for i in {0..31}; do zcat c2taFull$ver.$i.s | ~/lookup/Cmt2taBin.perl /fast/c2taFull$ver.$i.tch 1; done &
wait

scp -p a$ver.s c2taFull$ver.{[0-9],[1-3][0-9]}.s a2cFull$ver.{[0-9],[1-3][0-9]}.s da0:/data/basemaps/gz
scp -p /fast/a2cFull$ver.{[0-9],[1-3][0-9]}.tch da0:/data/basemaps/


for i in {0..31..4}; do scp -p da0:/data/basemaps/c2pcFullQ.$i.tch /fast/c2pcFull${ver}.$i.tch; ~/lookup/Cmt2Par.perl $i $ver | gzip > cnpFull$ver.$i; done &
...
wait
for i in {0..31}; do scp -p da0:/data/basemaps/c2ccFullQ.$i.tch /fast/c2ccFull${ver}.$i.tch; done
time ~/lookup/Cmt2ChldCUpdt.perl /fast/c2ccFullQ 2000000
#4250m

for i in {0..31}; do scp -p da0:/data/basemaps/c2rFullQ.$i.tch /fast/c2rFull${ver}.$i.tch; ~/lookup/Cmt2${ver}oot.perl $i ${ver}; done &
wait
for i in {0..31}; do rm -f /fast/c2hFull${ver}.$i.tch; done
for i in {0..31}; do time ~/lookup/Cmt2Head.perl $i ${ver}; done
# 6926m on i=0, 758m on i=1 481m on i=2 347m on i=3 262m on i=4 221m on i=5...117m on i=10 79m i=19 65m i=30

#now copy c2{pc,r,h,cc,ta,a}Full$ver.*.tch a2cFull$ver.*.tch da0:/data/basemaps/ 
#done with primary commit maps

#create databases for c2p/p2c
for j in {0..31}; do ssh da3 "zcat /data/basemaps/gz/p2cFull$ver$i.s" < /dev/null | ~/lookup/s2hBinSorted.perl /fast/p2cFull$ver.$j.tch; done &
for j in {0..31}; do ssh da3 "zcat /data/basemaps/gz/c2pFull$ver$i.s" < /dev/null | ~/lookup/h2sBinSorted.perl /fast/c2pFull$ver.$j.tch; done &

#calculate a2p and p2a (see p2a.pbs)
for i in {0..31}; do zcat a2pFull$ver$i.s | ~/lookup/s2sBinSorted.perl /fast/a2pFull$ver.$i.tch; done &
for i in {0..31}; do zcat p2aFull$ver$i.s | ~/lookup/s2sBinSorted.perl /fast/p2aFull$ver.$i.tch; done &

#calculate a2f and f2a (see updateCFBR.pbs)
for w in a2f f2a p2a a2p
do for o in {0..3}
  do for i in $(eval echo "{$o..31..4}"); do zcat ${w}Full${ver}$i.s | ~/lookup/s2sBinSorted.perl /fast/${w}Full${ver}.$i.tch; done &
  done
done

for w in c2p c2f b2f 
do for o in {0..3}
  do for i in $(eval echo "{$o..31..4}"); do zcat ${w}Full${ver}$i.s ${w}Full${ver}$(($i+32)).s ${w}Full${ver}$(($i+64)).s ${w}Full${ver}$(($i+96)).s | ~/lookup/h2sBinSorted.perl /fast/${w}Full${ver}.$i.tch; done &
  done
  wait
done

done
for w in c2b b2c 
do for o in {0..3}
  do for i in $(eval echo "{$o..31..4}"); do zcat ${w}Full${ver}$i.s ${w}Full${ver}$(($i+32)).s ${w}Full${ver}$(($i+64)).s ${w}Full${ver}$(($i+96)).s | ~/lookup/h2hBinSorted.perl /fast/${w}Full${ver}.$i.tch; done &
  done
done
for w in p2c a2c f2b f2c 
do for o in {0..3}
  do for i in $(eval echo "{$o..31..4}"); do zcat ${w}Full${ver}$i.s ${w}Full${ver}$(($i+32)).s ${w}Full${ver}$(($i+64)).s ${w}Full${ver}$(($i+96)).s | ~/lookup/s2hBinSorted.perl /fast/${w}Full${ver}.$i.tch; done &
  done
done

# c2ta, b2fa
(w=b2fa; for i in {0..31}; do time zcat ${w}Full${ver}$i.s ${w}Full${ver}$(($i+32)).s ${w}Full${ver}$(($i+64)).s ${w}Full${ver}$(($i+96)).s | ~/lookup/b2facBinSorted.perl /fast/b2aFull${ver}.$i.tch;done)
(w=c2ta; for i in {0..31}; do zcat ${w}Full${ver}$i.s ${w}Full${ver}$(($i+32)).s ${w}Full${ver}$(($i+64)).s ${w}Full${ver}$(($i+96)).s | ~/lookup/Cmt2FieldsBinSorted.perl /fast/${w}Full${ver}.$i.tch 1;done)
(w=b2tk; for i in {0..31}; do zcat ${w}Full${ver}$i.s ${w}Full${ver}$(($i+32)).s ${w}Full${ver}$(($i+64)).s ${w}Full${ver}$(($i+96)).s | ~/lookup/Cmt2FieldsBinSorted.perl /fast/${w}Full${ver}.$i.tch 1;done)

# a2fb lookup/updateCFBR.pbs
for i in {0..31}; do time zcat a2fbFull$ver.$i.s | ~/lookup/s2hBinSorted.perl /fast/a2fbFull$ver.$i.tch; done &


# tokens
#get first file name to annotate blobs
(w=b2f; for i in {0..127}; do zcat ${w}Full${ver}$i.s | perl -e '$bp="";while (<STDIN>){($b,$f)=split(/;/,$_,-1);next if $bp eq $b; $bp=$b; $f=~s|.*/||; print "$b;$f"}' | ~/lookup/h2sBinSorted.perl /fast/b2ffFull${ver}.$i.tch 0; done 
#now extract tokens
for i in {0..127}
do mkdir -p /fast/tags$i; 
cd /fast/tags$i; 
cat /data/All.blobs/blob_$i.idx | awk -F\; '{if (NF>5){print $5";"$2";"$3}else{print $4";"$2";"$3}}' | ~/lookup/lstShow.perl /fast/b2ffFull${ver}.$i.tch h s 2> /data/basemaps/gz/blob_$i.idx.noFname | gzip > /data/basemaps/gz/blob_$i.idx.fname
time zcat /data/basemaps/gz/blob_$i.idx.fname | perl -I ~/lookup/ -I ~/lib64/perl5 ~/lookup/ctags1.perl $i tkns$i 2> tkns$i.err
done


# we need blob to commit for commits that have no parent as well
for j in {0..15}; do for i in $(eval echo {$j..127..16}); do k=$(($i%32)); cut -d\; -f4 /data/All.blobs/commit_$i.idx| ~/lookup/hasValue.perl /fast/c2pcFull${ver}.$k.tch | gzip > /data/basemaps/gz/cnpFull${ver}.$i; done & done
wait
for j in {0..15}; do for i in $(eval echo {$j..127..16}); do zcat /data/basemaps/gz/cnpFull${ver}.$i | lsort 5G -u | ~/lookup/showCmtTree.perl 2> /data/basemaps/gz/cnp2bfFull${ver}$i.err | gzip > /data/basemaps/gz/cnp2bfFull${ver}$i.s; done & done
#see see ~/lookup/b2cfall.pbs for detail
# also need to add blobs for commits that have parent specified but not in the database
...

#fix c2cc
echo 692a9535fce8d19a7df0d1ec98254aa98d99d483 |~/lookup/getValues -f c2pc
692a9535fce8d19a7df0d1ec98254aa98d99d483;e6fd4dcc357c8f62934b677988b4a4bfdcff9f27
but no child:
echo e6fd4dcc357c8f62934b677988b4a4bfdcff9f27 | ~/lookup/getValues -f c2cc

#invert c2fbb and cnp2bf - need for b2c, b2f, 

for i in {0..127}; do  ssh da0 "zcat /data/basemaps/gz/c2fbbFull$ver$i.s" < dev/null | perl -ane 'chop();($c,$f,$bn,$bo)=split(/;/,$_,-1);if ($bo ne ""&& $bo =~ /^[0-9a-f]{40}$/){print "$bn;$bo;$c;$f\n";}' | gzip > bbcfFull$ver$i.gz; done

for i in {0..127}; do 
zcat /da0_data/basemaps/gz/c2fbbFull$ver$i.s | perl -ane 'chop();($c,$f,$bn,$bo)=split(/;/,$_,-1);if ($bo eq "" && $bn =~ /^[0-9a-f]{40}$/){print "$bn;$c;$f\n";}'
done | ~/lookup/splitSec.perl b2cfFull$ver

# b2tk is needed for token diff (td) map, see token diffs

#do token diffs
#first create b2tk map
for i in {0..127}; do zcat tkns$i.idx.gz | awk -F\; '{print $6";"$5}' | lsort 100G -t\; -k1,2 -u | gzip > b2tkFull${ver}$i.s); done

#now use it to join with bb/obb to get tk2otk map (below may be a better approach)
#for i in {0..127}; do lsort 200G -t\; -k1,2 --merge -u <(zcat b2tkFull${ver}$i.s) <(zcat b2tkFull${ver}$(($i+32)).s) <(zcat b2tkFull${ver}$(($i+64)).s) <(zcat b2tkFull${ver}$(($i+96)).s) | grep -v '^;' | gzip > b2tkFull${ver}.$i.s; done
#for i in {0..127}; do zcat b2tkFull${ver}$i.s  | uniq | perl -ane 'print if /^[0-9a-f]{40};[0-9a-f]{40}$/' | join -t\; <(zcat obb$i.s) - |gzip > obb2tk$i.s; done
#for i in {0..127}; do zcat b2tkbcfFull${ver}$i.s; done | awk -F\; '{print $3";"$1";"$2";"$4";"$5}'| perl ~/lookup/splitSec.perl obbtkcf. 32 &
#for i in {0..31}; do zcat obbtkcf.$i.gz | lsort 100G -t\; -k1,3 | gzip > obbtkcf.$i.s; done
#for i in {0..31}; do zcat b2tkFull${ver}.$i.s | join -t\; - <(zcat /data/basemaps/gz/obbtkcf.$i.s) | cut -d\; -f2,4- | uniq | gzip > otktkcf.$i.s; done
#zcat otktkcf.*.s | awk -F\; '{ print $2 ";" $1}' | uniq | ~/lookup/splitSec.perl tk2otk. 32
#for i in {0..31}; do zcat tk2otk.$i.gz | lsort 100G -t\; -k1,2 -u | gzip > tk2otk$i.s; done

#see actions below to get bb2tk and bb2otk
for i in {0..31}; do for j in {0..127..32}; do zcat bb2tk$(($i+$j)).s | sed 's|;|_|' | join -t\; - <(zcat bb2otk$(($i+$j)).s|sed 's|;|_|'); done | cut -d\; -f2- | uniq | gzip >  tk2otk$i.s; done
#now run the diff
for i in {0..31}; do time zcat tk2otk$i.s | ~/lookup/tdiffFromGz.perl $i; done 

#finally create c2td, td2c, and td2f map for token diffs

#get bb to tk
for i in {0..127}; do zcat bbcfFull${ver}$i.s | cut -d\; -f1,2 | uniq | perl -ane 'print if /^[0-9a-f]{40};[0-9a-f]{40}$/' | gzip > bb$i.s; done &
for i in {0..127}; do zcat b2tkfFull${ver}$i.s  | uniq | perl -ane 'print if /^[0-9a-f]{40};[0-9a-f]{40}$/' | join -t\; <(zcat bb$i.s) - |gzip > bb2tk$i.s; done

#get bb to otk
for i in {0..127}; do zcat obbcfFull${ver}$i.s | cut -d\; -f1,2 | uniq | perl -ane 'print if /^[0-9a-f]{40};[0-9a-f]{40}$/' | gzip > obb$i.s; done &
for i in {0..127}; do zcat b2tkFull${ver}$i.s  | uniq | perl -ane 'print if /^[0-9a-f]{40};[0-9a-f]{40}$/' | join -t\; <(zcat obb$i.s) - |gzip > obb2tk$i.s; done
for i in {0..127}; do zcat obb2tk$i.s | awk -F\; '{print $2";"$1";"$3}'; done | ~/lookup/splitSec.perl bb2otk$i. 128
for i in {0..127}; do zcat bb2otk.$i.gz | lsort 50G -t\; -k1,3 | gzip > bb2otk$i.s

#do we need this? in case want to map thotk to bob
zcat bb2tk0.s | sed 's|;|_|' | join -t\; - <(zcat bb2otk0.s|sed 's|;|_|'); done | awk -F\; '{print $2"_"$3";"$1}' | ~/lookup/splitSec.perl tkotk2bb$i. 32

#link tkotk to td
awk -F\; '{print $6";"$5";"$4}' /data/All.blobs/tdiff_*.idx | splitSec.perl tk2otktd${ver}. 128
for i in {0..127}; do zcat tk2otktd${ver}.$i.gz | lsort 50G -t\; -k1,3 -u | gzip > tk2otktd${ver}.$i.s; done

#link tkotk to cf
for i in {0..127}; do zcat bb2tk$i.s | sed 's|;|_|' | join -t\; - <(zcat bb2otk$i.s|sed 's|;|_|') | join -t\; - <(zcat bbcfFull${ver}$i.s| sed 's|;|_|') | awk -F\; '{print $2"_"$3";"$4";"$5}'|uniq | gzip > tkotk2cf$i.s; done
for i in {0..127}; do zcat tkotk2cf$i.s; done |~/lookup/splitSec.perl tkotk2cf. 128
for i in {0..127}; do zcat tkotk2cf.$i.gz | lsort 100G -t\; -k1,3 -u | gzip > tkotk2cf.$i.s; done

#create c2tdf, td2cf
for i in {0..127}; do zcat tkotk2cf.$i.s | join -t\; <(zcat tk2otktd${ver}.$i.s | sed 's|;|_|') - | awk -F\; '{ print $3";"$2";"$4}' | gzip > c2tdf$i.gz; done
for i in {0..127}; do zcat c2tdf$i.gz; done |~/lookup/splitSec.perl c2tdfFull${ver} 32
for i in {0..31}; do zcat c2tdfFull${ver}.$i.gz | lsort 100G -t\; -k1,3 -u | gzip > c2tdfFull${ver}$i.s; done

for i in {0..127}; do zcat c2tdf$i.gz | awk -F\; '{print $2";"$1";"$3}'; done | ~/lookup/splitSec.perl td2cfFull${ver}. 32
for i in {0..31}; do zcat td2cfFull${ver}.$i.gz |  lsort 100G -t\; -k1,3 -u | gzip > td2cfFull${ver}$i.s

#create c2td, td2c, td2f
for i in {0..31}; do zcat c2tdfFull${ver}$i.s | cut -d\; -f1,2 | grep -v ';$' | uniq |  ~/lookup/h2hBinSorted.perl /fast/c2tdFull${ver}.$i.tch 0; done
for i in {0..31}; do zcat td2cfFull${ver}$i.s | cut -d\; -f1,2 | grep -v '^;' | uniq | ~/lookup/h2hBinSorted.perl /fast/td2cFull${ver}.$i.tch 0; done
for i in {0..31}; do zcat td2cfFull${ver}$i.s | cut -d\; -f1,3 | grep -v '^;' | grep -v ';$' | uniq | ~/lookup/h2sBinSorted.perl /fast/td2fFull${ver}.$i.tch 0; done
...


# find missing filenames for blobs
for h in {0..7}; 
do ssh woc$(($h+1)) "for i in {$h..127..8}; do perl -I ~/lib/x86_64-linux-gnu/perl/ b2ptf.perl $i | gzip > /data/basemaps/gz/b2ptfR$i.gz; done" &
done
?do tree to parent tree map as well? and use in conjunction with t2c to find the commit for these blobs?

zcat /woc?_data/basemaps/gz/b2ptfR*.gz | grep 00c9be71f11193b60bdd7cfba2ba5b74da467e95
woc2:00c9be71f11193b60bdd7cfba2ba5b74da467e95;69fb1aff02aefe1e803fabed802c187f37c4c118;game.rb


Create tree to commit map
for h in {0..7}; 
do ssh woc$(($h+1)) "for i in {$h..127..8}; do perl -I ~/lookup/ -I ~/lib/x86_64-linux-gnu/perl/ ~/lookup/lstCmt.perl 0 $i | awk -F\; '{print $2";"$1}' | gzip
> /data/basemaps/gz/t2cFullR$i.gz; done" &
done


zcat /data/basemaps/gz/t2c* | grep 69fb1aff02aefe1e803fabed802c187f37c4c118

```
#the Q ver api model took 45 days! 
( time python3 fitXpclF.py PtAPkgQ 200 50 20 5 1618784533 /fast/all 143 &> fitXpclF.out )
real    65609m27.716s
user    944992m8.628s
sys     48077m54.233s



### Version P
```
(t=tag; ls -f O.*/*$t.bin  | sed 's/\.bin$//' | while read i; do (echo $i; perl -I ~/lib64/perl5/ ~/lookup/checkBin1in.perl $t $i)&>> O.$t.err; done) &
(t=commit; ls -f O.*/*$t.bin  | sed 's/\.bin$//' | while read i; do (echo $i; perl -I ~/lib64/perl5/ ~/lookup/checkBin1in.perl $t $i)&>> O.$t.err; done) &

for r in {00..39} 
for r in {40..67} 69 70 
do cd /data/update/O.$r 
 #time ls -f *.tag.bin | ~/lookup/AllUpdateObj.perl tag
 time ls -f *.commit.bin | ~/lookup/AllUpdateObj.perl commit
 #time ls -f *.tree.bin | ~/lookup/AllUpdateObj.perl tree 
 #time ls -f *.blob.bin | ~/lookup/AllUpdateObj.perl blob
done
for i in {0..127}; do ~/lookup/Obj2ContUpdt.perl commit $i $nmax; done
for i in {0..127}; do ~/lookup/Obj2ContUpdt.perl tree $i $nmax; done
for i in {0..127}; do ~/lookup/BlobN2Off.perl $i; done

zcat c2pFullP$j.cs | lsort 5G -u --merge  <(zcat c2taFP$j.cs) |  join -v1 - <(zcat c2fFullO$j.cs) | join -v1 - <(zcat emptycsO.$j) | gzip > s12.$j.gz

for j in {0..31}; do zcat c2taFull$ver.$j.s | awk -F\; '{print $3 ";" $1}' | lsort 10G -t\; -k1b,2 | gzip > a2cF$ver$j.s & done
for i in {0..31}; do zcat /data/basemaps/gz/c2taFull$ver.$i.s | ~/lookup/Cmt2taBin.perl /fast/c2taFullP.$i.tch 1 & done
wait

for j in {0..31}
do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl $j $ver | gzip > /data/basemaps/gz/cncFull$ver.$j &
done
for j in {0..31}
do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Head.perl $j $ver  &
done

for j in {0..31}
do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Par.perl $j $ver > /data/basemaps/gz/cnpFull$ver.$j &
done
for j in {0..31}
do for i in $j $(($j+32)) $(($j+64))$(($j+96)); do cut -d\; -f4 /data/All.blobs/commit_$i.idx; done |  perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Root.perl $j $ver  &
done

pVer=O
ver=P

#update b2a from version O - each takes 10-30 days
# ver O  zcat /da0_data/basemaps/gz/b2cFull$ver$i.s | ~/lookup/Blob2Author.perl $ver 2> /data/update/b2aFull$ver$i.err | gzip > /data/update/b2aFull$ver$i.s
# following update quite fast
zcat /da0_data/basemaps/gz/b2cFull$ver$i.s | join -t\; -v1 - <(zcat /da0_data/basemaps/gz/b2cFull$pVer$i.s) | gzip > b2cFull$ver$pVerO$i.s
zcat b2cFull$ver$pVer$i.s| ~/lookup/Blob2Author.perl P 2> b2aFull$ver$pVer$i.err | gzip > b2aFull$ver$Pver$i.s
~/lookup/Blob2AuthorJoin.perl  /da0_data/basemaps/gz/b2aFull$pVer$i.s b2aFull$ver$pVer$i.s | gzip > /da0_data/basemaps/gz/b2aFull$ver$i.s




for LA in jl pl R #
for LA in  ipy F Go Scala swift Cs C JS PY Rust java 
do cd /da0_data/play/${LA}thruMaps
 for int in "{0..31}" "{32..63}" "{64..95}" "{96..127}" 
 do for j in $(eval "echo $int")
  do zcat b$pVer${LA}.$j.gz | lsort 3G -u | join -v2 - <(zcat b$ver$LA.$j.gz | lsort 3G -u) | gzip > b$ver$LA.$j.s1 &
  done
  wait
 done
 for int in "{0..31}" "{32..63}" "{64..95}" "{96..127}" 
 do for j in $(eval "echo $int")
  do zcat b$ver${LA}.$j.s1 | ~/lookup/b2pkgsFast${LA}.perl $j 2> /dev/null | gzip > b$ver${LA}pkgs.$j.s1 &
  done
  wait
 done
 for int in "{0..31}" "{32..63}" "{64..95}" "{96..127}" 
 do for j in $(eval "echo $int")
  do zcat b$pVer${LA}pkgs.$j.gz b$ver${LA}pkgs.$j.s1 |gzip > b$ver${LA}pkgs.$j.gz &  
 done; wait; done
done

```

### Version O
```
cd /data/update
# 201903 add gitlab.com
lst="android.googlesource.com bioconductor.org bitbucket.org drupal.com git.eclipse.org git.kernel.org git.postgresql.org git.savannah.gnu.org git.zx2c4.com gitlab.gnome.org kde.org repo.or.cz salsa.debian.org sourceforge.net"
for r in {00..24}  $lst
do cd /data/update/N.$r 
 time ls -f *.tag.bin | ~/lookup/AllUpdateObj.perl tag
 time ls -f *.tree.bin | ~/lookup/AllUpdateObj.perl tree
 time ls -f *.blob.bin | ~/lookup/AllUpdateObj.perl blob
 time ls -f *.commit.bin | ~/lookup/AllUpdateObj.perl commit

 zcat *.olist.gz | ssh  dad2 '~/lookup/Prj2CmtChk.perl /fast/p2cFullN 32' | lsort 120G -u -t\; -k1b,2 | ~/lookup/splitSecCh.perl p2c. 32 
 for j in {0..31}; do gunzip -c p2c.$j.gz | awk -F\; '{print $2";"$1}'
 done | lsort 120G -u -t\; -k1b,2 | ~/lookup/splitSec.perl c2p. 3
done 

ver=O
pVer=N
for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in {00..24} $lst; do str="$str <(zcat N.$i/p2c.$j.gz)"; done; eval $str | gzip > p2c$ver$j.s; done &
for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in {00..24} $lst; do str="$str <(zcat N.$i/c2p.$j.gz)"; done; eval $str | gzip > c2p$ver$j.s; done &

for j in {0..127}; do $HOME/lookup/lstCmt.perl 1 $j | lsort 2G -t\; -k1b,2 | gzip > /data/basemaps/gz/c2taFull$ver$j.s & done
wait
for j in {0..31}; do zcat /data/basemaps/gz/c2taFull$ver$j.s | lsort 9G -t\; -k1b,2 --merge - <(zcat /data/basemaps/gz/c2taFull$ver$(($j+32)).s) <(zcat /data/basemaps/gz/c2taFull$ver$(($j+64)).s) <(zcat /data/basemaps/gz/c2taFull$ver$(($j+96)).s) | gzip > /data/basemaps/gz/c2taFull$ver.$j.s & done 
wait

for i in {0..31}; do zcat s11.$i.c2fb | cut -d\; -f1 | uniq | gzip > s11.$i.got; zcat s11.$i.got | join -v2 - <(zcat s11.$i.gz) | gzip > s11.$i.left; grep ^identical s11.new.$i.err | sed 's/.* for //;s/ and.*//' | lsort 1G -u > s11.$i.empty; (zcat /data/basemaps/gz/badcs$pVer.$i; join -v1 <(zcat s11.$i.left) <(zcat s11.$i.got) | join -v1 - s11.$i.empty) | lsort 1G -u > s11.$i.try;
cat s11.$i.try | ~/lookup/cmputeDiff2.perl 2>  s11.$i.try.err | gzip > s11.$i.try.c2fb;
(zcat  /data/basemaps/gz/emptycs$pVer.$i; cat s11.$i.empty; grep ^identical s11.$i.try.err | sed 's/.* for //;s/ and.*//')|lsort 1G -u | gzip > /data/basemaps/gz/emptycs$ver.$i;
zcat s11.$i.try.c2fb | cut -d\; -f1 | uniq | gzip > s11.$i.try.got;
zcat s11.$i.try.got | join -v2 - s11.$i.try | join -v1 - <(zcat  /data/basemaps/gz/emptycs$ver.$i) | gzip >  /data/basemaps/gz/badcs$ver.$i;
done

on dad2: 
for j in {0..31}; do time zcat /data/c2pFullO$j.s | awk -F\; '{print $1 ";;;" $2}' | perl -I ~/lookup  -I ~/lib/x86_64-linux-gnu/perl ~/lookup/Cmt2PrjBinSorted.perl /fast/c2pFullO.$j.tch 1; done &
for j in {0..31}; do time zcat /data/p2cFullO$j.s |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/p2cFullO.$j.tch; done &
for i in {0..31}; do zcat /data/a2pO.$i.gz | perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl ~/lookup/Prj2FileBinSorted.perl a2pO.$i.tch; done &
for i in {0..31}; do zcat /data/p2aO.$i.gz | perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl ~/lookup/Prj2FileBinSorted.perl p2aO.$i.tch; done &
for j in {0..31}; do time zcat /data/a2cFullO$j.gz |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFullO.$j.tch; done
for j in {0..31}; do time perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl  $j $ver | gzip > /da0_data/basemaps/gz/cnpFull$ver.$j; done
zcat a2cFull$ver*gz | cut -d\; -f1 | uniq | gzip > as$ver.gz
zcat as$ver.gz | perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl -I /home/audris/lookup -ane 'use cmt; chop();@x=splitSignature($_);@n = split(/ /, $x[0]); @e = split(/\@/, $x[1]); print "$_;$x[0];$x[1];$n[0];$n[$#n];$e[0];$e[1]\n";' | gzip > as$ver.split
#zcat as$ver.split | perl -ane 'chop();if ($_ !~ m/^;/){@x=split(/\;/, $_); for $i (0..$#x){ $x[$i] =~ s/"/'"'"'/g; } print "{ \"id\":\"$x[0]\", \"name\":\"$x[1]\", \"email\":\"$x[2]\", \"first\":\"$x[3]\", \"last\":\"$x[4]\", \"user\":\"$x[5]\",\"domain\":\"$x[6]\" }\n";} '| gzip > as$ver.split.json

zcat as$ver.split | perl -ane 'chop();if ($_ !~ m/^;/){@x=split(/\;/, $_); for $i (0..$#x){ $x[$i] =~ s/"//g; } print "{ \"id\":\"$x[0]\", \"name\":\"$x[1]\", \"email\":\"$x[2]\", \"first\":\"$x[3]\", \"last\":\"$x[4]\", \"user\":\"$x[5]\",\"domain\":\"$x[6]\" }\n";} '| gzip > as$ver.split.json

zcat as$ver.split.json  | python3 ~/docker/gather/authors.py WoC authors$ver > as$ver.split.json.bad


pVer=N
ver=O
#on beacon
for LA in jl F R PY JS C java Go Rust Cs pl Swift Erlang Scala Fml Lua rb sql php Cob 
do sed "s/VER/$ver/;s/MACHINE/beacon/;s/PART/first/;s/LANG/$LA/" /nics/b/home/audris/lookup/grepNew.pbs | qsub
done

#on da4
for LA in jl F R pl Scala Cs Rust Go PY JS C java  
do cd /da0_data/play/${LA}thruMaps/
for int in "{0..31}" "{32..63}" "{64..95}" "{96..127}" ; do for j in $(eval "echo $int"); do zcat b$pVer${LA}.$j.gz | lsort 3G -u | join -v2 - <(zcat b$ver$LA.$j.gz | lsort 3G -u) | gzip > b$ver$LA.$j.s1 & done; wait; done
for int in "{0..31}" "{32..63}" "{64..95}" "{96..127}" ; do for j in $(eval "echo $int"); do zcat b$ver${LA}.$j.s1 | ~/lookup/b2pkgsFast${LA}.perl $j 2> /dev/null |gzip > b$ver${LA}pkgs.$j.s1 &  done; wait; done
for int in "{0..31}" "{32..63}" "{64..95}" "{96..127}" ; do for j in $(eval "echo $int"); do zcat b$pVer${LA}pkgs.$j.gz b$ver${LA}pkgs.$j.s1 |gzip > b$ver${LA}pkgs.$j.gz &  done; wait; done
done

#on beacon
pVer=N
ver=O
for LA in jl F R PY JS C java Go Rust Cs pl Swift Erlang Scala Fml Lua rb sql php Cob 
do scp -p da0:/data/play/${LA}thruMaps/b$ver${LA}pkgs.*.gz .
sed "s/VER/$ver/;s/MACHINE/beacon/;s/PART/second/;s/LANG/$LA/" /nics/b/home/audris/lookup/grepNew.pbs | qsub
done

for LA in jl F R pl Scala Cs Rust Go PY JS C java  
do scp -p P2m$ver$LA m2nP$ver$LA.s c2bPtaPkg$ver$LA.*.gz da0:/data/play/${LA}thruMaps/
done 



#plot languages
LNGS="JS java PY C php Lisp Rust Scala rb Erlang Swift Go Lua Sql Cs R F jl Fml Cob"
for LA in $LNGS
do zcat c2ta$ver$LA.*.gz|awk -F\; '{print int($2/3600/24/365.25+1970)}' | lsort 10G | uniq -c > ${LA}$ver.trend
zcat c2ta$ver$LA.*.gz|awk -F\; '{print int($2/3600/24/365.25+1970)";"$3}' | lsort 10G | uniq | cut -d\; -f1 | uniq -c > ${LA}$ver.trendA
done
s="year";for LA in $LNGS; do s="$s;$LA";done; echo $s > cmts$ver.lng
for y in {2010..2019}; do s="$y";for LA in  $LNGS
do n=$(grep " $y$" ${LA}$ver.trend | awk '{print $1}'); s="$s;$n"; done; echo $s; done >> cmts$ver.lng
s="year";for LA in $LNGS; do s="$s;$LA";done; echo $s > cmts$ver.lng1
for y in {2010..2019}; do s="$y";for LA in $LNGS
do n=$(grep " $y$" ${LA}$ver.trendA | awk '{print $1}'); s="$s;$n"; done; echo $s; done >> cmts$ver.lng1

scp -p cmts$ver.{lng1,lng} *$ver.{trend,trendA}   da2:swsc/overview

x=read.table("cmtsO.lng1",sep=";",header=T);
y=read.table("cmtsO.lng",sep=";",header=T);
x[10,-1]=4*x[10,-1];
y[10,-1]=4*y[10,-1];
png("AuthorsByLanguageO.png",width=1000,height=750);
matplot(x[,1],x[,-1],type="o",lwd=1:3,lty=1:7,col=1:5,log="y",pch="0123456789abcdefghi",xlab="Years",ylab="Authors");
N=dim(x)[2]-1;
legend(2016.1,3e04,legend=names(x)[-1],lty=1:7,col=1:5,lwd=1:3,pch="0123456789abcdefghi",bg="white")
dev.off()
png("PrdByLanguageO.png",width=1000,height=750);
matplot(x[,1],y[,-1]/x[,-1],type="o",lwd=1:3,lty=1:7,col=1:5,log="y",pch="0123456789abcdefghi",xlab="Years",ylab="Cmghi");
legend(2016.1,1000,legend=names(x)[-1],lwd=1:3,lty=1:7,col=1:5,pch="0123456789abcdefghi",bg="white")
dev.off();

#most frequent reuse:
see grepNew.pbs
overview/deps/plot.r
LNGS1="C Cs F Go JS PY R Rust Scala java jl pl rb"
for LA in $LNGS1; do scp -p $ver$LA.* da0:/data/play/plots; done
scp -p cmts$ver.lng1 cmts$ver.lng *N.trend *N.trendA da0:/data/play/plots/

```

### Version N
```
cd /data/update
# 2019025
for r in {00..32} bioconductor.org bitbucket.org kde.org repo.or.cz sourceforge.net gitlab.com
do cd /data/update/M.$r 
   time ls -f *.tag.bin | ~/lookup/AllUpdateObj.perl tag
   time ls -f *.commit.bin | ~/lookup/AllUpdateObj.perl commit
   time ls -f *.tree.bin | ~/lookup/AllUpdateObj.perl tree
   time ls -f *.blob.bin | ~/lookup/AllUpdateObj.perl blob

   gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl /da0_data/basemaps/p2cFullM 32 | lsort 120G -u -t\; -k1b,2 | ~/lookup/splitSecCh.perl p2c. 32 
   for j in {0..31}; do gunzip -c p2c.$j.gz | awk -F\; '{print $2";"$1}'
   done | lsort 120G -u -t\; -k1b,2 | ~/lookup/splitSec.perl c2p. 32
done
for i in {0..127}; do ~/lookup/checkBin.perl commit /data/All.blobs/commit_$i 703111; done
for i in {0..127}; do ~/lookup/checkBin.perl tree /data/All.blobs/tree_$i 2579370; done
for i in {0..127}; do ~/lookup/checkBin.perl tag /data/All.blobs/tag_$i 30000; done
for i in {0..127}; do ~/lookup/checkBin.perl blob /data/All.blobs/blob_$i 2507276; done

for i in {0..127}; do ~/lookup/Obj2ContUpdt.perl commit $i 705111; done
for i in {0..127}; do ~/lookup/Obj2ContUpdt.perl tree $i 2579370; done

#prepare for processing
zcat asN.s | perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl -I /home/audris/lookup -ane 'use cmt; chop();@x=splitSignature($_);@n = split(/ /, $x[0]); @e = split(/\@/, $x[1]); print "$_;$x[0];$x[1];$n[0];$n[$#n];$e[0];$e[1]\n";' | gzip > asN.split
zcat asN.split | perl -ane 'chop();if ($_ !~ m/^;/){@x=split(/\;/, $_); for $i (0..$#x){ $x[$i] =~ s/"/'"'"'/g; } print "{ \"id\":\"$x[0]\", \"name\":\"$x[1]\", \"email\":\"$x[2]\", \"first\":\"$x[3]\", \"last\":\"$x[4]\", \"user\":\"$x[5]\",\"domain\":\"$x[6]\" }\n";} '| gzip > asN.split.json
zcat /home/audris/asN.split.json  | python3 ~/docker/gather/authors.py WoC authors > /home/audris/asN.split.json.bad
for i in {0..127}; do ~/lookup/lstCmt.perl 2 $i | cut -d\; -f2,4 | lsort 5G -u | gzip > a2mN$i.s; done
str="lsort 250G -t\; -k1b2 -u --merge"
for i in {0..127}; do str="$str <(zcat a2mN$i.s)"; done
eval $str | ~/lookup/splitSecCh.perl a2mN. 32
#do some cleaning: exclude single commit ids
zcat /data/basemaps/gz/a2mN.s| perl -e 'while(<STDIN>){chop();($a,$m)=split(/;/);$m2n{$m}++;}; while (($m,$v)=each %m2n){ print "$v;$m\n" if $v > 30; }' | gzip > /data/basemaps/gz/mFreqN.gz


for i in {0..31}; do zcat s10.$i.gz | ~/lookup/cmputeDiff2.perl 2> s10.new.$i.err | gzip > s10.$i.c2fb; done&
for i in {0..31}
do zcat s9.$i.c2fb | cut -d\; -f1 | uniq | gzip > s9.$i.got
  zcat s10.$i.c2fb | cut -d\; -f1 | uniq | gzip > s10.$i.got
  (zcat s9.$i.got| join -v2 - <(zcat s9.$i.gz); zcat s10.$i.got| join -v2 - <(zcat s10.$i.gz)) | lsort 1G -u > $i.left
  grep ^identical s9.new.$i.err s10.new.$i.err | sed 's/.* for //;s/ and.*//' | lsort 1G -u > $i.empty
  (zcat /data/basemaps/gz/badcs.$i; join -v1 $i.left $i.empty)  | lsort 1G -u > $i.try
  cat $i.try | ~/lookup/cmputeDiff2.perl 2>  $i.try.err | gzip > $i.try.c2fb
  (zcat /data/basemaps/gz/emptycs.$i; cat $i.empty; grep ^identical $i.try.err | sed 's/.* for //;s/ and.*//') | lsort 1G -u | gzip > /data/basemaps/gz/emptycsN.$i
  zcat $i.try.c2fb | cut -d\; -f1 | uniq | gzip > $i.try.got
  zcat $i.try.got | join -v2 -  $i.try | join -v1 - <(zcat  /data/basemaps/gz/emptycsN.$i) | gzip >  /data/basemaps/gz/badcsN.$i
  zcat /data/basemaps/gz/badcs.$i | join -v1 - <(zcat /data/basemaps/gz/badcsN.$i) | ~/lookup/cmputeDiff2.perl > /dev/null 2> check$i
  grep -v ^iden check$i |grep -v ^mdir | sed 's/.* for //' | uniq | gzip > /data/basemaps/gz/badcsPartialN.$i
done   



cd /data/update
# 201813
for r in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1
do cd $r 
  time ls -f *.tag.bin | ~/lookup/AllUpdateObj.perl tag
  time ls -f *.commit.bin | ~/lookup/AllUpdateObj.perl commit
  time ls -f *.tree.bin | ~/lookup/AllUpdateObj.perl tree
  time ls -f *.blob.bin |  ~/lookup/AllUpdateObj.perl blob
  cd ..
done

for r in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1
do cd /data/update/$r
   gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl /da0_data/basemaps/p2cFullK 32 ../p2cL 32 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | ~/lookup/splitSec.perl c2p. 32
   zcat p2c.s | ~/lookup/splitSecCh.perl p2c. 32   
   zcat c2p.s | cut -d\; -f1 | uniq | ~/bin/hasObj1.perl commit | gzip > cs.gz1
   cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs.gz
done

for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1; do str="$str <(zcat $i/p2c.$j.gz)"; done; eval $str | gzip > p2cM$j.s; done &
for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in BB.02 L.BB.03 L.18 L.19 L.20 L.21 L.22 L.23 L.24 L.GL.0 L.GL.1 L.SF L.SF.1; do str="$str <(zcat $i/c2p.$j.gz)"; done; eval $str | gzip > c2pM$j.s; done &
wait
cd /data/update/c2fb
zcat ../{BB.02,L.BB.03,L.18,L.19,L.20,L.21,L.22,L.23,L.24,L.GL.0,L.GL.1,L.SF,L.SF.1}/cs.gz | lsort 100G -u | ~/lookup/splitSec.perl s9. 32
for i in {0..15..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {1..15..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {2..15..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {3..15..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&

for i in {16..31..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {17..31..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {18..31..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
for i in {19..31..4}; do zcat s9.$i.gz | ~/lookup/cmputeDiff2.perl 2> s9.new.$i.err | gzip > s9.$i.c2fb; done&
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

for j in {0..31}; do zcat c2taF$ver$j.s | awk -F\; '{print $3 ";" $1}' | lsort 5G -t\; -k1b,2 | gzip > a2cF$ver$j.s & done
wait
str="$HOME/bin/lsort 50G -u --merge -t\; -k1b,2"
for j in {0..31}; do str="$str <(zcat a2cFull$ver$j.s)"; done
eval $str | perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/splitSecCh.perl a2cFull$ver 32
for j in {0..31}; do mv a2cFull$ver$j.gz a2cFull$ver$j.s; done
zcat a2cFull$ver*.s | cut -d\; -f1 | uniq | gzip > as$ver.gz
zcat as$ver.s | perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl -I /home/audris/lookup -ane 'use cmt; chop();@x=splitSignature($_);@n = split(/ /, $x[0]); @e = split(/\@/, $x[1]); print "$_;$x[0];$x[1];$n[0];$n[$#n];$e[0];$e[1]\n";' | gzip > as$ver.split

for j in {0..31..4}; do zcat a2cFull$ver$j.s |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &
for j in {1..31..4}; do zcat a2cFull$ver$j.s |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &
for j in {2..31..4}; do zcat a2cFull$ver$j.s |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &
for j in {3..31..4}; do zcat a2cFull$ver$j.s |perl -I ~/lookup -I ~/lib/x86_64-linux-gnu/perl  ~/lookup/Prj2CmtBinSorted.perl /fast/a2cFull$ver.$j.tch; done &


for i in {0..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl /fast/c2cc$ver $i | gzip > cnp$ver.$i; done &
for i in {1..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl c2cc$ver $i | gzip > cnp$ver.$i; done &
for i in {2..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl c2cc$ver $i | gzip > cnp$ver.$i; done &
for i in {3..31..4}; do perl -I ~/lib/x86_64-linux-gnu/perl -I ~/lookup ~/lookup/Cmt2Chld.perl c2cc$ver $i | gzip > cnp$ver.$i; done &


for j in {0..31..4}; do zcat c2pFull$ver$j.s | join -t\; - <(zcat c2taF$ver.$j.s) | awk -F\; '{ print $4";"$2}' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1b,2 -u | gzip > a2p$ver$j.s; done &
for j in {0..31}; do zcat a2p$ver$j.s | perl -I$HOME/lookup -I $HOME/lib/perl5 $HOME/lookup/splitSecCh.perl a2p$ver.$j. 32 & done
for j in {0..31}; do str="$HOME/bin/lsort ${maxM}M -t\; -k1b,2 --merge -u";   for i in {0..31};   do  str="$str <(zcat a2p$ver.$i.$j.gz)";   done;   eval $str > a2p$ver.$j.gz; done

for j in {0..31}; do zcat a2p$ver$j.s |  awk -F\; '{ print $2";"$1}' | perl -I$HOME/lookup -I $HOME/lib/perl5 $HOME/lookup/splitSecCh.perl p2a$ver.$j. 32 & done
wait
for j in {0..31}; do for i in {0..31};   do $HOME/bin/lsort ${maxM}M -t\; -k1b,2 <(zcat p2a$ver.$i.$j.gz) | gzip > p2a$ver.$i.$j.s &   done;   wait; done
for j in {0..31}; do str="lsort 8G -t\; -k1b,2 -u --merge"; for i in {0..31}; do str="$str <(zcat p2a$ver.$i.$j.s)"; done; eval $str | gzip > p2a$ver$j.s & done

for j in {0..31}; do zcat a2p$ver$j.s |  perl ~/lookup/mp.perl 1 c2pFull$ver.forks | lsort 30G -t\; -k1b,2 -u | gzip > a2P$ver$j.s; done

for j in {0..31}; do zcat p2a$ver$j.s |  perl ~/lookup/mp.perl 0 c2pFull$ver.forks | perl -I$HOME/lookup -I $HOME/lib/perl5 $HOME/lookup/splitSecCh.perl P2a$ver.$j. 32; done
for j in {0..31}; do for i in {0..31};   do $HOME/bin/lsort ${maxM}M -t\; -k1b,2 <(zcat P2a$ver.$i.$j.gz) | gzip > P2a$ver.$i.$j.s &   done;   wait; done
for j in {0..31}; do str="lsort 8G -t\; -k1b,2 -u --merge"; for i in {0..31}; do str="$str <(zcat P2a$ver.$i.$j.s)"; done; eval $str | gzip > P2a$ver$j.s & done


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
   gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl /da0_data/basemaps/p2cFullJK 32 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | ~/lookup/splitSec.perl c2p. 32
   zcat p2c.s | ~/lookup/splitSecCh.perl p2c. 32   
   zcat c2p.s | cut -d\; -f1 | uniq | ~/bin/hasObj1.perl commit | gzip > cs.gz1
   cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs.gz
done

for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in $(ls -fd L.[01][0-9] BB.00 BB.01); do str="$str <(zcat $i/p2c.$j.gz)"; done; eval $str | gzip > p2cL$j.s; done &
for j in {0..31}; do str="$HOME/bin/lsort 120G -u --merge -t\; -k1b,2"; for i in $(ls -fd L.[01][0-9] BB.00 BB.01); do str="$str <(zcat $i/c2p.$j.gz)"; done; eval $str | gzip > c2pL$j.s; done &


cd ../c2fb
zcat ../L.0[0-5]/cs.gz | lsort 100G -u | ~/lookup/splitSec.perl s8a. 32

zcat ../L.{0[6-9],1[0-7]}/cs.gz | lsort 100G -u | ~/lookup/splitSec.perl s8b. 32
for i in {00..31}
do zcat s8a.$i.gz | ~/lookup/cmputeDiff2.perl 2> s8a.new.$i.err | gzip > s8a.$i.c2fb
   zcat s8b.$i.gz | ~/lookup/cmputeDiff2.perl 2> s8b.new.$i.err | gzip > s8b.$i.c2fb
   zcat s8c.$i.gz | ~/lookup/cmputeDiff2.perl 2> s8c.new.$i.err | gzip > s8c.$i.c2fb
   zcat s8d.$i.gz | ~/lookup/cmputeDiff2.perl 2> s8d.new.$i.err | gzip > s8d.$i.c2fb
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
ver=N
LNGS="JS java PY C php Lisp Rust Scala rb Swift Go Lua Sql Cs R F jl Fml Cob"
for LA in $LNGS
do zcat c2ta$ver$LA.*.gz|awk -F\; '{print int($2/3600/24/365.25+1970)}' | lsort 10G | uniq -c > ${LA}$ver.trend
zcat c2ta$ver$LA.*.gz|awk -F\; '{print int($2/3600/24/365.25+1970)";"$3}' | lsort 10G | uniq | cut -d\; -f1 | uniq -c > ${LA}$ver.trendA
done
s="year";for LA in $LNGS; do s="$s;$LA";done; echo $s > cmts$ver.lng
for y in {2010..2018}; do s="$y";for LA in  $LNGS
do n=$(grep " $y$" ${LA}$ver.trend | awk '{print $1}'); s="$s;$n"; done; echo $s; done >> cmts$ver.lng
s="year";for LA in $LNGS; do s="$s;$LA";done; echo $s > cmts$ver.lng1
for y in {2010..2018}; do s="$y";for LA in $LNGS
do n=$(grep " $y$" ${LA}$ver.trendA | awk '{print $1}'); s="$s;$n"; done; echo $s; done >> cmts$ver.lng1

x=read.table("cmtsN.lng1",sep=";",header=T)
y=read.table("cmtsN.lng",sep=";",header=T)
png("AuthorsByLanguageN.png",width=1000,height=750);
matplot(x[,1],x[,-1],type="o",lwd=1:3,lty=1:7,col=1:5,log="y",pch="0123456789abcdefghi",xlab="Years",ylab="Authors");
N=dim(x)[2]-1;
legend(2016.1,1e04,legend=names(x)[-1],lty=1:7,col=1:5,lwd=1:3,pch="0123456789abcdefghi",bg="white")
dev.off()
png("PrdByLanguageN.png",width=1000,height=750);
matplot(x[,1],y[,-1]/x[,-1],type="o",lwd=1:3,lty=1:7,col=1:5,log="y",pch="0123456789abcdefghi",xlab="Years",ylab="Cmghi");
legend(2016.1,1000,legend=names(x)[-1],lwd=1:3,lty=1:7,col=1:5,pch="0123456789abcdefghi",bg="white")
dev.off();

#most frequent reuse:
see grepNew.pbs
overview/deps/plot.r
LNGS1="C Cs F Go JS PY R Rust Scala java jl pl rb"
for LA in $LNGS1; do scp -p $ver$LA.* da0:/data/play/plots; done
scp -p cmts$ver.lng1 cmts$ver.lng *N.trend *N.trendA da0:/data/play/plots/


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
   gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl /data/basemaps/p2cFullJ 32 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | ~/lookup/splitSec.perl c2p. 32
   zcat p2c.s | ~/lookup/splitSecCh.perl p2c. 32   
   cut -d\; -f4 *.commit.idx | lsort 20G -u | gzip > cs.gz
done
for i in {00..11} 
do cd /data/update/new.$i
   gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl /data/basemaps/p2cFullJ 32 ../p2cKb | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   zcat c2p.s | ~/lookup/splitSec.perl c2p. 32
   zcat p2c.s | ~/lookup/splitSecCh.perl p2c. 32
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
do zcat cmts.s6a.new.$i.gz | ~/lookup/cmputeDiff2.perl 2> cmts.s6a.new.$i.err | gzip > cmts.s6a.new.$i.c2fb
done
# See  Create c2fb below using cmts.s6a and Inc20181110
for i in updt.08 updt.09 updt.10 updt.11 updt.12 updt.13 new.00 new.01; do zcat $i/cs.gz; done |  lsort 20G -u |gzip > cs.20181110.b
zcat cmts.s6a | lsort 10G -u --merge - <(zcat cs.20181110.b) | gzip > cmts.s6b
zcat cmts.s6a | join -v2 - <(zcat cs.20181110.b) | gzip > cmts.s6b.new
zcat cmts.s6b.new | split -l 2075511 -d -a 2 --filter='gzip > $FILE.gz' - /data/update/c2fb/cmts.s6b.new. 
cd /data/update/c2fb/
for i in {00..22}
do zcat cmts.s6b.new.$i.gz | ~/lookup/cmputeDiff2.perl 2> cmts.s6b.new.$i.err | gzip > cmts.s6b.new.$i.c2fb
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

#Clean c2f: determine whats up with missing commits

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
gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl p2cFullI 32 | gzip > p2c.gz
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
   gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl /data/basemaps/Prj2CmtH 8 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
   cut -d\; -f4 *.commit.idx | lsort 20G -u > cs
done
cd ../
zcat {emr,gl,withDnld}/cs | lsort 50G -u | gzip > cs.20180710
zcat /data/basemaps/cmts.s3 | lsort 10G -u --merge - <(zcat cs.20180710) | gzip > /data/basemaps/cmts.s4
zcat /data/basemaps/cmts.s3 | join -v2 - <(zcat cs.20180710) | gzip > /data/basemaps/cmts.s4.new
zcat /da4_data/basemaps/cmts.s4.new | split -l 2075511 -d -a 2 --filter="gzip ? $FILE.gz" - cmts.s4.new. 

lsort 20G -t\; -k1b,2 --merge <(gunzip -c emr/p2c.s) <(gunzip -c withDnld/p2c.s) <(gunzip -c gl/p2c.s|awk '{print "gl_"$0}') | uniq | ~/lookup/splitSecCh.perl Inc20180710.p2c. 8
lsort 20G -t\; -k1b,2 --merge <(gunzip -c emr/c2p.s) <(gunzip -c withDnld/c2p.s) <(gunzip -c gl/c2p.s|sed 's/;/;gl_/') | uniq | ~/lookup/splitSec.perl Inc20180710.c2p. 8


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

   gunzip -c *.olist.gz | ~/lookup/Prj2CmtChk.perl /data/basemaps/Prj2CmtH 8 | gzip > p2c.gz
   gunzip -c p2c.gz   | lsort 120G -u -t\; -k1b,2 | gzip > p2c.s
   gunzip -c p2c.gz | awk -F\; '{print $2";"$1}' | lsort 120G -u -t\; -k1b,2 | gzip > c2p.s
done
cd /data/update
lsort 20G -t\; -k1b,2 --merge <(gunzip -c with/p2c.s) <(gunzip -c withFrk/p2c.s) <(gunzip -c withWch/p2c.s) <(gunzip -c withIssues/p2c.s) <(gunzip -c chris/p2c.s) <(gunzip -c chrisB/p2c.s) <(gunzip -c py/p2c.s)  | uniq | ~/lookup/splitSecCh.perl Inc20180510.p2c. 8

lsort 20G -t\; -k1b,2 --merge <(gunzip -c with/c2p.s) <(gunzip -c withFrk/c2p.s) <(gunzip -c withWch/c2p.s) <(gunzip -c withIssues/c2p.s) <(gunzip -c chris/c2p.s) <(gunzip -c chrisB/c2p.s) <(gunzip -c py/c2p.s)  | uniq | ~/lookup/splitSec.perl Inc20180510.c2p. 8

```
1. Verify input is good
```
   for t in commit blob tree tag; do ls -f *.$t.idx | sed 's/\.idx$//' | while read i; do ~/lookup/checkBin1in.perl $t $i; done; done
```
1. Update da4:/data/All.blobs

```
   ls -f *.commit.bin | ~/lookup/AllUpdateObj.perl commit
   ls -f *.tree.bin | ~/lookup/AllUpdateObj.perl tree
   ls -f *.blob.bin |  ~/lookup/AllUpdateObj.perl blob
   ls -f *.tag.bin | ~/lookup/AllUpdateObj.perl tag
```
1. Verify it worked (up to 4K (or more if needed) records
```		
   for i in {0..127}; do ~/lookup/checkBin.perl commit /data/All.blobs/commit_$i 10000; done
   for i in {0..127}; do ~/lookup/checkBin.perl tree /data/All.blobs/tree_$i 10000; done
   for i in {0..127}; do ~/lookup/checkBin.perl tag /data/All.blobs/tag_$i 10000; done
   for i in {0..127}; do ~/lookup/checkBin.perl blob /data/All.blobs/blob_$i 10000; done
```
1. Update All.sha1c commit and tree needed for c2fb and cmptDiff2.perl
```
   nmax=2000000
   #  1475976;
   for i in {0..127}; do ~/lookup/Obj2ContUpdt.perl commit $i $nmax; done
   nmax=8227751
   for i in {0..127}; do ~/lookup/Obj2ContUpdt.perl tree $i $nmax; done
```
1. Update All.sha1o needed for f2b tree-based stuff
```
	for i in {0..127}; do ~/lookup/BlobN2Off.perl $i; done
```
1. Update Author to commit map
```
#~/lookup/Auth2Cmt.perl /data/basemaps/Auth2CmtNew.tch
# The above may be more correct
# 394525: how much back to go from the end of All.blobs/commit_X.idx
#time ~/lookup/Auth2CmtUpdt.perl Auth2CmtNew 394525
#time ~/lookup/Auth2CmtMrg.perl Auth2CmtNew Auth2CmtNew.new Auth2CmtH
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
 ~/lookup/splitSec.perl Inc20180710.c2f. 32

#J contains extra (see below)
for j in {0..31}; do 
  zcat Inc20180710.c2f.$j.gz |sed 's|;/|;|' | lsort 30G -t\; -k1b,2 | gzip > Inc20180710.c2f.$j.s
  lsort 10G --merge -u -t\; -k1b,2 <(zcat c2fFullJ$j.s) \ 
  <(zcat Inc20180710.c2f.$j.s| cut -d\; -f1,2 | uniq) | \
    gzip > c2fFullI$j.s
  zcat c2fFullI$j.s | ~/lookup/Cmt2FileBinSorted.perl c2fFullI.$j.tch 1
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
(j=0; lsort 10G --merge -u -t\; -k1b,2 <(zcat /data/basemaps/gz/c2fFullH$j.s)  <(zcat ~/update/c2fb/cmts.s.extra.c2fb.$j.gz| cut -d\; -f1,2 | sed 's|;/|;|') |perl -I ~/lib64/perl5/ -I ~/lookup/ -e 'use cmt; while(<STDIN>){ ($c, @r) = split(/;/); print $_ if ! defined $badCmt{$c};}' | gzip > /data/basemaps/gz/c2fFullJ$j.s) &

##################################
#cut -d\; -f4 /data/All.blobs/commit_*.idx | lsort 40G | gzip > /data/basemaps/cmts.s1
gunzip -c /data/basemaps/cmts.s | join -v1 <(gunzip -c /data/basemaps/cmts.s1) - | gzip > /data/basemaps/cmts.s1.new
gunzip -c cmts.s1.new | split -l 2075511 -d -a2 --filter='gzip > $FILE.gz' - cmts.s1.new.
#this takes a while and requires All.sha1c/{commit,tree}_{0..127}.tch
for i in {00..99}
do gunzip -c cmts.s1.new.$i.gz | ~/lookup/cmputeDiff2.perl 2> cmts.s1.new.$i.err | gzip > cmts.s1.new.$i.c2fb
done

#now put all of that good into one place
zcat cmts.s[1-3].new.*.c2fb | ~/lookup/splitSec.perl /data/update/Inc20180510.c2f. 8 
cd /data/update

#now create c2f and b2c (potentially using debugging from below)
for j in {0..7}; do 
  zcat Inc20180510.c2f.$j.gz | lsort 80G -t\; -k1b,2 | gzip > Inc20180510.c2f.$j.s
  lsort 10G --merge -u -t\; -k1b,2 <(zcat /data/basemaps/gz/c2fFullF$j.s) \ 
    <(zcat Inc20180510.c2f.$j.s| cut -d\; -f1,2 | sed 's|;/|;|') | gzip > /data/basemaps/gz/c2fFullH$j.s
  zcat /da4_data/basemaps/gz/c2fFullH$j.s | ~/lookup/Cmt2FileBin.perl /da4_data/basemaps/c2fFullH.$j.tch 1
done

zcat cmts.s[1-3].new.*.c2fb | cut -d\; -f1,3 | grep -v '^;'| grep -v '^$' | awk -F\; '{ print $2";"$1}' | \
  ~/lookup/splitSec.perl /data/update/Inc20180510.b2c. 16 
for j in {0..15}; do
   zcat /data/update/Inc20180510.b2c.$j.gz| grep -v '^;' | grep -v '^$' | lsort 20G -t\; -k1b,2 | gzip > /data/update/Inc20180510.b2c.$j.s
   lsort 10G --merge -u -t\; -k1b,2 <(zcat /da4_data/basemaps/gz/b2cFullF$j.s) <(zcat /da4_data/update/Inc20180510.b2c.$j.s) |
     gzip > /data/basemaps/gz/b2cFullH$j.s
   zcat /data/basemaps/gz/b2cFullH$j.s | awk -F\; '{print $1";;"$2}'| ~/lookup/Cmt2BlobBin.perl /da4_data/basemaps/b2cFullH.$j.tch 1 
done

#finally invert c2f to f2c and b2c to c2b
for i in {0..7}; do 
  gunzip -c /da4_data/update/Inc20180510.c2f.$i.s
done | perl -I ~/lookup -I ~/lib64/perl5 -ane 'use cmt;@x=split(/\;/);next if defined $badCmt{$x[0]}; print;' |\
  awk -F\; '{print $2";"$1}' | ~/lookup/splitSecCh.perl Inc20180213.f2c. 8 &

for i in {0..7}; do zcat /da4_data/update/Inc20180510.c2f.$i.s; done | perl -I ~/lookup -I ~/lib64/perl5 \
   -ane 'use cmt;s|;/|;|;@x=split(/\;/);next if defined $badCmt{$x[0]}; print;' | \
   awk -F\; '{print $2";"$1}' | ~/lookup/splitSecCh.perl Inc20180510.f2c. 8 &
for i in {0..7}; do   lsort 30G --merge -u -t\; -k1b,2 <(zcat Inc20180510.f2c.$i.gz|lsort 5G -u  -t\; -k1b,2) \
      <(zcat /da4_data/basemaps/gz/f2cFullF$i.s) | \
    gzip > f2cFullH$i.s
    gunzip -c f2cFullH$i.s | awk -F\; '{print $2";"$1}' | ~/lookup/File2CmtBin.perl f2cFullH.$i.tch 1 
done

for i in {0..15}; do gunzip -c /da4_data/basemaps/gz/b2cFullH$i.s; done | perl -I ~/lookup -I ~/lib64/perl5 \
   -ane 'use cmt;@x=split(/\;/);next if defined $badCmt{$x[1]} || defined $badBlob{$x[0]}; print;' | \
  awk -F\; '{print $2";"$1}' | ~/lookup/splitSec.perl c2bFullH 16
for i in {0..15}; do gunzip -c c2bFullH$i.gz | awk -F\; '{print $1";;"$2}'| ~/lookup/Cmt2BlobBin.perl c2bFullH.$i.tch 1
done

```

1. Update various maps
```
cd /data/basemaps
~/lookup/Auth2File.perl Auth2CmtH.tch /fast1/All.sha1c/c2fFullH Auth2FileH.tch 

#the following is slow: needs > 250G of ram
~/lookup/Cmt2Par.perl /data/basemaps/Cmt2Chld.tch

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
lsort 10G -t\; -k1b,2 -u --merge <(gunzip -c CRAN/c2p.CRAN.gz)  <(gunzip -c secure/c2p.secure.gz) <(gunzip -c cve/c2p.cve.gz) <(gunzip -c js/c2p.js.gz) | ~/lookup/splitSec.perl Inc20180213.c2p. 8


#debug: look for missing commits/trees

for i in CRAN cve secure js
do cd $i
  gunzip -c c2p.$i.gz | cut -d\; -f1 | lsort 10G -u | gzip > c.$i.cs
  gunzip -c c.$i.cs | ~/lookup/splitSec.perl c.$i.cs. 8 
  cd ..
done
for j in {0..7}
do for i in CRAN cve secure js bbnew
  do gunzip -c $i/c.$i.cs.$j.gz
  done | lsort 10G -u  |gzip > Inc20180213.c2f.$j.gz
done
for j in {0..7}; do gunzip -c /data/basemaps/gz/c2fFullE$j.s | cut -d\; -f1 | uniq | join -v2 - <(gunzip -c Inc20180213.c2f.$j.gz) | gzip > Inc20180213.c2f.$j.todo & done
for j in {0..7} 
do gunzip -c Inc20180213.c2f.$j.todo | ~/lookup/cmputeDiff2.perl 2> Inc20180213.c2f.$j.err | gzip > Inc20180213.c2f.$j.c2fb &
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
cat Inc20180213.c2f.bad | ~/lookup/cmputeDiff2.perl 2> /dev/null >  Inc20180213.c2f.bad.c2fb
wc -l Inc20180213.c2f.bad.c2fb
join -v1 Inc20180213.c2f.new Inc20180213.c2f.in | join -v1 - Inc20180213.c2f.bad > Inc20180213.c2f.empty
#verify empty
cat Inc20180213.c2f.empty | ~/lookup/cmputeDiff2.perl

#now update empty, nt, bad
#empty
lsort 10G -u --merge <(gunzip -c /data/basemaps/empty.cs) Inc20180213.c2f.empty | gzip > /data/basemaps/empty.cs1
mv /data/basemaps/empty.cs1 /data/basemaps/empty.cs

#nt
#did we find any new trees
gunzip -c /data/basemaps/nt.ts | ~/lookup/showTree.perl -1 | sort -u > Inc20180213.c2f.ts
lsort 10G -u --merge <(gunzip -c /data/basemaps/nt.ts) Inc20180213.nt | join -v1 - Inc20180213.c2f.ts | gzip > /data/basemaps/nt.ts1
#make sure all are missing
gunzip -c /data/basemaps/nt.ts1 | ~/lookup/showTree.perl -1
mv /data/basemaps/nt.ts1 /data/basemaps/nt.ts

# bad
lsort 10G -u --merge <(gunzip -c /data/basemaps/bad.cs) Inc20180213.c2f.bad | gzip > /data/basemaps/bad.cs1
gunzip -c  /data/basemaps/bad.cs1 | ~/lookup/cmputeDiff2.perl 2> /dev/null > seeIfBad
cut -d\; -f1 seeIfBad | uniq | lsort 10G -u | join -v1 - Inc20180213.c2f.in > Inc20180213.c2f.in.extra
grep -Ff Inc20180213.c2f.in.extra seeIfBad | ~/lookup/splitSec.perl Inc20180213.c2f.extra. 8

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
cd ~/delta
~/lookup/lstCmt.perl 1 | gzip > /da3_data/delta/cmt.lst


gunzip -c /da4_data/update/Inc20180213.c2f.[0-7].gz |uniq | ~/lookup/showCmt.perl 1 | gzip > Inc20180213.delta
#gunzip -c /da4_data/update/Inc20180213.c2p.[0-7].gz | cut -d\; -f1 | uniq | ~/lookup/showCmt.perl 1 | gzip > Inc20180213.delta
gunzip -c Inc20180213.delta | perl -I ~/lib64/perl5/ deltaHash.perl
perl -I ~/lib64/perl5 /home/audris/bin/listTC.perl delta.tch 1 | gzip > delta.id2content.gz

cat delta.idx | perl -ane 'chop();@x=split(/\;/, $_,-1); $c=$x[2];next if length($c) != 40 || "$c" =~ /[^0-9a-f]/;print "$c;$x[0];$x[1]\n";' | uniq | lsort 130G -u -t\; -k1b,2 |gzip > delta.idx.37.c2mid
lsort 20G --merge -t\; -k1b,2 -u <(gunzip -c delta.idx.37.c2mid) <(gunzip -c delta.idx.c2mid) | gzip > delta.idx.c2mid1
mv delta.idx.c2mid1 delta.idx.c2mid

# ? gunzip -c /da3_data/delta/delta.idx.c2mid | sed 's/;/;;;/' | perl ~/lookup/Cmt2PrjBinSorted.perl mid2cmt.tch 1
# ? gunzip -c /da3_data/delta/delta.idx.c2mid | awk -F\; '{print $2";"$1}' | ~/lookup/File2CmtBin.perl delta.idx.mid2c 1
gunzip -c delta.id2content.gz | grep -iw cve > ALLCVEs
cut -d\; -f1 ALLCVEs | gzip > ALLCVEs.ids
gunzip -c delta.idx.c2mid | ~/bin/grepField.perl ALLCVEs.ids 2 | cut -d\; -f1 | gzip > ALLCVEs.cs
gunzip -c ALLCVEs.cs | ~/lookup/showCmt.perl 2> CVEbadcmt | gzip > CVECommitInfo
gunzip -c ALLCVEs.cs | ~/lookup/Cmt2PrjShow.perl /da4_data/basemaps/Cmt2PrjG 1 8 | gzip > ALLCVEs.c2p
gunzip -c ALLCVEs.cs | ~/lookup/Cmt2PrjShow.perl /da4_data/basemaps/c2fFullF 1 8 | gzip > ALLCVEs.c2f
gunzip -c ALLCVEs.cs | ~/lookup/Cmt2BlobShow.perl /da4_data/basemaps/c2bFullE 1 16 | gzip > ALLCVEs.c2b
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




