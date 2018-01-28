#swich away to c2fb and Cmt2Prj
#get commits in All.blobs
cd /da0_data/c2fbp
cut -d\; -f4 /data/All.blobs/commit_*.idx | lsort 40G | gzip > /data/basemaps/cmts.s

#get commits from All.blobs that are not in c2fbp.00-81 and that are in
gunzip -c cmts.s | perl -ane 'chop(); next if length($_) != 40;print "$_\n";' | join -v1 - <(gunzip -c /da0_data/c2fbp/cs.s) | gzip >/data/basemaps/cNotInC2fbp.s
gunzip -c cmts.s | join -v1 - <(gunzip -c cNotInC2fbp.s) | gzip > cInC2fbp.s
gunzip -c /data/basemaps/cNotInC2fbp.s | split -l 200000 -d -a 3 --filter='gzip > $FILE.gz' - cNot.
gunzip -c /data/basemaps/cInC2fbp.s | split -l 1000000 -d -a 3 --filter='gzip > $FILE.gz' - cIn.

# collect all commits in call
# collect commits from olist files (see #Prj2Cmt.sh)
#add them to the full list
lsort 20G -u --merge <(gunzip -c /da0_data/c2fbp/os.p2c.000-890.cs) <(gunzip -c /da4_data/basemaps/cmts.s) <(gunzip -c /da4_data/basemaps/cs.s) | gzip > call.cs
# empty.cs have no files changed, bad.cs have tree or parent missing, and nc.cs are simply missing and need to be extrcted


#Produce tch
#c2f, f2c
gunzip -c c2fFullE[0-7].gz | awk -F\; '{print $2";"$1}' | /da3_data/lookup/splitSec.perl f2cFullE. 8
for i in {0..7}
do gunzip -c /da0_data/c2fbp/c2fFullE$i.gz | /da3_data/lookup/Cmt2FileBin.perl c2fFullE.$i 1
   gunzip -c /da0_data/c2fbp/f2cFullE.$i.gz | awk -F\; '{print $2";"$1}' | /da3_data/lookup/File2CmtBin.perl f2cFullE.$i 1 &
done

#c2b,b2c
gunzip -c b2cFullE[0-7].s | awk -F\; '{print $2";"$1}' | /da3_data/lookup/splitSec.perl c2bFullE. 16
for i in {0..15}
do gunzip -c /da4_data/basemaps/gz/c2bFullE$i.gz | awk -F\; '{print $1";;"$2}'| /da3_data/lookup/Cmt2BlobBin.perl c2bFullE.$i.tch 1 & done
   gunzip -c /da4_data/basemaps/gz/b2cFullE$i.s | awk -F\; '{print $1";;"$2}'| /da3_data/lookup/Cmt2BlobBinSorted.perl b2cFullE.$i.tch 1 & done
done


#When updatig do two things
#1) extract project to commit map from olist
#2) run ./cmputeDiff2.perl to create additional c2fb
#3) get c2f, b2c from these new c2fb
#4) merge with  b2cFullX and c2fFullX
#5) produce b2cFullX and c2fFullX tch
#6) invert b2cFullX and c2fFullX with splitSec.perl
#7) produce c2bFullX and f2cFullX tch

###################################
#everything below is old stuff
###################################

#lsort 50G -t\; -k1b,2 --merge -u <(gunzip -c b2c.00-19.s) <(gunzip -c b2c.20-39.s) <(gunzip -c b2c.40-59.s) <(gunzip -c b2c.60-81.s) <(gunzip -c b2cN.000-614.gz) | /da3_data/lookup/splitSec.perl b2cFull 16 &
#for i in {0..15}; do gunzip -c b2cFull$i.gz | sed 's/;/;;/' | /da3_data/lookup/Cmt2BlobBinSorted.perl b2cFull.$i 1 & done


#check if c2fFullE.cs is complete
gunzip -c call.cs | join -v1 - <(gunzip -c /da0_data/c2fbp/c2fFullE.cs) | join -v1 - <(gunzip -c empty.cs) | join -v1 - <(gunzip -c nc.cs) | join -v1 - <(gunzip -c bad.cs) | gzip > call.cs.extra
#should be empty set if complete

#compare with c2fbp
cmd=$(echo "lsort 50G --merge -u -t\; -k1b,2"; ls -f c2f.[0-8][0-9].s| while read i; do echo " <(gunzip -c $i)"; done)
eval $cmd | gzip > c2f.00-81.s1
for i in {0..7}; do
  lsort 50G -t\; -k1b,2 -u --merge <(gunzip -c c2f.00-81.s1.$i.gz) <(gunzip -c c2fFullE$i.gz) | gzip > c2fFullF$i.gz &
done





#compare with all olist files
cmd1=$(echo "lsort 50G --merge -u -t\; -k1b,2"; ls -f os.p2c.*| while read i; do echo " <(gunzip -c $i)"; done)
#lsort 50G --merge -u -t\; -k1b,2 <(gunzip -c os.p2c.000-249.gz|cut -d\; -f1|uniq) <(gunzip -c os.p2c.250-499.gz|cut -d\; -f1|uniq) <(gunzip -c os.p2c.500-749.gz|cut -d\; -f1|uniq) <(gunzip -c os.p2c.750-799.gz|cut -d\; -f1|uniq) <(gunzip -c os.p2c.800-849.gz|cut -d\; -f1|uniq) <(gunzip -c os.p2c.850-890.gz|cut -d\; -f1|uniq)
eval $cmd1 | gzip > os.p2c.000-890.cs 
gunzip -c os.p2c.000-890.cs |lsort 120G -u | gzip > os.p2c.000-890.cs1
mv os.p2c.000-890.cs1 os.p2c.000-890.cs
gunzip -c os.p2c.000-890.cs | join -v1 - <(gunzip -c c2fFullE.cs) | gzip > c2fFullE.cs.miss2 
gunzip -c c2fFullE.cs.miss2| join -v1 - <(gunzip -c c2fFullE.cs.empty) | gzip > c2fFullE.cs.miss2.valid
#now investigate where these commits got lost (since they are in the olist)
#compare with cmts.s
gunzip -c /da4_data/basemaps/cmts.s  | join -v1 - <(gunzip -c c2fFullE.cs) | gzip > c2fFullE.cs.miss0
gunzip -c c2fFullE.cs.miss0 | join -v1 - <(gunzip -c c2fFullE.cs.bad) | gzip > c2fFullE.cs.miss


##############
gunzip -c c2fFullC.cs.miss | ./splitSec.perl c2fFullC.cs.miss. 8
for i in {0..7}; do
    gunzip -c c2fFullC.cs.miss.$i.gz | ./cmputeDiff2.perl 2> c2fFullC.cs.miss.$i.err | gzip > c2fFullC.cs.miss.$i.c2fb
done
for i in {0..7}; do
    gunzip -c c2fFullC.cs.miss.$i.c2fb | perl -ane '@x=split(/;/, $_, -1);$x[1]=~s|^/*||;print "$x[0];$x[1]\n";' | \
	gzip > c2fN.miss1.$i.gz
done
(gunzip -c c2fFullC.cs.bad; for i in {0..7}; do cat c2fFullC.cs.miss.$i.err | grep '^no ' | sed 's/.* for //'; done) | sort -u | gzip > c2fFullC.cs.bad1
mv c2fFullC.cs.bad1 c2fFullD.cs.bad
for i in {0..7}; do
    gunzip -c c2fFullC.cs.miss.$i.gz | join -v1 -t\; - <(gunzip -c c2fN.miss1.$i.gz|cut -d\; -f1|uniq)
done | lsort 30G -u | join -v1 -t\; - <(gunzip -c c2fFullD.cs.bad) | gzip >  c2fFullD.cs.empty
for i in {0..7}; do lsort 50G -t\; -k1b,2 -u --merge <(gunzip -c c2fN.miss1.$i.gz) <(gunzip -c c2fFullC$i.gz) | gzip > c2fFullD$i.gz & done

for i in {0..7}; do gunzip -c c2fFullD5.gz| cut -d\; -f1 | uniq | gzip > c2fFullD$i.cs; done
cmd=$(echo "lsort 50G --merge -u -t\; -k1b,2"; ls -f c2fFullD?.cs| while read i; do echo " <(gunzip -c $i)"; done)
eval $cmd | gzip > c2fFullD.cs &
gunzip -c c2fFullD.cs | join -v2 - <(gunzip -c /da4_data/basemaps/cmts.s) | gzip > c2fFullD.cs.miss
#make sure nothing is missing
gunzip -c c2fFullD.cs.miss | join -v1 - <(gunzip -c c2fFullD.cs.empty) | join -v1 - <(gunzip -c c2fFullD.cs.bad)

#what is extra stuff?
gunzip -c /da4_data/basemaps/cmts.s | join -v2 - <(gunzip -c c2fFullD.cs) | gzip > c2fFullD.cs.extra
#Ok all from c2fbp
gunzip -c c2fFullD.cs.extra | join -v1 - <(gunzip -c /da4_data/basemaps/cs.s)
#any missing from c2fbp?
gunzip -c /da4_data/basemaps/cs.s | join -v1 - <(gunzip -c c2fFullD.cs) | gzip > c2fFullD.cs.miss1 
gunzip -c /da4_data/basemaps/c2f.00-81.s | join -t\; - <(gunzip -c c2fFullD.cs.miss1) | gzip > c2fFullD.cs.miss1.c2f


gunzip -c os.p2c.000-890.cs1 | join -v1 - <(gunzip -c c2fFullD.cs) | gzip > c2fFullD.cs.miss2
gunzip -c c2fFullD.cs.miss2| join -v1 - <(gunzip -c c2fFullD.cs.empty) | join -v1 - <(gunzip -c c2fFullD.cs.bad) | gzip > c2fFullD.cs.miss2.valid


gunzip -c c2fFullD$i.gz |   /da3_data/lookup/Cmt2FileBin.perl c2fFullD.$i 1 &

for i in {000..614}
do
 # the following takes forever but more accurate (still needs improvements)
 # gunzip -c cNotInC2fbp.$i.gz | /da3_data/lookup/cmputeDiff.perl 2> c2fb.$i.err | gzip > c2fb.$i.gz &
 gunzip -c cNot.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> cNot.$i.err | gzip > cNot.$i.c2fb1 &
done 

for i in {000..614}; do cat cNot.$i.err; done | gzip > cNotInC2fbp.err
#3M missing
gunzip -c cNotInC2fbp.err | grep '^no tree:' | sed 's/^no tree://;s/ for .*//' | lsort -30G -u | gzip > cNotInC2fbp.treemiss
# 1M missing 232K in cs.s, so the project can be deduced
gunzip -c cNotInC2fbp.err | grep '^no parent commit: ' | sed 's/^no parent commit: //;s/ for .*//' | lsort 30G -u | gzip > cNotInC2fbp.pcmtmiss
# 10M have problem
gunzip -c cNotInC2fbp.err | grep '^no ' | sed 's/.* for //' | sed 's/.* of //' | lsort 30G -u | gzip > cNotInC2fbp.cmtprob

#redo with updated trees!
gunzip -c cNotInC2fbp.cmtprob | /da3_data/lookup/splitSec.perl cNotInC2fbp.cmtprob. 8
for i in {0..7}
do gunzip -c cNotInC2fbp.cmtprob.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> cNot.error.$i.err | gzip > cNot.error.$i.c2fb & done
for i in {0..7}; do
    gunzip -c cNot.error.$i.c2fb | perl -ane '@x=split(/;/, $_, -1);$x[1]=~s|^/*||;print "$x[0];$x[1]\n";' | \
	 gzip > c2fN.error.$i.gz &
done
cat cNot.error.$i.err | grep '^no ' | sed 's/.* for //' | sed 's/.* of //' | lsort 30G -u | gzip > cNotInC2fbp.cmtprob1
gunzip -c cNotInC2fbp.cmtprob1 | wc
 948537 
# down to < 1M have problems
# the remaining 6.7M are empty
gunzip -c c2fN.error.[0-7].gz| cut -d\; -f1 | uniq | lsort 30G -u | join -v2 -  <(gunzip -c cNotInC2fbp.cmtprob) | gzip > cNotInC2fbp.empty
gunzip -c cNotInC2fbp.empty| wc
7796141
gunzip -c cNotInC2fbp.empty | /da3_data/lookup/splitSec.perl cNotInC2fbp.empty. 8
for i in {0..7}
do gunzip -c cNotInC2fbp.empty.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> cNot.empty.$i.err | gzip > cNot.empty.$i.c2fb & done
for i in {0..7}; do
    gunzip -c cNot.empty.$i.c2fb | perl -ane '@x=split(/;/, $_, -1);$x[1]=~s|^/*||;print "$x[0];$x[1]\n";' | \
	 gzip > c2fN.empty.$i.gz &
done
gunzip -c *.c2fb1 | cut -d\; -f1 | uniq | lsort 90G -u | gzip cNot.cs
gunzip -c cNot.e*.c2fb | cut -d\; -f1 | lsort 10G -u | gzip > cNot.misc.cs
lsort 90G -u --merge <(gunzip -c cNot.misc.cs) <(gunzip -c cNot.cs) | gzip > cNot.cs1
join -v1 <(gunzip -c /data/basemaps/cNotInC2fbp.s) <(gunzip -c cNot.cs1) | wc

for i in {0..7}; do gunzip -c c2fFullB$i.gz | cut -d\; -f1  | uniq | gzip > c2fFullB$i.cs & done
for i in {0..7}; do gunzip -c c2fFullB$i.cs | join -v2 - <(gunzip -c cNotInC2fbp.$i.gz) | gzip > cNotInC2fbp.$i.miss & done
for i in {0..6}; do
  gunzip -c /da0_data/c2fbp/cNotInC2fbp.$i.miss | /da3_data/lookup/cmputeDiff2.perl 2> /da0_data/c2fbp/cNotInC2fbp.$i.miss.err | gzip > /da0_data/c2fbp/cNotInC2fbp.$i.miss.c2fb
  gunzip -c cNotInC2fbp.$i.miss.c2fb | perl -ane '@x=split(/;/, $_, -1);$x[1]=~s|^/*||;print "$x[0];$x[1]\n";' | \
	 gzip > c2fN.miss.$i.gz &
done
for i in {0..7}; do lsort 50G -t\; -k1b,2 -u --merge <(gunzip -c c2fN.miss.$i.gz) <(gunzip -c c2fFullB$i.gz) | gzip > c2fFullC$i.gz & done


gunzip -c cNotInC2fbp.7.miss | split -l 1500000 -da 1 --filter='gzip > $FILE.gz' - cNotInC2fbp.7.miss.
for i in {0..9}; do gunzip -c /da0_data/c2fbp/cNotInC2fbp.7.miss.$i.gz | /da3_data/lookup/cmputeDiff2.perl 2> /da0_data/c2fbp/cNotInC2fbp.7.miss.$i.err | gzip > /da0_data/c2fbp/cNotInC2fbp.7.miss.$i.c2fb & done
for i in {0..9}; do
    gunzip -c cNotInC2fbp.7.miss.$i.c2fb | perl -ane '@x=split(/;/, $_, -1);$x[1]=~s|^/*||;print "$x[0];$x[1]\n";' | gzip > c2fN.miss.7.$i.gz &
done 
for i in {0..9}; do gunzip -c c2fN.miss.7.$i.gz; done | gzip > c2fN.miss.7.gz

for i in {0..7}; do 
gunzip -c c2fFullC$i.gz | /da3_data/lookup/Cmt2FileBin.perl c2fFull.$i 1 &
done
lsort 50G -t\; -k1b,2 -u --merge <(gunzip -c c2fN.miss.7.gz) <(gunzip -c /da4_data/update/c2fFull7.gz) <(gunzip -c c2fFullC7.0.gz) <(gunzip -c /da4_data/update/c2fN.empty.7.gz)  <(gunzip -c /da4_data/update/c2fN.error.7.gz) | gzip > c2fFullC7.gz &



#now create c2fN, c2bN, b2fN,
#for i in {000..614}; do gunzip -c cNot.$i.c2fb; done |  split -l 1000000000 -d -a 2 --filter='gzip > $FILE.c2fb' - cNotInC2fbp. 
#really nasty c2f : 3759c6529b44b636b845fb1c8a0f42c4d14d7150 has tree e69de29bb2d1d6434b8b29ae775ad8c2e48c5391 with millions of files

for k in {0..5}; do
  to=${k}99
  [[ $k == 5 ]] && to=614 
  for i in $(eval echo "{${k}00..$to}"); do cat cNot.$i.c2fb.bad; done | sed 's/^[-+]//' | uniq | sort -u > c2fN.$k.bad 
  cat c2fN.$k.bad | /da3_data/lookup/cmputeDiff2.perl 2> c2fN.$k.bad.err | gzip > c2fN.$k.bad.c2fb
  for i in $(eval echo "{${k}00..$to}"); do gunzip -c cNot.$i.c2fb1 | cut -d\; -f1 | uniq > cNot.$i.cs; done 
  for i in $(eval echo "{${k}00..$to}"); do gunzip -c cNot.$i.c2fb1; done | perl -ane '@x=split(/;/, $_, -1);$x[1]=~s|^/*||;print "$x[0];$x[1]\n";' | gzip > c2fN.$k.gz 
done
gunzip -c c2fN.[0-5].bad.c2fb | head -30 | perl -ane '@x=split(/;/, $_, -1);$x[1]=~s|^/*||;print "$x[0];$x[1]\n" if $x[0] =~ m/^[0-9a-f]{40}$/;' | lsort 100G -t\; -k1b -u | gzip > c2fN.bad.gz
sort 130G -u -k1b --merge <(gunzip -c c2fN.{133,363,400-427,428,429-521,522,523-614}.gz) <(gunzip -c c2fN.0-399.133,363.gz) <(gunzip -c c2fN.bad.gz) <(gunzip -c /data/basemaps/c2f.00-81.s) | ./splitSec.perl c2fFull 8
for i in {0..7}; do gunzip -c c2fFull$i.gz | /da3_data/lookup/Cmt2FileBin.perl c2fFull.$i 1 & done


#Similarly for blob2commit
# for c2fbp stuff
for i in {00..81}
c=/lustre/haven/user/audris/c2fbp
i=NNN
cd /tmp
gunzip -c $c/c2b.$i.s | awk -F\; '{print $2";"$1}' | lsort 15G -t\; -k1b,2 -u | gzip > $c/b2c.$i.gz
cmd=$(echo "lsort 10G -t\; -k1b,2 --merge -u"; for k in {00..81}; do echo " <(gunzip -c $c/$s.$k.gz)"; done)
eval $cmd | gzip > $c/$s.00-81.gz
#for new
for i in {000..614}
do gunzip -c $c/cNot.$i.c2fb | perl -ane 'chop();@x=split(/;/,$_, -1); print "$x[2];$x[0]\n" if $x[0] =~ m|^[0-9a-f]{40}$| && $x[2] =~ m|^[0-9a-f]{40}$|' | lsort 15G -t\; -k1b,2 -u | gzip > $c/b2cN.$i.gz
done
#eval $cmd | gzip > $c/$s.000-614.gz
#cmd=$(echo "lsort 10G -t\; -k1b,2 --merge -u"; for k in {NNN..MMM}; do echo " <(gunzip -c $c/$s.$k.gz)"; done)
#eval $cmd | gzip > $c/$s.$i-$j.gz
#lsort 130G -u -k1b --merge <(gunzip -c b2cN.000-614.gz) <(gunzip -c b2c.00-81.gz) | /da3_data/lookup/splitSec.perl b2cFull 16
#lsort 50G -t\; -k1b,2 --merge -u <(gunzip -c b2c.00-19.s) <(gunzip -c b2c.20-39.s) <(gunzip -c b2c.40-59.s) <(gunzip -c b2c.60-81.s) <(gunzip -c b2cN.000-614.gz) | /da3_data/lookup/splitSec.perl b2cFull 16 &

ls -f *.c2fb | grep -v '^cNot\.[0-6][0-9][0-9]\.' | while read i; do gunzip -c $i | awk -F\; '{print $3";"$1}' ; done | grep -E '^[0-9a-f]{40};[0-9a-f]{40}$' | \
     /da3_data/lookup/splitSec.perl b2c.misc.  16 &
gunzip -c b2cN.000-614.gz | grep -E '^[0-9a-f]{40};' | /da3_data/lookup/splitSec.perl b2c.000-614. 16 &


gunzip -c b2c.000-614.$i.gz ../basemaps/gz/b2c.00-81.s1.$i.gz b2c.misc.$i.gz ../basemaps/b2cFullB$i.s | lsort 70G -t\; -k1b,2 -u | gzip > b2cFullE$i.s

for i in {0..15}; do
    gunzip -c b2cFullE$i.s | sed 's/;/;;/' | /da3_data/lookup/Cmt2BlobBin.perl b2cFullD.$i.tch 1 & done

#do summaries of the old stuff in  c2b.00-81.s, b2f.00-81.s, c2f.00-81.s
for i in {00..81}; do
gunzip -c $cloneDir/c2fbp.$i.gz | cut -d\; -f1,2 | uniq | \
  perl -ane 'chop();($c,$f)=split(/\;/,$_,-1);next if "$c" !~ /^[0-9a-f]{40}$/;$f=~s|^/*||;print "$c;$f\n";' | \
  lsort 15G -u | gzip > $cloneDir/c2f.$i.s
done
#doExtr1.pbs
for s in c2f b2f c2b c2p
for i in {0..7}; do
if [[ $i == 0 ]]
then 
  lsort 10G -t\; -k1b,2 --merge -u <(gunzip -c $c/$s.${i}0.s) <(gunzip -c $c/$s.${i}1.s) <(gunzip -c $c/$s.${i}2.s) <(gunzip -c $c/$s.${i}3.s) <(gunzip -c $c/$s.${i}4.s) <(gunzip -c $c/$s.${i}5.s) <(gunzip -c $c/$s.${i}6.s) <(gunzip -c $c/$s.${i}7.s) <(gunzip -c $c/$s.${i}8.s)  <(gunzip -c $c/$s.${i}9.s) <(gunzip -c $c/$s.${j}0.s) | gzip > $c/$s.${i}0-${j}0.s
else if [[ $i == 7 ]]
  then 
    lsort 10G -t\; -k1b,2 --merge -u <(gunzip -c $c/$s.${i}1.s) <(gunzip -c $c/$s.${i}2.s) <(gunzip -c $c/$s.${i}3.s) <(gunzip -c $c/$s.${i}4.s) <(gunzip -c $c/$s.${i}5.s) <(gunzip -c $c/$s.${i}6.s) <(gunzip -c $c/$s.${i}7.s) <(gunzip -c $c/$s.${i}8.s)  <(gunzip -c $c/$s.${i}9.s) <(gunzip -c $c/$s.${j}0.s)  <(gunzip -c $c/$s.${j}1.s) | gzip > $c/$s.${i}1-${j}1.s
  else
    lsort 10G -t\; -k1b,2 --merge -u <(gunzip -c $c/$s.${i}1.s) <(gunzip -c $c/$s.${i}2.s) <(gunzip -c $c/$s.${i}3.s) <(gunzip -c $c/$s.${i}4.s) <(gunzip -c $c/$s.${i}5.s) <(gunzip -c $c/$s.${i}6.s) <(gunzip -c $c/$s.${i}7.s) <(gunzip -c $c/$s.${i}8.s)  <(gunzip -c $c/$s.${i}9.s) <(gunzip -c $c/$s.${j}0.s) | gzip > $c/$s.${i}1-${j}0.s
  fi
fi
#doExtr2.pbs
lsort 10G -t\; -k1b,2 --merge -u <(gunzip -c $c/$s.00-10.s) <(gunzip -c $c/$s.11-20.s) <(gunzip -c $c/$s.21-30.s) <(gunzip -c $c/$s.31-40.s) <(gunzip -c $c/$s.41-50.s) <(gunzip -c $c/$s.51-60.s) <(gunzip -c $c/$s.61-70.s) <(gunzip -c $c/$s.71-81.s) | gzip > $c/$s.00-81.s

#having c2b.00-81.s, b2f.00-81.s, c2f.00-81.s

#Merge both
lsort 30G -u --merge -t\; -k1b <(gunzip -c c2fN.s) <(gunzip $c/c2f.00-81.s) | ./Cmt2PrjBinSorted.perl Cmt2FileFull 8
Two nasty commits
   with 100M files in 03cb3eb9c22e21e2475fee4fb6013718a2fa39fb
and 16777217 files in 0f17bf2e73149f60302a0a2464b3fadf3ea3e6f9
Exclude them? 

#now do author to file


#Do complete fresh
for i in {00..81}; do sed "s/NNN/$i/g;" doB2CBin.pbs | qsub; done
for i in {00..81}; do sed "s/NNN/$i/g;" doC2Bbin.pbs | qsub; done



#premerge into fewer chunks
for k in {00..64..16}; do for i in {0..15}; do sed "s/NNN/$k/g;s/MMM/$i/g" doB2Cmerge.pbs | qsub; done; done
for k in {00..64..16}; do for i in {0..15}; do sed "s/NNN/$k/g;s/MMM/$i/g" doC2Bmerge.pbs | qsub; done; done


#merge each uses about 44GB RAM 20 min
for i in {0..15}; do (for k in {00..64..16}; do echo Cmt2Blob.$k-$(($k+15)).$i.tch; done; echo  Cmt2Blob.80.$i.tch) | while read l; do rsync -a $l da3:/fast1; done; done
for i in {0..15}; do (for k in {00..64..16}; do echo Blob2Cmt.$k-$(($k+15)).$i.tch; done; echo  Blob2Cmt.80.$i.tch) | while read l; do rsync -a $l da3:/fast1; done; done

for i in {0..15}
do time (for k in {00..64..16}; do echo /fast1/Blob2Cmt.$k-$(($k+15)).$i.tch; done; echo /fast1/Blob2Cmt.80.$i.tch) | ./f2bMerge.perl Blob2Cmt.$i
done
for i in {0..15}
do (for k in {00..64..16}; do echo /fast1/Cmt2Blob.$k-$(($k+15)).$i.tch; done; echo /fast1/Cmt2Blob.80.$i.tch) | ./f2bMerge.perl Cmt2Blob.$i
done

#!done!

#Older approach, was reading c2fbp icorrectly
for i in {00..80..16}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2Bin.pbs | qsub; done; done
faster simply:
for k in {0..15}
do ls -f Cmt2Blob.[0-8][0-9].$k | f2bMerge.perl Cmt2Blob.$k
   scp -p Cmt2Blob.$k.tch da4:/data/basemaps/
done   
Result is Cmt2Blob.00-80.{0..15}.tch


#now invert
for k in {0..15}
do ./Cmt2BlobInvrt.perl /fast1/All.sha1c/Cmt2Blob.00-80.$k.tch Blob2Cmt.00-80.$k
done

#now merge inverted
for k in {0..15}
do ls -f Blob2Cmt.00-80.{[0-9],1[0-5]}.$k.tch | f2bMerge.perl Blob2Cmt.$k
   scp -p Blob2Cmt.$k.tch da4:/data/basemaps/
done



#older

# too slow to mess with iterative small ram merges
for i in {00..78..02}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge.pbs | qsub; done; done
for i in {00..76..04}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge1.pbs | qsub; done; done
for i in {00..72..08}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge2.pbs | qsub; done; done
for i in {00..64..16}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge3.pbs | qsub; done; done
for i in {00..32..32}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge4.pbs | qsub; done; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS.pbs | qsub; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS1.pbs | qsub; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS2.pbs | qsub; done


#use the result of old Cmt2Blob.perl in commit_blob.tch
mv /fast1/All.sha1c/commit_blob.tch /fast1/All.sha1c/commit_blob.tch.old
./exportObj.perl /fast1/All.sha1c/commit_blob.tch.old | gzip > /data/All.blobs/commit_blob.bin
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Cmt2BlobMerge.perl /data/All.blobs/commit_blob.bin /data/commit_blob.tch
mv /data/commit_blob.tch /fast1/All.sha1c/
#use Cmt2Blob.00-80.{0..15}.tch as produced above instead 

#use old /fast1/All.sha1c/blob_commit.tch 
./exportObj1.perl /fast1/All.sha1c/blob_commit.tch | gzip > /data/All.blobs/blob_commit.bin
# this takes 700G of ram and takese several weeks: avoid
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Blob2CmtMerge.perl /data/blob_commit.bin /data/blob_commit.tch
mv /data/blob_commit.tch /fast1/All.sha1c/

The alternative is iteratively merge 80 chunks produced 
by doB2CBin.pbs 
via Blob2CmtMergeTC.perl
see doB2Cmerge.pbs
also takes very long time, use split invert/merge as shown above
