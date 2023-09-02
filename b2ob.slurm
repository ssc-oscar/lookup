#!/bin/bash
#SBATCH -J WHAT.FROM.PRT
#SBATCH -A ACF-UTK0011
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=NTASKS
#SBATCH --partition=campus
#SBATCH --time=0-23:59:59
#SBATCH --error WHAT.FROM.PRT.o%J
#SBATCH --output WHAT.FROM.PRT.o%J
#SBATCH --mail-user=audris@utk.edu
#SBATCH --mail-type=FAIL

module purge
module load bzip2/1.0.8  intel-compilers/2021.2.0

LD_LIBRARY_PATH=/nfs/home/audris/lib:/nfs/home/audris/lib64:$LD_LIBRARY_PATH

c=/lustre/isaac/scratch/audris/c2fb
cd $c


machine=MACHINE
maxM=$((1000*NTASKS))
[[ $machine == monster ]] && maxM=30000
[[ $machine == rho ]] && maxM=900
[[ $machine == sigma ]] && maxM=2900

ver=V
pVer=U
i=FROM
what=WHAT
sel=PRT
mul=1

if test 'WHAT' = 'prep'; then


##calc diffs on da5/da4/da3
# ( i=57; zcat RS$i.cs | perl -I ~/lookup -I ~/lib64/perl5 ~/lookup/cmputeDiff3.perl 2> errRS.$i | gzip > RS$i.gz ) &
# for i in {0..127}; do zcat cnpcOrUndefRS$i.s | time perl -I ~/lookup -I ~/lib64/perl5 ~/lookup/cmputeDiff3.perl 2> errUndefRS.$i | gzip > cUndefRS$i.gz; done &
#

l=FROM
for k in {0..1}
do i=$(($k+$l*2)) 
 zcat $pVer${pVer}1.$i.gz $pVer${ver}.$i.gz |\
 perl -I ~/lib -I ~/lib64/perl5 -I $HOME/lib/perl5 -I $HOME/lookup -e 'use cmt; while(<STDIN>){ chop (); s|;/|;|g; @r = split(/;/); $r[$#r] = "long" if $r[$#r] =~ / /&& length($r[$#r]) > 300; print "".(join ";", @r)."\n" if ! defined $badCmt{$r[0]};}' | \
 $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > $pVer$ver$i.s
 echo $pVer$ver$i.s
 #zcat cUndef$pVer$ver$i.gz |\
 # perl -I $HOME/lib/perl5 -I $HOME/lookup -e 'use cmt; while(<STDIN>){ chop (); s|;/|;|g; @r = split(/;/); $r[$#r] = "long" if $r[$#r] =~ / /&& length($r[$#r]) > 300; print "".(join ";", @r)."\n" if ! defined $badCmt{$r[0]};}' | \
 # $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > cUndef$pVer$ver$i.s
 #zcat cnp2bfFullR$i.s | awk -F\; '{print $1";"$3";"$2";"}' | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > cnpc2fbFullR$i.s
 #echo cnpc2fbFullR$i.s
 #lsort 3G -t\; -k1,4 -u --merge <(zcat c2fbbFull$pVer$i.s) <(zcat $pVer$ver$i.s) <(zcat  cUndef$pVer$ver$i.s) <(zcat cnpc2fbFullR$i.s)| gzip > c2fbbFull$ver$i.s
 lsort ${maxM}M -t\; -k1,4 -u --merge <(zcat c2fbbFull$pVer$i.s) <(zcat $pVer$ver$i.s) | gzip > c2fbbFull$ver$i.s
 echo c2fbbFull$ver$i.s
done

fi
if test 'WHAT' = 'idxf'; then

cd ../All.blobs
l=FROM
for k in {0..1}
do i=$((k+l*2))
  zcat ../c2fb/TU.$i.bs | lsort ${maxM}M -t\; -k1,1 | join -t\; - <(zcat ../c2fb/b2fFullU$i.s) | gzip > TU.$i.bsf
  zcat ../c2fb/TU.$i.bf | awk -F\; '{print $1";"$3}' | lsort ${maxM}M -t\; -k1,1 -u | gzip > TU.$i.bfs
  lsort ${maxM}M -t\; -k1,1 -u --merge <(zcat TU.$i.bsf) <(zcat TU.$i.bfs) | gzip > TU.$i.bf1
  bl=$(zcat ../All.blobs/blob_$i.idxf2|tail -1|cut -d\; -f4)
  n0=$(grep $bl ../All.blobs/blob_$i.idx|tail -1|cut -d\; -f1)
  n1=$(tail -1 ../All.blobs/blob_$i.idx|cut -d\; -f1)
  tail -$((n1-n0)) ../All.blobs/blob_$i.idx| lsort ${maxM}M -t\; -k4,4 | gzip > TU.$i.idxs
  zcat TU.$i.idxs| join -t\; -1 4 -2 1 -a1 - <(zcat TU.$i.bf1) | awk -F\; '{print $2";"$3";"$4";"$1";"$5}' | lsort ${maxM}M -t\; -k1,1 -n | gzip > TU.$i.idxf2 
  zcat ../All.blobs/blob_$i.idxf2 TU.$i.idxf2 |gzip > ../All.blobs/blob_$i.idxf
done
 
fi
if test 'WHAT' = 'check'; then

l=FROM
zcat $pVer$ver$l.0.gz $pVer$ver$l.1.gz | grep -F dc8f32860044f93c7cf898655d71d3c999248465 > dc8f32860044f93c7cf898655d71d3c999248465.$l 

fi
if test 'WHAT' = 'b2idx'; then

l=FROM
for k in {0..1}
do i=$(($k+$l*2))
# print middle file: perhaps pick shortest without . prefix?
cat ../All.blobs/blob_$i.idx | perl -ane 'chop();@x=split(/;/);$x[3]=$x[4] if $#x>5;printf ("%s;%.9u;%s;%s\n",$x[3],$x[0],$x[1],$x[2]);' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > b2idx$i.s
zcat b2idx$i.s | join -t\; - <(zcat b2fFull$ver$i.s) | \
 perl -ane 'chop();@x=split(/;/);print "$x[1];$x[2];$x[3];$x[0];$x[4]\n"' | \
 perl -e '$pb="";while(<STDIN>){@x=split(/;/);if ($x[3] ne $pb && $pb ne ""){ print "$pre;$pb;".($tmp[$#tmp/2]); @tmp=(); } $pb=$x[3]; $pre="$x[0];$x[1];$x[2]";push @tmp, $x[4]; } print "$pre;$pb;".($tmp[$#tmp/2]);' | \
 $HOME/bin/lsort ${maxM}M -t\; -k1,1 | sed 's|^0+||' | gzip > ../All.blobs/blob_$i.idxf
 cat ../All.blobs/blob_$i.idx | perl -ane 'chop();@x=split(/;/);$x[3]=$x[4] if $#x>5; $i=shift @x; printf ("%.9d;%s\n",$i, ($x[0].";".$x[1].";".$x[2].";"));'  | join -t\; -v1 - <(zcat ../All.blobs/blob_$i.idxf) | gzip > ../All.blobs/blob_$i.idxNof
 echo blob_$i.idxNof
 $HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge <(zcat ../All.blobs/blob_$i.idxNof) <(zcat ../All.blobs/blob_$i.idxf) | gzip > ../All.blobs/blob_$i.idxf2
done

fi
if test 'WHAT' = 'tst1'; then

i=103
cat ../All.blobs/blob_$i.idx | perl -ane 'chop();@x=split(/;/);$x[3]=$x[4] if $#x>5; $i=shift @x; printf ("%.9d;%s\n",$i, ($x[0].";".$x[1].";".$x[2].";"));'  | join -t\; -v1 - <(zcat ../All.blobs/blob_$i.idxf) | gzip > ../All.blobs/blob_$i.idxNof
echo blob_$i.idxNof
$HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge <(zcat ../All.blobs/blob_$i.idxNof) <(zcat ../All.blobs/blob_$i.idxf) | gzip > ../All.blobs/blob_$i.idxf2

fi
if test 'WHAT' = 'addf'; then
#old, tries to annotate idx with filenames
l=FROM
for k in {0..1}
do i=$(($k+$l*2))
   cat ../All.blobs/blob_$i.idx | perl -ane 'chop();@x=split(/;/);$x[3]=$x[4] if $#x>5;printf ("%s;%.8d;%lu;%lu\n",$x[3],$x[0],$x[1],$x[2]);' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > b2idx$i.s
   echo b2idx$i.s
   zcat b2idx$i.s | join -t\; - <(zcat b2fFull$ver$i.s) | perl -ane 'chop();@x=split(/;/);print "$x[1];$x[2];$x[3];$x[0];$x[4]\n"' | \
     perl -e '$pb="";while(<STDIN>){@x=split(/;/);print if ($x[0] ne $pb); $pb=$x[0];}' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | sed 's|^0+||' | gzip > ../All.blobs/blob_$i.idxf
   echo ../All.blobs/blob_$i.idxf
   cat ../All.blobs/blob_$i.idx | perl -ane 'chop();@x=split(/;/);$x[3]=$x[4] if $#x>5; $i=shift @x; printf ("%.8d;%s\n",$i, ($x[0].";".$x[1].";".$x[2].";"));'  |join -t\; -v1 - <(zcat ../All.blobs/blob_$i.idxf1) | gzip > ../All.blobs/blob_$i.idxNof
   echo blob_$i.idxNof
   $HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge <(zcat ../All.blobs/blob_$i.idxNof) <(zcat ../All.blobs/blob_$i.idxf) | gzip > ../All.blobs/blob_$i.idxf2
   echo blob_$i.idxf2
done

fi
if test 'WHAT' = 'addSTf'; then

i=FROM
cat ../All.blobs/blob_ST_$i.idx | perl -ane 'chop();@x=split(/;/);$x[3]=$x[4] if $#x>5;printf ("%s;%.8d;%lu;%lu\n",$x[3],$x[0],$x[1],$x[2]);' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > b2STidx$i.s
echo b2STidx$i.s
zcat b2STidx$i.s | join -t\; - <(zcat b2fFull$ver$i.s) | perl -ane 'chop();@x=split(/;/);print "$x[1];$x[2];$x[3];$x[0];$x[4]\n"' | \
     perl -e '$pb="";while(<STDIN>){@x=split(/;/);print if ($x[0] ne $pb); $pb=$x[0];}' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | sed 's|^0+||' | gzip > ../All.blobs/blob_ST_$i.idxf
echo blob_ST_$i.idxf
$HOME/bin/lsort ${maxM}M -t\; -k1,1 <(zcat ../All.blobs/blob_ST_$i.idxf) | gzip > ../All.blobs/blob_ST_$i.idxf2

fi
# c2f c2b c2fb
if test 'WHAT' = 'c2f'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
  zcat c2fbbFull$ver$j.s | cut -d\; -f1,2 | grep -E '^[0-9a-f]{40};.+$' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | \
     gzip > c2fFull$ver$j.s
  echo c2fFull$ver$j.s
done
#compare with merging with c2fFull$pver

fi
if test 'WHAT' = 'f2c'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
  zcat c2fFull$ver$j.s | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n" if "$x[1];$x[0]" =~ /^[^;]+;[0-9a-f]{40}$/' | uniq 
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl f2cFull$ver.$l. 128 
echo f2cFull$ver.$l.

for i in {0..127}
do zcat f2cFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > f2cFull$ver.$l.$i.s
   echo f2cFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'f2b'; then

l=FROM   
for i in {0..1}
do j=$(($i+$l*2))
  zcat b2fFull$ver$j.s | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n" if "$x[1];$x[0]" =~ /^[^;]+;[0-9a-f]{40}$/' | uniq 
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl f2bFull$ver.$l. 128
echo f2bFull$ver.$l.

for i in {0..127}
do zcat f2bFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > f2bFull$ver.$l.$i.s
   echo f2bFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'b2f'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
  zcat c2fbbFull$ver$j.s | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[2];$x[1]\n" if "$x[2];$x[1]" =~ m/^[0-9a-f]{40};.+/;' | uniq   
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl b2fFull$ver.$l. 128
echo b2fFull$ver.$l.

for i in {0..127}
do zcat b2fFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > b2fFull$ver.$l.$i.s
   echo b2fFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'b2c'; then #b2ta seems to have b2c?

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
  zcat c2bFull$ver$j.s | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n" if "$x[1];$x[0]" =~ m/^[0-9a-f]{40};[0-9a-f]{40}$/;' | uniq
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl b2cFull$ver.$l. 128
echo b2cFull$ver.$l.

for i in {0..127}
do zcat b2cFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > b2cFull$ver.$l.$i.s
   echo b2cFull$ver.$l.$i.s
done


fi
if test 'WHAT' = 'c2b'; then

l=FROM   
for i in {0..1}
do j=$(($i+$l*2))
  zcat c2fbbFull$ver$j.s | cut -d\; -f1,3 | grep -E '^[0-9a-f]{40};[0-9a-f]{40}$' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | \
     gzip > c2bFull$ver$j.s
  echo c2bFull$ver$j.s
done

fi
if [[ 'WHAT' == 'b2fm' || 'WHAT' == 'f2bm' || 'WHAT' == 'f2cm' || 'WHAT' == 'b2obm' || 'WHAT' == 'ob2bm' || 'WHAT' == 'b2cm' || 'WHAT' == "b2Pm" || 'WHAT' == "P2bm" || 'WHAT' == "P2fm" ]]; then

pre=$(echo WHAT|sed 's|m$||')
l=FROM
for k in {0..1}
do i=$((FROM*2+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for l in {0..63}
  do str="$str <(zcat ${pre}Full$ver.$l.$i.s)"
  done
  eval $str | gzip > ${pre}Full$ver$i.s
  echo ${pre}Full$ver$i.s
  if [[ 'WHAT' == "b2Pm" || 'WHAT' == "P2bm"  ]];  then
    zcat ${pre}Full$ver$i.s | cut -d\; -f1 | uniq -c | awk '{ if ($1 > 100) print $2";"$1}' | gzip > large$pre$i.s
    echo large$pre$i.s
  fi
done

fi
if [[ 'WHAT' == 'largeb2P128' ]]; then

l=FROM
for k in {0..1}
do i=$((FROM*2+$k))
pre=b2P128	
zcat ${pre}Full$ver.$i.gz | cut -d\; -f1 | uniq -c | awk '{ if ($1 > 100) print $2";"$1}' | gzip > large$pre$ver$i.s
done

fi
if [[ 'WHAT' == 'b2tam' ]]; then

pre=$(echo WHAT|sed 's|m$||')
l=FROM   
for k in {0..1}
do i=$((FROM*2+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
  for l in {0..63}
  do str="$str <(zcat ${pre}Full$ver.$l.$i.s)"
  done
  eval $str | gzip > ${pre}Full$ver$i.s
  echo ${pre}Full$ver$i.s
done


fi
if [[ 'WHAT' == "a2fm" || 'WHAT' == "a2fbm" || 'WHAT' == "A2fbm" ]]; then

pre=$(echo WHAT|sed 's|m$||')

  #zcat ../All.blobs/b2sla$j.s | perl ~/lookup/filterByLaSz.perl 450 | gzip > bSelect$j.s
  #echo bSelect$j.s
  #  zcat b2P$ver$j.s | cut -d\; -f1 | uniq -c | awk '{ if ($1 > 100) print $2";"$1}' | gzip > largeb2P$j.s

l=FROM   
for k in {0..1}
do i=$((FROM*2+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for l in {0..63}
  do str="$str <(zcat ${pre}Full$ver.$l.$i.s)"
  done
  eval $str | gzip > ${pre}Full$ver$i.s
  echo ${pre}Full$ver$i.s
done


fi
if [[ 'WHAT' == "export2Pm" ]]; then

pre=$(echo WHAT|sed 's|m$||')
l=FROM
for k in 0
do i=$((FROM+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for l in {0..127}
  do str="$str <(zcat ${pre}Full$ver.$l.$i.s)"
  done
  eval $str | gzip > ${pre}Full$ver$i.s
  echo ${pre}Full$ver$i.s
done



fi
if test 'WHAT' = 'bExport'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
  zcat b2fFull$ver$j.s | ~/lookup/parseExports.perl | gzip > bExport$ver$j.s
  echo bExport$ver$j.s
done

fi 
if test 'WHAT' = 'bSel'; then

l=FROM
for i in {0..7}
do j=$(($i+$l*8))
  zcat b2fFull$ver$j.s| perl ~/lookup/selBlobsByExt.perl | gzip > bSelect$ver$j.s
  echo bSelect$ver$j.s
done

fi
if test 'WHAT' = 'bSelS'; then

l=FROM
for i in {0..7}
do j=$(($i+$l*8))
   #zcat ../All.blobs/blob_$j.idxf2| awk -F\; '{if ($3>450) print $4";"$3}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | join -t\; - <(zcat bSelect$ver$j.s) |gzip > bSelectSz$ver$j.s
   zcat b2idx$j.s | cut -d\; -f1,4 | join -t\; - <(zcat bSelect$ver$j.s) |gzip > bSelectSz$ver$j.s
   echo bSelectSz$ver$j.s
done

fi
if test 'WHAT' = 'T2Tcut'; then

l=FROM
cut=CUT;
l=FROM
for i in {0..3}
do j=$((FROM*4+i))
   zcat b2TFull${ver}$j.s | cut -d\; -f1 | uniq -c | awk '{ if ($1 > 1) print $2";"$1}' | gzip > largeb2T${ver}$j.s
   zcat largeb2T${ver}$j.s | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';'  | gzip > largeb2T${ver}$j.$cut.s
done
for i in {0..3}
do j=$((FROM*4+i))
   $HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge <(zcat bSelectSz$ver$j.s|cut -d\; -f1) | join -t\; -  <(zcat b2TFull${ver}$j.s) | perl $HOME/bin/grepFieldv.perl largeb2T${ver}$j.$cut.s 1 
done | perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > T2TFull${ver}$l.b2b.$cut
echo T2TFull${ver}$l.b2b.$cut
zcat T2TFull${ver}$l.b2b.$cut | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > T2TFull${ver}$l.b2b.$cut.gz
echo T2TFull${ver}$l.b2b.$cut.gz
zcat T2TFull${ver}$l.b2b.$cut.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > T2TFull${ver}$l.b2b.$cut.s
echo T2TFull${ver}$l.b2b.$cut.s


fi
if test 'WHAT' = 'P2Pcut'; then

l=FROM
cut=CUT;

#for i in {0..31}; do zcat largeb2P$i.s | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';'; done | gzip > largeb2P.$cut.s
#cat ../tkns/tkns{$j,$((j+32)),$((j+64)),$((j+96))}.*.idx  | perl ~/lookup/filterByLaSz.perl 450 | lsort ${maxM}M -u | gzip > bSelect$j.s
#fi
#if test 'WHAT' = 'P2Pb'; then
j=FROM
l=FROM
#zcat b2PFull${ver}$j.s | cut -d\; -f1 | uniq -c | awk '{ if ($1 > 10) print $2";"$1}' | gzip > largeb2P${ver}$j.s
zcat largeb2P${ver}$j.s | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';'  | gzip > largeb2P${ver}$j.$cut.s
#for i in {0..1}
#do j=$((FROM*2+i))
#   zcat largeb2P$i.s | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';' | gzip > largeb2P$j.$cut.s
#   cat ../tkns/tkns{$j,$((j+32)),$((j+64)),$((j+96))}.*.idx  | perl ~/lookup/filterByLaSz.perl 450 | lsort ${maxM}M -u | gzip > bSelect$j.s
$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge <(zcat bSelectSz$ver$j.s|cut -d\; -f1) <(zcat bSelectSz$ver$((j+32)).s|cut -d\; -f1) <(zcat bSelectSz$ver$((j+64)).s|cut -d\; -f1) <(zcat bSelectSz$ver$((j+96)).s|cut -d\; -f1) | join -t\; -  <(zcat b2PFull${ver}$j.s) | perl $HOME/bin/grepFieldv.perl largeb2P${ver}$j.$cut.s 1 \
| perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > P2PFull${ver}$j.b2b.$cut
echo P2PFull${ver}$l.b2b.$cut
zcat P2PFull${ver}$l.b2b.$cut | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > P2PFull${ver}$l.b2b.$cut.gz
echo P2PFull${ver}$l.b2b.$cut.gz
zcat P2PFull${ver}$l.b2b.$cut.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > P2PFull${ver}$l.b2b.$cut.s
echo P2PFull${ver}$l.b2b.$cut.s

fi
if test 'WHAT' = 'P2Pcutm'; then

str="lsort $(($maxM*3))M -t\| --merge"
for j in {0..31}
do str="$str <(zcat  P2PFull$ver$j.b2b.CUT.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > P2PFull$ver.nb2b.CUT.s
echo P2PFull$ver.nb2b.CUT.s

fi
if test 'WHAT' = 'T2Tcutm'; then

str="lsort $(($maxM*3))M -t\| --merge"
for j in {0..31}
do str="$str <(zcat  T2TFull$ver$j.b2b.CUT.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > T2TFull$ver.nb2b.CUT.s
echo T2TFull$ver.nb2b.CUT.s

fi
if test 'WHAT' = 'P2Pcran'; then
cut=2000
for j in {0..31}
do zcat P2PFull$ver$j.b2b.2000 |grep ';cran_' 
done | gzip > P2PFull${ver}CRAN.b2b.2000

fi
if test 'WHAT' = 'A2Afb'; then

l=FROM

for i in {0..3}
do j=$((FROM*4+i))
   zcat b2fAFull$ver$j.s | join -t\; - <(zcat bSelectSz$ver$j.s) |join -t\; - <(zcat b2tAFull$ver$j.s)                  #3600*24*365.25*12
done | perl -ane 'chop();($b,$t0,$a0,$c0,$t1,$a1,$c1)=split(/;/);print "$a0;$a1;$b;".($t1-$t0)."\n" if $t0 > 378691200' | uniq | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl A2Afb.$l. 32
echo A2Afb.$l.

for i in {0..31}
do zcat A2Afb.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,3 -u | cut -d\; -f1,2,4 | gzip > A2AfbFull$ver.$l.$i.s
   echo A2Afb$ver.$l.$i.s
done

fi
if [[ 'WHAT' = 'A2Afbm' || 'WHAT' == 'A2bm' ]]; then

pre=$(echo WHAT|sed 's|m$||')
l=FROM
for k in {0..3}
do i=$((FROM*4+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 --merge -u"
  for l in {0..31}
  do str="$str <(zcat ${pre}Full$ver.$l.$i.s)"
  done
  eval $str | gzip > ${pre}Full$ver$i.s
done

fi
if test 'WHAT' = 'A2Acut'; then

l=0
cut=CUT
l=FROM
for j in $l
do zcat A2AfbFull${ver}$j.s | perl -ane 'chop();($fr,$to,$tdiff)=split(/;/);print ";$fr;$to\n" if $fr ne $to && $tdiff/3600/24 >= '$cut';' | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$1$_\n"' | gzip > A2AFull${ver}$j.nfb.$cut.s
   echo A2AFull${ver}$j.nfb.$cut.s
done

fi
if test 'WHAT' = 'b2ta'; then
#does c2fbbFull have c with no pc?

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
  #TODO: done, because time seconds value is always in utc: calculate proper timestamp for c2dat taking into account time zone
  zcat c2fbbFull$ver$j.s | cut -d\; -f 1,3 |  join -t\; - <(zcat ../gz/c2datFull$ver$j.s| cut -d\; -f1-2,4)
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[2];$x[3];$x[0]\n" if "$x[0];$x[1]" =~ m/^[0-9a-f]{40};[0-9a-f]{40}$/;' | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl b2taFull$ver.$l. 128
echo b2taFull.$l.

for i in {0..127}
do zcat b2taFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > b2taFull$ver.$l.$i.s
   echo b2taFull$ver.$l.$i.s
done


fi
if test 'WHAT' = 'b2tA'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
  zcat b2taFull$ver$j.s | perl ~/lookup/mapA.perl 2 ../gz/a2AFullH$ver.s | gzip > b2tAFull$ver$j.s
  echo b2tAFull$ver$j.s
done
#use it to create blob reuse map

fi
if test 'WHAT' = 'A2b'; then

l=FROM
for i in {0..3}
do j=$(($i+$l*4))
  zcat b2tAFull$ver$j.s 
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[2];$x[0]\n";' | uniq | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl A2bFull$ver.$l. 32
echo A2bFull$ver.$l.

for i in {0..31}
do zcat A2bFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > A2bFull$ver.$l.$i.s
   echo A2bFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'b2fa'; then #after b2tam

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
 #exclude bad times (prior to Jan 1, 1980) from consideration
 dt=$((3600*24*365*10))
 zcat b2taFull$ver$j.s | perl -e '$pb="";while(<STDIN>){@x=split(/;/);next if $x[1] < '$dt'; print if ($x[0] ne $pb); $pb=$x[0];}' | gzip > b2faFull$ver$j.s
 echo b2faFull$ver$j.s
done


fi
if test 'WHAT' = 'b2fA'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
 #exclude bad times (prior to Jan 1, 1980) from consideration
 #Using ta leads to different results than using fa as mapA.perl drops garbage authors allowing valid author to be first
 dt=$((3600*24*365*10))
 zcat b2taFull$ver$j.s | perl ~/lookup/mapA.perl 2 ../gz/a2AFullH$ver.s  | perl -e '$pb="";while(<STDIN>){@x=split(/;/);next if $x[1] < '$dt';print if ($x[0] ne $pb); $pb=$x[0];}' | gzip > b2fAFull$ver$j.s
 #zcat b2faFull$ver$j.s | perl ~/lookup/mapA.perl 2 ../gz/a2AFullH$ver.s  | gzip > b2fAFull$ver$j.s
 echo b2fAFull$ver$j.s
done

fi
if test 'WHAT' = 'CommonBlobs'; then

for i in {0..127..4}
do zcat b2taFullU$i.s
done | cut -d\; -f1 | uniq -c | awk '{if ($1>1e6)print $2}' |gzip > CommonBlobs0.gz&
for i in {1..127..4}
do zcat b2taFullU$i.s
done | cut -d\; -f1 | uniq -c | awk '{if ($1>1e6)print $2}' |gzip > CommonBlobs1.gz&
for i in {2..127..4}
do zcat b2taFullU$i.s
done | cut -d\; -f1 | uniq -c | awk '{if ($1>1e6)print $2}' |gzip > CommonBlobs2.gz&
for i in {3..127..4}
do zcat b2taFullU$i.s
done | cut -d\; -f1 | uniq -c | awk '{if ($1>1e6)print $2}' |gzip > CommonBlobs3.gz&
wait
zcat CommonBlobs[0-3].gz|gzip > CommonBlobs.gz

fi
if test 'WHAT' = 'b2tP'; then

j=FROM
zcat c2fbbFull$ver$j.s | cut -d\; -f 1,3 | \
 join -t\; - <(zcat ../gz/c2datFull$ver$j.s| cut -d\; -f1-2) | \
 join -t\; <(zcat ../gz/c2PFull$ver$j.s) - |\
 perl -ane 'chop();($c,$p,$b,$t)=split(/;/, $_, -1); print "$b;$t;$p\n" if "$b;$c" =~ m/^[0-9a-f]{40};[0-9a-f]{40}$/;'|\
 perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl b2tP.$j. 128

#fi
#if test 'WHAT' = 'b2tPs'; then

j=FROM
for i in {0..127}
do $HOME/bin/lsort $((maxM*mul))M -t\; -k1,3 -u <(zcat b2tP.$j.$i.gz) | gzip > b2tP.$j.$i.s
echo b2tP.$j.$i.s
done

fi
if test 'WHAT' = 'b2tPm'; then

j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 --merge"
for k in {0..127}
do str="$str <(zcat b2tP.$k.$j.s)"
done
eval $str | gzip > b2tPFull${ver}$j.s
echo b2tPFull${ver}$j.s

fi
if test 'WHAT' = 'b2tPsum'; then

j=FROM
zcat b2tPFull${ver}$j.s | \
  cut -d\; -f1 | uniq -c | awk '{ i++;if($1==1)k++;j+=$1}END{print i";"k";"j}' > b2tPFull${ver}$j.sum 
  #perl -e '$pb="";while(<STDIN>){chop();($b,$t,$p)=split(/;/);if ($pb ne $b && $pb ne ""){$nb++;@ps=keys %pt;if ($#ps > 0){$snbc+=$#ps+1;$lsnbc+=log($#ps+1); $nbc++}; %pt=();}; $pb=$b;$pt{$p}=$t};print "$nb;$nbc;$snbc;$lsnbc\n";' 

#fi
#if test 'WHAT' = 'b2tPdist'; then

j=FROM
zcat b2tPFull${ver}$j.s | \
  cut -d\; -f1 | uniq -c | awk '{print $1}'| $HOME/bin/lsort ${maxM}M -n | uniq -c |awk '{print $2";"$1}'|gzip > b2tPFull${ver}$j.dist

#for j in {0..127}; do zcat b2tPFull${ver}$j.dist; done |awk -F\; '{n[$1]+=$2}END {for (i in n) print i";"n[i]}' > b2tPFull${ver}.dist
#for j in {0..127}; do cat b2tPFull${ver}$j.sum; done |awk -F\; '{i+=$1;j+=$2;k+=$3;print i";"j";"k}'|tail -1 > b2tPFull${ver}.sum

fi
if test 'WHAT' = 'Pt2Ptb'; then

#zcat b2tPFullT$j.s|perl -e '$pb="";$n=0;$i=-1;while(<STDIN>){@x=split(/;/);if($pb eq ""||($n>472640415/10 && $pb ne $x[0])){$i++;open A, "|gzip > b2tPFullT'$j'.$i.s";$n=0 };$pb=$x[0];$n++;print A $_;}'
j=FROM
zcat b2tPFull${ver}$j.s | \
 perl -e '$pb="";while(<STDIN>){chop();($b,$t,$p)=split(/;/);if ($pb ne $b && $pb ne ""){ if ($#ps > 0){for $pp (@ps){print "$ps[0];$pt{$ps[0]};$pp;$pt{$pp};$pb\n" if $pp ne $ps[0];}}; @ps=();%pt=();} $pb=$b; if (! defined $pt{$p}){push @ps, $p; $pt{$p}=$t};}' |\
  perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl Pt2Ptb.$j. 32
  echo Pt2Ptb.$j.

fi
if test 'WHAT' = 'Pt2PtbO1'; then
# if Pt2Ptb does not finish do this
j=FROM
for k in {0..31}
do zcat  Pt2Ptb.$j.$k.gz |tail -2|head -1 |cut -d\; -f5
done > Pt2Ptb.$j.lastblob
nn=$(zcat b2tPFull${ver}$j.s | grep -nFf Pt2Ptb.$j.lastblob | cut -d: -f1 | head -1)
n=$(zcat b2tPFull${ver}$j.s | wc -l)
zcat b2tPFull${ver}$j.s |tail -n +$((nn+1)) | \
perl -e '$pb="";while(<STDIN>){chop();($b,$t,$p)=split(/;/);if ($pb ne $b && $pb ne ""){ if ($#ps > 0){for $pp (@ps){print "$ps[0];$pt{$ps[0]};$pp;$pt{$pp};$pb\n" if $pp ne $ps[0];}}; @ps=();%pt=();} $pb=$b; if (! defined $pt{$p}){push @ps, $p; $pt{$p}=$t};}' |\
perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl Pt2Ptb1.$j. 32

fi
if test 'WHAT' = 'Pt2PtbO2'; then
	# after (if it was run) Pt2PtbO1 do this to clean up
j=FROM
if [[ -f Pt2Ptb1.$j.0.gz ]]
then
for k in {0..31}
do lastb=$(zcat Pt2Ptb1.$j.$k.gz|head -1|cut -d\; -f5|head -1)
   n=$(zcat Pt2Ptb.$j.$k.gz|grep -n $lastb|cut -d: -f1|head -1)
   if [ -z $n ]; then
     n=$(zcat Pt2Ptb.$j.$k.gz|wc -l)
     zcat Pt2Ptb.$j.$k.gz|head -$((n-1)) | gzip > Pt2Ptb.$j.$k.gz0
   else
     zcat Pt2Ptb.$j.$k.gz|head -$((n-1)) | gzip > Pt2Ptb.$j.$k.gz0
   fi
   zcat Pt2Ptb.$j.$k.gz0 Pt2Ptb1.$j.$k.gz |gzip > Pt2Ptb.$j.$k.gz
done
fi

fi
if test 'WHAT' = 'Pt2Ptbs'; then

j=FROM
for i in {0..31}
do $HOME/bin/lsort $((maxM*mul))M -t\; -s -k1,2  <(zcat Pt2Ptb.$j.$i.gz) | gzip > Pt2Ptb.$j.$i.s
echo Pt2Ptb.$j.$i.s
done

fi
if test 'WHAT' = 'Pt2Ptbm'; then

j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -s -k1,2 --merge"
for k in {0..127}
do [[ -f Pt2Ptb.$k.$j.s ]] && str="$str <(zcat Pt2Ptb.$k.$j.s)"
   #[[ -f Pt2Ptb1.$k.$j.s && $(stat --printf="%s" Pt2Ptb1.$k.$j.s) -gt 20 ]] && str="$str <(zcat Pt2Ptb1.$k.$j.s)"
done
eval $str | gzip > Pt2PtbFull${ver}$j.s
echo Pt2PtbFull${ver}$j.s

#measure duration
#zcat Pt2Ptb.0.0.gz|uniq|perl -e 'while(<STDIN>){@x=split(/;/); $x[3]=~s/^0+//;$x[1]=~s/^0+//;next if length($x[1])<9 || length($x[3]) < 4; $v=($x[3]-$x[1])/3600/24/365.25;$ma=$v if $v > $ma;print "@x" if $v > 50;$lv=log($v+.0000001) if $v>=0;$n++;$s+=$v;$ls+=$lv;};print "$ma;$n;".($s/$n).";".(exp($ls/$n))."\n"'
fi
if test 'WHAT' = 'Pbinf'; then

j=FROM
zcat Pt2PtbFull${ver}$j.s | \
  perl $HOME/lookup/pbInfluence.perl | gzip > P2binfFull${ver}$j.s

fi
if test 'WHAT' = 'Pt2Ptbsum'; then

j=FROM
zcat Pt2PtbFull${ver}$j.s | \
 cut -d\; -f1,5 | uniq | cut -d\; -f1 | uniq -c | awk '{ print $2";"$1}' | gzip > P2nfbFull${ver}$j.s

zcat Pt2PtbFull${ver}$j.s | \
 cut -d\; -f1 | uniq -c | awk '{ i++;if($1==1)k++;j+=$1}END{print i";"k";"j}' > Pt2PtbFull${ver}$j.sum

zcat Pt2PtbFull${ver}$j.s | \
 cut -d\; -f1,5 | uniq -c | awk '{ i++;if($1==1)k++;j+=$1}END{print i";"k";"j}' > Pt2PtbFull${ver}$j.sumb

  #perl -e '$pb="";while(<STDIN>){chop();($b,$t,$p)=split(/;/);if ($pb ne $b && $pb ne ""){$nb++;@ps=keys %pt;if ($#ps > 0){$snbc+=$#ps+1;$lsnbc+=log($#ps+1); $nbc++}; %pt=();}; $pb=$b;$pt{$p}=$t};print "$nb;$nbc;$snbc;$lsnbc\n";' 
  #
  ##fi
  ##if test 'WHAT' = 'b2tPdist'; then
  #
  #j=FROM
zcat Pt2PtbFull${ver}$j.s | \
  cut -d\; -f1 | uniq -c | awk '{print $1}'| $HOME/bin/lsort ${maxM}M -n | uniq -c |awk '{print $2";"$1}'|gzip > Pt2PtbFull${ver}$j.dist
  

fi
if test 'WHAT' = 'P2fb'; then

i=FROM
for k in {0..7}
do j=$((k+i*8))
   zcat Pt2PtbFull${ver}$j.s|cut -d\; -f1,5 | uniq | gzip > P2fbFull${ver}$j.s
done

fi
if test 'WHAT' = 'Pt2Ptbannote'; then

j=FROM
zcat Pt2PtbFull${ver}$j.s| perl ~/lookup/annote1.perl | gzip > annote$j.gz


fi
if test 'WHAT' = 'Pt2Ptbannote2'; then

j=FROM
zcat annote$j.gz | perl ~/lookup/annote2.perl | gzip > annote2.$j.gz


fi
if test 'WHAT' = 'Pt2Ptbannote2a'; then

for j in {0..31}
do zcat annote$j.gz 
done | perl ~/lookup/annote2.perl | gzip > annote2.a.gz

fi
if test 'WHAT' = 'Pt2Ptbannote3'; then

j=FROM
k=131
[[ -f annote3.$j.gz$k ]] || exit
for i in {1..199}
do [[ $i -lt $k ]] && eval "from$i=$(zcat annote3.$j.gz$i | wc -l)"
done
from=$(zcat annote3.$j.gz$k | grep -n . | tail -2 | head -1 | cut -d: -f1)
zcat annote3.$j.gz$k |head -$from | gzip > annote3.$j.gz
mv annote3.$j.gz annote3.$j.gz$k
eval "from$k=$(zcat annote3.$j.gz$k | wc -l)"
from=0
for i in {1..199}
do [[ $i -le $k ]] && eval "from=$((from+from$i))"
done
echo $j $k $from
zcat annote$j.gz | perl ~/lookup/annote3.perl $from | gzip > annote3.$j.gz$((k+1))

fi
if test 'WHAT' = 'A2fb'; then

l=FROM   
for i in {0..1}
do j=$(($i+$l*2))
 zcat b2fAFull$ver$j.s | perl -ane '@x=split(/;/);print "$x[2];$x[0]\n" if ($x[2] ne "");' | uniq
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl A2fbFull$ver.$l.  32
echo A2fbFull$ver.$l.

for i in {0..31}
do $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u <(zcat A2fbFull$ver.$l.$i.gz) | gzip > A2fbFull$ver.$l.$i.s
   echo A2fbFull$ver.$l.$i.s
done
#now just need to merge 

fi
if test 'WHAT' = 'a2fb'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2))
 zcat b2faFull$ver$j.s | perl -ane '@x=split(/;/);print "$x[2];$x[0]\n" if ($x[2] ne "");' | uniq
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl a2fbFull$ver.$l.  32 

#fi
#if test 'WHAT' = 'a2fb1'; then

l=FROM
for i in {0..31}
do zcat a2fbFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > a2fbFull$ver.$l.$i.s
   echo a2fbFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'b2ob'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2)); zcat c2fbbFull$ver$j.s | cut -d\; -f3-4 | grep -E '^[0-9a-f]{40};[0-9a-f]{40}$'
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl b2obFull$ver.$l. 128

for i in {0..127}
do zcat b2obFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > b2obFull$ver.$l.$i.s
   echo b2obFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'ob2b'; then

l=FROM
for i in {0..1}
do j=$(($i+$l*2)); zcat c2fbbFull$ver$j.s | cut -d\; -f3-4 | grep -E '^[0-9a-f]{40};[0-9a-f]{40}$'
done | awk -F\; '{print $2";"$1}' | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl ob2bFull$ver.$l. 128

for i in {0..127}
do zcat ob2bFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > ob2bFull$ver.$l.$i.s
   echo ob2bFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'a2f'; then


l=FROM
for i in {0..1} 
do j=$(($i+$l*2));
  zcat c2fFull$ver$j.s | join -t\; <(zcat ../gz/c2datFull$ver$j.s| cut -d\; -f1,4) - | cut -d\; -f2-3 | uniq
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl a2fFull$ver.$l. 32
echo a2fFull$ver.$l.

for i in {0..31}
do zcat a2fFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > a2fFull$ver.$l.$i.s
   echo a2fFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'A2f'; then

l=FROM
for i in 0
do j=$(($i+$l))
 zcat a2fFull$ver$j.s |  perl ~/lookup/mapA.perl 0 ../gz/a2AFullH$ver.s | gzip > A2fFull$ver.$j.gz
 echo A2fFull$ver.$j.gz
done

for i in 0
do j=$(($i+$l))
   zcat A2fFull$ver.$j.gz
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl A2fFull$ver.$l. 32
echo A2fFull$ver.$l.

for i in {0..31}
do $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u <(zcat A2fFull$ver.$l.$i.gz) | gzip > A2fFull$ver.$l.$i.s
   echo A2fFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'A2fmerge'; then

l=FROM
for i in 0
do j=$(($i+$l))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 -u --merge"
  for k in {0..31}; do str="$str <(zcat A2fFull$ver.$k.$j.s)"; done
  eval $str | gzip > A2fFull$ver$j.s
  echo A2fFull$ver$j.s
done

fi
if test 'WHAT' = 'A2mnc'; then

l=FROM
dt=$((3600*24*365*10))
for k in {0..1}
do j=$((k+l*2))
  zcat ../gz/c2PFull$ver$j.s | join -t\; - <(zcat ../gz/c2datFull$ver$j.s|perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[0];$x[1];$x[3]\n" if $x[1] > '$dt';') | \
  perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[3];$x[2];$x[1];$x[0]\n";' |\
  perl ~/lookup/mapA.perl 1 ../gz/a2AFullH$ver.s | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl A2tPcFull$ver.$j. 32 

  for i in {0..31}
  do zcat A2tPcFull$ver.$j.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > A2tPcFull$ver.$j.$i.s
     echo A2tPcFull$ver.$j.$i.s
  done
done

fi
if test 'WHAT' = 'A2mncm'; then

j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
for k in {0..127}
do str="$str <(zcat A2tPcFull$ver.$k.$j.s)"
done
eval $str | gzip > A2tPcFull$ver$j.s
echo A2tPcFull$ver$j.s

zcat A2tPcFull$ver$j.s | perl -ane 'chop();@x=split(/;/);@a=localtime($x[1]);$m=$a[4]+1;$m="0$m" if $m<10;print "$x[0];$x[2];".($a[5]+1900)."-$m\n";' | uniq -c | \
  perl -ane 'chop();s|^\s*||;s| |;|;($n,$p,$a,$t)=split(/;/);print "$p;$t;$a;$n\n"' | $HOME/bin/lsort ${maxM}M -t\; -k1,3 |  \
  perl -e '$pt="";while(<STDIN>){chop();($p,$t,$a,$n)=split(/;/);if($pt ne "$p;$t" && $pt ne ""){print "$pt;$na;$nc\n";$nc=0;$na=0;$pa=""}$pt="$p;$t";$na++ if $pa ne $a;$nc+=$n;$pa=$a} print "$pt;$na;$nc\n";' | \
  gzip > ../gz/A2mncFull$ver$j.s;
echo ../gz/A2mncFull$ver$j.s

fi
if test 'WHAT' = 'A2tspan'; then

l=FROM
dt=$((3600*24*365*10))
for i in {0..7}
do j=$(($i+$l*8))
  zcat ../gz/c2datFull$ver$j.s | cut -d\; -f2,4
done | perl ~/lookup/mapA.perl 1 ../gz/a2AFullH$ver.s | perl -e 'while (<STDIN>){chop();($t,$p)=split(/;/,$_,-1);$pmi{$p}=$t if ($pmi{$p}>$t || !defined $pmi{$p}) && $t > '$dt';$pma{$p}=$t if ($pma{$p}<$t || !defined $pma{$p}) && $t > '$dt';} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}'  | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl A2tspanFull$ver.$l. 32

for i in {0..31}
do $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u <(zcat A2tspanFull$ver.$l.$i.gz) | gzip > A2tspanFull$ver.$l.$i.s
   echo A2tspanFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'A2tspanm'; then

l=FROM
for i in {0..7}
do j=$(($i+$l*8))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 -u --merge"
  for k in {0..15}; do str="$str <(zcat A2tspanFull$ver.$k.$j.s)"; done
  eval $str | gzip > A2tspanFull$ver$j.s
  echo A2tspanFull$ver$j.s
done


fi
if test 'WHAT' = 'P2g'; then

c=/lustre/isaac/scratch/audris/gz
cd $c
l=FROM
zcat P2AFull$ver$l.s | perl ~/lookup/mp.perl 1 A2g$ver.gz 0 | gzip > P2gFull$ver$l.s

fi
if test 'WHAT' = 'b2license'; then

l=FROM
zcat b2fFull$ver$l.s|grep LICENSE | gzip > b2fLICENSEFull$ver$l.s

fi
if test 'WHAT' = 'bL2P'; then

l=FROM
c=/lustre/isaac/scratch/audris/c2fb
cd $c
zcat b2fLICENSEFull$ver$l.s | grep -v / | grep -E ';(LICENSE|LICENSE.txt|LICENSE.md)$' | cut -d\; -f1 | uniq | join -t\; - <(zcat b2P128Full$ver.$l.gz) | gzip > bL2PFull$ver$l.s
echo bL2PFull$ver$l.s

fi
if test 'WHAT' = 'bL2nP'; then

for l in {0..127}
do zcat bL2PFull$ver$l.s | cut -d\; -f1 | uniq -c | sed 's|^\s*||;s| |;|' | perl -ane 'chop();($n,$l)=split(/;/); print "$l;$n\n"'
done | gzip > bL2nPFull$ver.s
echo bL2nPFull$ver.s

for l in {0..127}
do zcat bL2PFull$ver$l.s|perl -ane 'chop();($n,$l)=split(/;/); print "$l;$n\n"' 
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl  P2LFull$ver. 32
echo P2LFull$ver.

for i in {0..31}
do zcat P2LFull$ver.$i.gz|$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > P2LFull$ver$i.s
   echo P2LFull$ver$i.s
done

fi
if test 'WHAT' = 'A2summ'; then
#(t=A2summ; for j in A2c A2f A2P A2fb A2tPllPkg; do for i in {0..31}; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|PRT|$j|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done)
# A2tPlPkg A2[bfc] A2fb 
#for i in {0..31}; do zcat P2AFull$ver$i.s | perl ~/lookup/mp.perl 1 A2g$ver.s 0 | gzip > P2gFullS$i.gz; done
#zcat A2gT.gz |~/lookup/splitSecCh.perl A2summFull.A2g.T 32
#TODO A2fb
c=/lustre/isaac/scratch/audris/gz
cd $c
l=FROM
t=PRT
perl $HOME/lookup/AuthSummary.perl $ver $l $t | gzip > A2summFull.$t.$ver$l.gz

fi
if test 'WHAT' = 'A2summ1'; then



c=$HOME/work/gz
cd $c
l=FROM
t=PRT

a=$(zcat A2summFull.$t.$ver$l.gz | tail -2 | head -1 | cut -d\; -f1)
n=$(zcat A2summFull.$t.$ver$l.gz |grep -n "$a"|cut -d: -f1)
zcat A2summFull.$t.$ver$l.gz | head -$n | gzip > A2summFull.$t.$ver$l.gz0

perl $HOME/lookup/AuthSummary.perl $ver $l $t $n | gzip > A2summFull.$t.$ver$l.gz1

fi
if test 'WHAT' = 'AToFile'; then

c=/lustre/isaac/scratch/audris/gz
cd $c
i=FROM
#perl -I ~/lib/perl5/ ~/lookup/AuthToFile.perl $ver $i | gzip > A2summFull$ver$i.s
perl -I ~/lib/perl5/ ~/lookup/AuthToMongoJson.perl $ver $i | gzip > A2summFull$ver$i.json


fi
if test 'WHAT' = 'P2tspan'; then

dt=$((3600*24*365*10))
l=FROM
for i in {0..7}
do j=$(($i+$l*8))
   zcat ../gz/c2PFull$ver$j.s | join -t\; - <(zcat ../gz/c2datFull$ver$j.s) | cut -d\; -f2,3
done | perl -e 'while (<STDIN>){chop();($p,$t)=split(/;/,$_,-1);$pmi{$p}=$t if ($pmi{$p}>$t || !defined $pmi{$p}) && $t > '$dt';$pma{$p}=$t if ($pma{$p}<$t || !defined $pma{$p}) && $t > '$dt';} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}'  |\
#done | perl -e 'while (<STDIN>){chop();($p,$t)=split(/;/,$_,-1);$pmi{$p}=$t if ($pmi{$p} > $t  !defined $pmi{$p};$pma{$p}=$t if $pma{$p}<$t || !defined $pma{$p}} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}'  | \
  perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl  P2tspanFull$ver.$l. 32
echo P2tspanFull$ver.$l.

for i in {0..31}
do zcat P2tspanFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > P2tspanFull$ver.$l.$i.s
   echo P2tspanFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'P2tspanm'; then
dt=$((3600*24*365*10))
l=FROM   
for i in {0..7}
do j=$(($i+$l*8))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 -u --merge"
  for k in {0..15}; do str="$str <(zcat P2tspanFull$ver.$k.$j.s)"; done
  eval $str | perl -e 'while (<STDIN>){chop();($p, $t0, $t1)=split(/;/,$_,-1);$pmi{$p}=$t0 if ($pmi{$p}>$t0 || !defined $pmi{$p}) && $t0 > '$dt';$pma{$p}=$t1 if ($pma{$p}<$t1 || !defined $pma{$p}) && $t1 > '$dt';} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}' | gzip > P2tspanFull$ver$j.s
  echo P2tspanFull$ver$j.s
done


fi
if test 'WHAT' = 'PToFile'; then

c=/lustre/isaac/scratch/audris/gz
cd $c
i=FROM
#perl -I ~/lib/perl5/ ~/lookup/prjToFile.perl $ver $i | gzip > P2summFull$ver$i.s
perl -I ~/lib/perl5/ ~/lookup/prjToMongoJson.perl $ver $i | gzip > P2summFull$ver$i.json


fi
if test 'WHAT' = 'b2notCopied'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
i=FROM
zcat b2tPFullU$i.s| cut -d\; -f1 | uniq | join -t\; -v2 - <(zcat b2P128FullU.$i.gz) | gzip > b2notCopiedPFullU$i.s

fi
if test 'WHAT' = 'b2notCopiedSplit'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
j=FROM
for i in {0..7}
do k=$((j*8+i)) 
   zcat b2notCopiedPFullU$k.s
done | awk -F\; '{print $2";"$1}' | perl -I /nfs/home/audris/lib/perl5 -I /nfs/home/audris/lookup /nfs/home/audris/lookup/splitSecCh.perl P2notCopiedb.$j. 32
for i in {0..31}
do zcat P2notCopiedb.$j.$i.gz | lsort ${maxM}M -t\; -k1,2 -u | gzip > P2notCopiedb.$j.$i.s
done

fi	
if test 'WHAT' = 'b2notCopiedMerge'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for k in {0..15}
do str="$str <(zcat P2notCopiedb.$k.$j.s)"
done
eval $str | gzip > P2notCopiedbFull$ver$j.s

fi	
if test 'WHAT' = 'P2summ1'; then

c=/lustre/isaac/scratch/audris/gz
cd $c
l=FROM
t=PRT

pp=$(zcat P2summFull.$t.$ver$l.gz | tail -2 | head -1|cut -d\; -f1);
nn=$(zcat P2summFull.$t.$ver$l.gz|grep -n "^$pp;" |head -1|cut -d: -f1)
zcat P2summFull.$t.$ver$l.gz | head -$((nn-1)) | gzip > P2summFull.$t.$ver$l.gz0
perl -I ~/lib/perl5/ -I $HOME/lookup $HOME/lookup/prjSummary.perl $ver $l $t $pp | gzip > P2summFull.$t.$ver$l.gz1
zcat P2summFull.$t.$ver$l.gz[01] |gzip > P2summFull.$t.$ver$l.gz

fi
if test 'WHAT' = 'P2summ'; then
#"B2b", "P2A", "P2b", "P2c", "P2f", "P2g", "P2nfb", "P2p", "P2tspan","P2core","P2mnc"
#P2tAlPkg
#(t=P2summ; for j in P2b P2p P2c P2f P2A P2nfb; do for i in 0; do sed "s|WHAT|$t|g;s|FROM|$i|g;s|PRT|$j|g;s|VER|S|;s|MACHINE|beacon|" ~/lookup/b2ob.pbs | qsub; sleep 1; done; done)
# for P2p need zcat P2p$ver.s | ~/lookup/splitSecCh.perl P2pFull$ver. 32 
# these are used in ToJson directly P2mnc, P2core (see a2p.slurm) 
# need gender for P2g
# How to produce B2b?
# /da5_data/play/forks zcat fP2PStatsT.StrongReuseLinks011-1.crank.map|awk -F\; '{print $2";"$1}' |lsort 100G | gzip > B2bFullT.s

c=/lustre/isaac/scratch/audris/gz
cd $c
l=FROM
t=PRT
# ../c2fb/PnfbFull$ver$j.s: new approach does it in Pt2Ptbsum - check; old[[ "Pnfb" = $t ]] && cp -p ../c2fb/fP2nfbPFull$ver$j.s ../c2fb/PnfbFull$ver$j.s
perl -I ~/lib/perl5/ -I $HOME/lookup $HOME/lookup/prjSummary.perl $ver $l $t | gzip > P2summFull.$t.$ver$l.gz

fi
if test 'WHAT' = 'a2ffix'; then

for i in {1..31}
do lsort 3G -t\; -k1,2 -u --merge <(zcat a2f1FullS.0.$i.s) <(zcat a2f2FullS.2.$i.s) <(zcat a2f2FullS.3.$i.s) <(zcat a2f1FullS.2.$i.s) <(zcat a2f1FullS.3.$i.s) | gzip > a2fFullS.0.$i.s
   echo a2fFull$ver.0.$i.s
done

fi
if test 'WHAT' = 'P2b'; then


l=FROM
for i in {0..1}
do j=$(($i+$l*2));
  zcat c2bFull$ver$j.s | join -t\; <(zcat ../gz/c2PFull$ver$j.s) - 
done | cut -d\; -f2-3 | uniq | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl P2bFull$ver.$l. 32
echo P2bFull$ver.$l.

for i in {0..31}
do zcat P2bFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > P2bFull$ver.$l.$i.s
   echo P2bFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'b2P'; then

  #zcat ../All.blobs/b2sla$j.s | perl ~/lookup/filterByLaSz.perl 450 | gzip > bSelect$j.s
  #echo bSelect$j.s
  #  zcat b2PFull$ver$j.s | cut -d\; -f1 | uniq -c | awk '{ if ($1 > 100) print $2";"$1}' | gzip > largeb2P$j.s

l=FROM
for i in {0..1}
do j=$(($i+$l*2));
  zcat c2bFull$ver$j.s | join -t\; - <(zcat ../gz/c2PFull$ver$j.s) 
done | cut -d\; -f2-3 |uniq| perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl b2PFull$ver.$l. 32
echo b2PFull$ver.$l.

for i in {0..31}
do zcat b2PFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > b2PFull$ver.$l.$i.s
   echo b2PFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'splitb2P'; then

l=FROM
for i in 0
do j=$((i+l));
  zcat b2PFull$ver$j.s | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec2.perl b2P128Full$ver. 128 32 $j 
  echo b2P128Full$ver.
done

fi
if test 'WHAT' = 'export2Plong'; then

j=FROM
zcat bExport$ver$j.s |join -t\;  <(zcat b2P128Full$ver.$j.gz) - | perl -ane 'chop();($b,$p,$e,$l,$ee)=split(/;/);$e=~s/^\s*//;$e=~s/\s*$//;print "$e;$l;$p;$ee\n";' | gzip > export2PLong.$j.gz 

fi
if test 'WHAT' = 'export2Plong1'; then

j=FROM
zcat export2PLong.$j.gz | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl export2PFull$ver.$l. 128

fi
if test 'WHAT' = 'export2Plong2'; then

l=FROM
for i in {0..127}
do zcat export2PFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > export2PFull$ver.$l.$i.s
   echo export2PFull$ver.$l.$i.s
done


fi
if test 'WHAT' = 'export2P'; then

l=FROM
for i in 0
do j=$((i+l));
   zcat bExport$ver$j.s |join -t\;  <(zcat b2P128Full$ver.$j.gz) - 
done | perl -ane 'chop();($b,$p,$e,$l,$ee)=split(/;/);$e=~s/^\s*//;$e=~s/\s*$//;print "$e;$l;$p;$ee\n";' | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl export2PFull$ver.$l. 128

for i in {0..127}
do zcat export2PFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > export2PFull$ver.$l.$i.s
   echo export2PFull$ver.$l.$i.s
done

fi

if test 'WHAT' = 'P2f'; then


l=FROM
for i in {0..1}
do j=$(($i+$l*2));
  zcat c2fFull$ver$j.s | join -t\; <(zcat ../gz/c2PFull$ver$j.s) - | cut -d\; -f2-3 | uniq
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl P2fFull$ver.$l. 32
echo P2fFull$ver.$l.

for i in {0..31}
do zcat P2fFull$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > P2fFull$ver.$l.$i.s
   echo P2fFull$ver.$l.$i.s
done

fi
if test 'WHAT' = 'ctags'; then



c=/lustre/isaac/scratch/audris/All.blobs
cd $c

i=FROM
j=PRT
inc=$((73791582/32))
perl ~/lookup/ctags3.perl $i tkns$i.$j $((inc*j)) $((inc*(j+1)))
echo $i tkns$i.$j $((inc*j)) $((inc*(j+1)))
inc=$((73791582/32))
cat tkns$i.$j.idx | ~/lookup/parseAll.perl $i $((inc*j)) $((inc*(j+1))) | gzip > tkns$i.$j.parse
echo tkns$i.$j.parse
zcat tkns$i.$j.parse | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/parseA.perl $i $((inc*j)) $((inc*(j+1))) | gzip > tkns$i.$j.pkg
echo tkns$i.$j.pkg


fi
if test 'WHAT' = 'ctagsST'; then

c=/lustre/isaac/scratch/audris/All.blobs
cd $c

inc=$((10005266/8))
i=FROM
j=PRT
perl ~/lookup/ctags3ST.perl $i tkns_ST$i.$j $((inc*j)) $((inc*(j+1)))
echo $i tkns_ST$i.$j
cat tkns_ST$i.$j.idx | ~/lookup/parseAllST.perl $i $((inc*j)) $((inc*(j+1))) ST | gzip > tkns_ST$i.$j.parse
echo tkns_ST$i.$j.parse
zcat tkns_ST$i.$j.parse | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/parseAST.perl $i $((inc*j)) $((inc*(j+1))) ST | gzip > tkns_ST$i.$j.pkg

fi
if test 'WHAT' = 'ctagsTU'; then

c=/lustre/isaac/scratch/audris/All.blobs
cd $c
#15852307/8
#1981538.37500000000000000000
inc=$((15952307/8))
i=FROM
j=PRT
perl ~/lookup/ctags3TU.perl $i tkns_TU$i.$j $((inc*j)) $((inc*(j+1)))
echo $i tkns_TU$i.$j
cat tkns_TU$i.$j.idx | ~/lookup/parseAllST.perl $i $((inc*j)) $((inc*(j+1))) TU | gzip > tkns_TU$i.$j.parse
echo tkns_TU$i.$j.parse
zcat tkns_TU$i.$j.parse | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/parseAST.perl $i $((inc*j)) $((inc*(j+1))) TU | gzip > tkns_TU$i.$j.pkg

fi
if test 'WHAT' = 'pkgMergeTU'; then

c=/lustre/isaac/scratch/audris/tkns
cd $c

l=FROM
for i in {0..31}
do j=$((i+l*32))
  (for k in {0..8}
  do [[ -f ../All.blobs/tkns_$pVer$ver$j.$k.pkg ]] && zcat ../All.blobs/tkns_$pVer$ver$j.$k.pkg | grep -v ';JS;'  
  done |  perl -ane 'print if m|^[0-9a-f]{40};|;' | grep -v ';JS;'; zcat ../c2fb/blob_$pVer${ver}_$j.jsdeps) | perl -ane 'print if m|^[0-9a-f]{40};|;' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip >  b2lPkg$pVer$ver$j.s

  zcat b2lPkg$pVer$ver$j.s | $HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge - <(zcat b2lPkg$pVer$j.s | perl -ane 'print if m|[0-9a-f]{40};|;') | gzip > b2lPkg$ver$j.s
  echo b2lPkg$ver$j.s
done


fi
if test 'WHAT' = 'b2tk'; then

c=/lustre/isaac/scratch/audris/tkns
cd $c

#for i in {0..127}; do cat tkns$i.*.idx |cut -d\; -f5-6 | awk -F\; '{print $2";"$1}' | lsort 3G -t\; -k1,2 -u | gzip > b2tkFullS$i.s; done &
#for i in {0..127}; do cat tkns$i.*.idx |cut -d\; -f5-6; done | ~/lookup/splitSec.perl tk2bFullS. 128 &
#for i in {0..127}; do zcat tk2bFullS.$i.gz |lsort 3G -t\; -k1,2 -u | gzip > tk2bFullS$i.s; done &

l=FROM
for i in 0
do j=$((i+l))
  cat ../All.blobs/tkns_$pVer${ver}$j.*.idx |cut -d\; -f5-6 | awk -F\; '{print $2";"$1}' | lsort ${maxM}M -t\; -k1,2 -u | gzip > b2tkFull$pVer${ver}$j.s
  zcat b2tkFull$pVer$j.s | lsort ${maxM}M -t\; -k1,2 -u  --merge - <(zcat b2tkFull$pVer${ver}$j.s) | gzip > b2tkFull$ver$j.s
  zcat tk_$pVer${ver}2info.$j.gz | cut -d\; -f1,6 | awk -F\; '{print $2";"$1}' | lsort ${maxM}M -t\; -k1,2 -u | gzip > tk2bFull$pVer${ver}$j.s
  zcat tk2bFull$pVer$j.s | lsort ${maxM}M -t\; -k1,2 -u  --merge - <(zcat tk2bFull$pVer${ver}$j.s) | gzip > tk2bFull$ver$j.s
done

fi
if test 'WHAT' = 'invPkg'; then

pp=/lustre/isaac/scratch/audris/tkns
l=FROM
for i in {0..1}
do j=$((i+l*2))
   zcat $pp/b2lPkg$ver$j.s | join -t\; <(zcat b2P128Full$ver.$j.gz) - | cut -d\; -f2- | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSec.perl PlPkg$ver.$l. 128  
done

for i in {0..127}
do zcat PlPkg$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > PlPkg$ver.$l.$i.s
   echo PlPkg$ver.$l.$i.s
done


fi
if test 'WHAT' = 'invPkgm'; then

l=FROM
for i in {0..1}
do j=$((i+l*2))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..63}
  do str="$str <(zcat PlPkg$ver.$k.$j.s)"
  done
  eval $str | gzip > PlPkg$ver$j.s
  #project;language;cobination of packages in a single blob
  echo PlPkg$ver$j.s
done

#zcat Pkg2lPS{[0-9],[1-3][0-9]}.s|cut -d\; -f1,2| uniq -c |sed 's|^\s*||;s| |;|' | awk -F\; '{if ($1>300)print $3";"$2";"$1}' |gzip > Pkg2lCnt

fi
if test 'WHAT' = 'Pdef2lP'; then

pp=/lustre/isaac/scratch/audris/tkns
l=FROM
for i in 0
do j=$((i+l*1))
   zcat $pp/blob_$j.defs | join -t\; <(zcat b2P128Full$ver.$j.gz) - | cut -d\; -f2-
done | uniq | perl -ane 'chop();($p,$l,@P)=split(/;/);$f=pop @P if $l eq "JS"; for $pp (@P){print "$pp;$l;$p\n";}' | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSecCh.perl Pdef2lP$ver.$l. 32

fi
if test 'WHAT' = 'Pkg2lP'; then
#good
pp=/lustre/isaac/scratch/audris/tkns
l=FROM
for i in 0
do j=$((i+l*1))
   zcat $pp/b2lPkg$ver$j.s | join -t\; <(zcat b2P128Full$ver.$j.gz) - | cut -d\; -f2- 
done | uniq | perl -ane 'chop();($p,$l,@P)=split(/;/);$f=pop @P if $l eq "JS"; for $pp (@P){$pp=~s|\.\*;$|;|;$pp=~s|\s+| |g;$pp=~s|^\s*||;$pp=~s|\s*$||;$pp=~s|^[iI]mport ||;$pp=~s|^[\./]+||g;print "$pp;$l;$p\n";}' | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSecCh.perl Pkg2lP$ver.$l. 32
 
for i in {0..31}
do zcat Pkg2lP$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,3 -u | gzip > Pkg2lP$ver.$l.$i.s
   echo Pkg2lP$ver.$l.$i.s
done


fi
if test 'WHAT' = 'Pkg2lPm'; then
#good
pp=/lustre/isaac/scratch/audris/tkns
l=FROM

for i in 0
do j=$((i+l*1))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 -u --merge"
  for k in {0..127}
  do str="$str <(zcat Pkg2lP$ver.$k.$j.s)"
  done
  eval $str | gzip > Pkg2lP$ver$j.s
  echo Pkg2lP$ver$j.s
done

fi
if test 'WHAT' = 'Pkg2lPmm'; then

pp=/lustre/isaac/scratch/audris/tkns
l=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 -u --merge"
for k in {0..31}
do str="$str <(zcat Pkg2lP$ver$k.s)"
done
eval $str | gzip > Pkg2lPFull$ver.s

fi
if test 'WHAT' = 'c2pkg'; then
#good
c=/lustre/isaac/scratch/audris/c2fb
cd $c
l=FROM
for i in {0..1}
do j=$((i+l*2))
  #zcat b2lFile$ver$j.s | join -t\; - <(zcat b2lPkg$ver$j.s) | join -t\; <(zcat ../c2fb/b2taFull$ver$j.s) -
  zcat ../tkns/b2lPkg$ver$j.s | join -t\; <(zcat ../c2fb/bb2cfFull$ver$j.s) -
done | perl -ane 'chop(),($b, $bo, $c, $f, @x)=split(/;/);print "$c;$b;$f;".(join ";", @x)."\n"' | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSec.perl c2bflPkg$ver.$l. 128
echo c2bflPkg$ver.$l.

for i in {0..128}
do zcat c2bflPkg$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > c2bflPkg$ver.$l.$i.s
   echo c2blfPkg$ver.$l.$i.s
done

fi
if test 'WHAT' = 'cjoinTU'; then

#no need to add file, better get it from c2fb/bb2cf, investigate more
c=/lustre/isaac/scratch/audris/tkns
cd $c
l=FROM
for i in {0..7}
do j=$((i+l*8))
for k in {0..8}; do [[ -f ../All.blobs/tkns_$pVer$ver$j.$k.parse ]] && zcat ../All.blobs/tkns_$pVer$ver$j.$k.parse; done | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > b2lFile$pVer$ver$j.s
   $HOME/bin/lsort ${maxM}M -t\; -k1,3 --merge <(zcat b2lFile$pVer$ver$j.s) <(zcat b2lFile$pVer$j.s) |gzip > b2lFile$ver$j.s
   echo b2lFile$ver$j.s
done

fi

if test 'WHAT' = 'cjoinST'; then
# old, bad, multiplies c for each b
c=/lustre/isaac/scratch/audris/tkns
cd $c
l=FROM
for i in {0..7}
do j=$((i+l*8))
   for k in {0..7}; do zcat ../All.blobs/tkns_ST$j.$k.parse; done | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > b2lFileST$j.s
   $HOME/bin/lsort ${maxM}M -t\; -k1,3 --merge <(zcat b2lFileST$j.s) <(zcat b2lFileS$j.s) |gzip > b2lFile$ver$j.s
   echo b2lFile$ver$j.s
done

for i in {0..7}
do j=$((i+l*8))
  zcat b2lFile$ver$j.s | join -t\; - <(zcat b2lPkg$ver$j.s) | join -t\; <(zcat ../c2fb/b2cFull$ver$j.s) -
done | perl -ane 'chop(),($a,$b,@x)=split(/;/);print "$b;$a;".(join ";", @x)."\n"' | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSec.perl c2blfPkg$ver.$l. 128
echo c2blfPkg$ver.$l.

for i in {0..128}
do zcat c2blfPkg$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > c2blfPkg$ver.$l.$i.s
   echo c2blfPkg$ver.$l.$i.s
done


fi
if test 'WHAT' = 'cjoin'; then
# old, bad, multiplies c for each b
c=/lustre/isaac/scratch/audris/tkns
cd $c

l=FROM
for i in {0..7}
do j=$((i+l*8))
   for k in {0..31}; do zcat tkns$j.$k.parse; done | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > b2lFile$ver$j.s
done

for i in {0..7}
do j=$((i+l*8))
   zcat b2lFile$ver$j.s | join -t\; - <(zcat b2lPkg$ver$j.s) | join -t\; <(zcat ../c2fb/b2cFull$ver$j.s) - 
done | perl -ane 'chop(),($a,$b,@x)=split(/;/);print "$b;$a;".(join ";", @x)."\n"' | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSec.perl c2blfPkg$ver.$l. 128 
echo c2blfPkg$ver.$l.

for i in {0..128}
do zcat c2blfPkg$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > c2blfPkg$ver.$l.$i.s
   echo c2blfPkg$ver.$l.$i.s
done

fi
if test 'WHAT' = 'c2pkgm'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c

for k in {0..3}
do i=$((FROM*4+k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge"
  for l in {0..63}
  do str="$str <(zcat c2bflPkg$ver.$l.$i.s)"
  done
  eval $str | join -t\; <(zcat ../gz/c2datFull$ver$i.s|cut -d\; -f1,2,4) - | join -t\; <(zcat ../gz/c2PFull$ver$i.s) - | gzip > c2PtabflPkgFull$ver$i.s 
  echo c2tabflPkg$ver$i.s
done

fi
if test 'WHAT' = 'c2pkgA'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
l=FROM
for i in {0..3}
do j=$((i+l*4))
  zcat c2PtabflPkgFull$ver$j.s | perl ~/lookup/mapA.perl 3 ../gz/a2AFullH$ver.s | gzip > c2PtAbflPkgFull$ver$j.s
done

fi
if test 'WHAT' = 'c2defA'; then

c=/lustre/isaac/scratch/audris/tkns
cd $c
l=FROM
for i in {0..3}
do j=$((i+l*4))
  zcat ../c2fb/c2PtabflDefFull$ver$j.s | perl ~/lookup/mapA.perl 3 ../gz/a2AFullH$ver.s | gzip > ../c2fb/c2PtAbflDefFull$ver$j.s
done

fi
if test 'WHAT' = 'c2def'; then

l=FROM
for i in {0..1}
do j=$((i+l*2))
   zcat b2defFull$ver$j.s | join -t\; <(zcat ../c2fb/bb2cfFull$ver$j.s) -
done | perl -ane 'chop(),($b,$bo,$c,$f,$l,$def,$f1)=split(/;/);print "$c;$b;$f;$l;$def\n"' | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSec.perl c2bflDef$ver.$l. 128
echo c2btalfDef$ver.$l.

for i in {0..127}
do zcat c2bflDef$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > c2bflDef$ver.$l.$i.s
   echo c2bflDef$ver.$l.$i.s
done


fi
if test 'WHAT' = 'c2defm'; then

l=FROM
for i in {0..3}
do j=$((i+l*4))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge"
  for k in {0..63}
  do str="$str <(zcat c2bflDef$ver.$k.$j.s)"
  done
  eval $str | join -t\; <(zcat ../gz/c2datFull$ver$j.s|cut -d\; -f1,2,4) - | join -t\; <(zcat ../gz/c2PFull$ver$j.s) - | gzip > c2PtabflDefFull$ver$j.s
done

fi
if test 'WHAT' = 'def2P'; then
#this is an overall def to project map, should be equivalent to one obtained from c2def

cd /lustre/isaac/scratch/audris/c2fb
l=FROM
for i in {0..3}
do j=$((i+l*4))
  zcat b2defFull$ver$j.s | join -t\; <(zcat b2P128FullU.$j.gz) -
done | perl -ane 'chop();($b,$P,$l,$def,$f)=split(/;/);print "$l:$def;$P\n"' | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl def2P.$l. 32

for i in {0..31}
do zcat def2P.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > def2P.$l.$i.s
   echo def2P.$l.$i.s
done

fi
if test 'WHAT' = 'def2Pm'; then

cd /lustre/isaac/scratch/audris/c2fb
i=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for l in {0..31}
do str="$str <(zcat def2P.$l.$i.s)"
done
eval $str | gzip > def2PFull$ver$i.s

fi


if test 'WHAT' = 'cenrich'; then
# bad, multiplies c for each b
c=/lustre/isaac/scratch/audris/tkns
cd $c
l=FROM
for i in {0..7}
do j=$((i+l*8))
   zcat c2blfPkg$ver$j.s | join -t\; <(zcat ../gz/c2datFull$ver$j.s|cut -d\; -f1-2,4) - | \
      join -t\; <(zcat ../gz/c2PFull$ver$j.s) - | \
      cut -d\; -f1-8,10-  | gzip > c2PtabllfPkgFull$ver$j.s
   echo c2PtabllfPkgFull$ver$j.s
done
fi
if test 'WHAT' = 'APIbyAx'; then
#old
for i in FROM
do zcat ../gz/A2summFull.A2tPllPkg.$ver$i.gz |grep ';api;' | \
  #perl -e 'while(<STDIN>){chop();($a, $x, $l, @pkg)=split(/;/);for $p0 (@pkg){($p,$c)=split(/=/, $p0);$p2l{$p}{$l}+=$c}};while (($k, $v)  = each %p2l){for $v1 (keys %$v){print "$v1;$k;$p2l{$k}{$v1}\n";}}' | gzip > l2pkg$i.gz
  perl -e 'while(<STDIN>){chop();($a, $x, $l, @pkg)=split(/;/);for $p0 (@pkg){($p,$c)=split(/=/, $p0);$p2l{$p}{$a}+=$c}};while (($k, $v)  = each %p2l){for $v1 (keys %$v){print "$v1;$k;$p2l{$k}{$v1}\n";}}' | gzip > A2pkg$i.gz
  #zcat l2pkg$i.gz | grep -v ';;' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | \
  zcat A2pkg$i.gz | grep -v ';;' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | \
    perl -e '$tc=0;$tk="";while(<STDIN>){chop();($l,$ap,$c)=split(/;/);if ($k ne "" && $k ne "$l;$ap"){print "$k;$tc\n";$tc=0;};$k="$l;$ap";$tc+=$c;}; print "$k;$tc\n"' |\
    #gzip > l2pkg$i.s
    gzip > A2pkg$i.s
done

fi
if test 'WHAT' = 'APIbyAxs'; then
#old
for i in FROM 
do zcat A2pkg$i.s | \
  perl -ane 'chop();($au,$ap,$n)=split(/;/);$ap=~s|^\s*||;$ap=~s|\\|/|g;$ap=~s|\s*$||;$ap=~s|/\*$||;$ap=~s|\.\./||g;$ap=~s|^\./||g;$ap=~s|[/\.][\*\$]*$||;@x=split(/[\/\.]/, $ap);@a=(pop @x);$a[0]=~s|^\s*||;$a[0]=~s|^import\s*||;$a[0]=~s|\s*$||; while ($z= pop @x){ $z=~s|^\s*||;$z=~s|\s*$||;@a=(@a, $z);} print "".(join "/", @a).";$au;$n\n"' | \
  $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > API2AN$i.s2
done 
#do str="$str <(zcat l2pkg$l.s)"
#eval $str |perl -e '$tc=0;$tk="";while(<STDIN>){chop();($l,$ap,$c)=split(/;/);if ($k ne "" && $k ne "$l;$ap"){print "$k;$tc\n";$tc=0;};$k="$l;$ap";$tc+=$c;}; print "$k;$tc\n"' | \

fi
if test 'WHAT' = 'APIbyAxm'; then
#old
str="$HOME/bin/lsort $((maxM*3))M -t\; -k1,2 --merge"
for l in {0..31}
do str="$str <(zcat API2AN$l.s2)"
done
eval $str | gzip > API2AN.s2

fi
if test 'WHAT' = 'APIfreq'; then
#old
c=/lustre/isaac/scratch/audris/tkns
cd $c
l=FROM
j=$l
zcat A2tPllPkgFull$ver$j.s | cut -d\; -f4,6- | uniq -c | sed 's|^\s*||;s| |;|' | perl -ane 'chop();($n,$l,@pkg)=split(/;/); for $p (@pkg){ print "$l;$p;$n\n" }' | gzip > L2APIN$ver$l.gz
zcat L2APIN$l.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | perl -e '$tc=0;$tk="";while(<STDIN>){chop();($l,$ap,$c)=split(/;/);if ($k ne "" && $k ne "$l;$ap"){print "$k;$tc\n";$tc=0;};$k="$l;$ap";$tc+=$c;}; print "$k;$tc\n"' | gzip > L2APIN$ver$l.s

fi
if test 'WHAT' = 'APIfreqm'; then

#old
c=/lustre/isaac/scratch/audris/tkns
cd $c
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge"
for l in {0..31}
do str="$str <(zcat L2APIN$ver$l.s)"
done
eval $str |perl -e '$tc=0;$tk="";while(<STDIN>){chop();($l,$ap,$c)=split(/;/);if ($k ne "" && $k ne "$l;$ap"){print "$k;$tc\n";$tc=0;};$k="$l;$ap";$tc+=$c;}; print "$k;$tc\n"' | gzip > L2APIN$ver.s

fi
if test 'WHAT' = 'APIbyA'; then
#
c=/lustre/isaac/scratch/audris/c2fb
cd $c
l=FROM
for i in {0..3}
do j=$((i+l*4))
   zcat c2PtAbflPkgFull$ver$j.s | perl -ane 'chop();($c,$P,$t,$a,$b,$f,$l,@pkg)=split(/;/);pop @pkg if $l eq "JS";$pp=join ";", @pkg;$pp=~s/^;*//;$pp=~s/;;/;/g; print "$a;$t;$P;$l;$pp\n" if $#pkg >= 0;'
done | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSecCh.perl A2tPlPkg$ver.$l. 32

#fi
#if test 'WHAT' = 'APIbyAs'; then

for j in {0..31}
do zcat A2tPlPkg$ver.$l.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > A2tPlPkg$ver.$l.$j.s
   echo A2tPlPkg$ver.$l.$j.s
done

fi
if test 'WHAT' = 'APIbyAm'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
for k in {0..1}
do i=$((FROM*2+k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge"
  for l in {0..31}
  do str="$str <(zcat A2tPlPkg$ver.$l.$i.s)"
  done
  eval $str | gzip > A2tPlPkgFull$ver$i.s
  echo A2tPlPkgFull$ver$i.s
done

fi
if test 'WHAT' = 'APIsumm'; then
# rerun on 
c=/lustre/isaac/scratch/audris/c2fb
cd $c
l=FROM
for i in {0..3}
do j=$((i+l*4))
   zcat c2PtAbflPkgFull$ver$j.s | perl -ane 'chop();($c,$P,$t,$a,$b,$f,$l,@pkg)=split(/;/);pop @pkg if $l eq "JS";if ($f !~ /node_modules/){ for $pp (@pkg){ $pp=~s|\.\*;$|;|;$pp=~s|\s+| |g;$pp=~s|^\s*||;$pp=~s|\s*$||;$pp=~s|^[iI]mport ||;$pp=~s|^[\./]+||g;print "$l:$pp;$t;$P;$a\n" if $pp ne "";}}'
done | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSecCh.perl Pkg2tPA$ver.$l. 32

for j in {0..31}
do zcat Pkg2tPA$ver.$l.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > Pkg2tPA$ver.$l.$j.s
   echo Pkg2tPA$ver.$l.$j.s
done

fi
if test 'WHAT' = 'APIsummm'; then
c=/lustre/isaac/scratch/audris/c2fb

cd $c
for k in 0
do i=$((FROM+k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge"
  for l in {0..31}
  do str="$str <(zcat Pkg2tPA$ver.$l.$i.s)"
  done
  eval $str | gzip > Pkg2tPAFull$ver$i.s
  echo Pkg2tPAFull$ver$i.s
done

fi
if test 'WHAT' = 'APIstat'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
dt=$((3600*24*365*10))
i=$((FROM+k))
zcat Pkg2tPAFull$ver$i.s | perl -e '$pp="";while (<STDIN>){chop();($p,$t,$P,$A)=split(/;/,$_,-1); if ($p ne $pp && pp ne ""){ $na=scalar (keys %as); $np=scalar(keys %ps);print "$pp;$pmi;$pma;$nc;$na;$np\n" if $pp ne "";undef $pmi;undef $pma; undef %ps; $nc=0; undef %as;} $pp=$p; $pl=$l; $nc++;$as{$A}++;$ps{$P}++;$pmi=$t if ($pmi>$t || !defined $pmi) && $t > '$dt';$pma=$t if ($pma<$t || !defined $pma) && $t > '$dt';}$na=scalar (keys %as); $np=scalar(keys %ps);print "$pp;$pmi;$pma;$nc;$na;$np\n" if $pp ne "";'|\
  gzip > Pkg2stat$i.gz

fi
if test 'WHAT' = 'APIbyP'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
l=FROM
for i in {0..3}
do j=$((i+l*4))
   zcat c2PtAbflPkgFull$ver$j.s | perl -ane 'chop();($c,$P,$t,$a,$b,$f,$l,@pkg)=split(/;/);pop @pkg if $l eq "JS";if ($f !~ /node_modules/){ $res="";for $pp (@pkg){ $pp=~s|\.\*;$|;|;$pp=~s|\s+| |g;$pp=~s|^\s*||;$pp=~s|\s*$||;$pp=~s|^[iI]mport ||;$pp=~s|^[\./]+||g;$res.=";$pp" if $pp ne "";} print "$P;$t;$a;$l;$res\n" if $res ne "";}'
done  | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/splitSecCh.perl P2tAlPkg$ver.$l. 32

#fi
##if test 'WHAT' = 'APIbyPs'; then

for j in {0..31}
do zcat P2tAlPkg$ver.$l.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > P2tAlPkg$ver.$l.$j.s
   echo P2tAlPkg$ver.$l.$j.s
done

fi
if test 'WHAT' = 'APIbyPm'; then

c=/lustre/isaac/scratch/audris/c2fb
cd $c
for k in {0..1}
do i=$((FROM*2+k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge"
  for l in {0..31}
  do str="$str <(zcat P2tAlPkg$ver.$l.$i.s)"
  done
  eval $str | gzip > P2tAlPkgFull$ver$i.s
  echo P2tAlPkgFull$ver$i.s
done

fi
if test 'WHAT' = 'tkRefile'; then

c=/lustre/isaac/scratch/audris/tkns
cd $c

for i in {0..127}; do 
  for j in {0..8}; do 
  [[ -f  ../All.blobs/tkns_$pVer$ver$i.$j.idx ]] && cat ../All.blobs/tkns_$pVer$ver$i.$j.idx | awk -F\; '{ print $5";'../All.blobs/tkns_$pVer$ver$i.$j.idx';"$2";"$3";"$4";"$6";"$7}'
  done
done | ~/lookup/splitSec.perl tk_$pVer${ver}2info. 128 

fi
if test 'WHAT' = 'tkRefile1'; then

c=/lustre/isaac/scratch/audris/tkns
cd $c

l=FROM
for k in {0..1}
do i=$((l*2+k))
   zcat tk_$pVer${ver}2info.$i.gz | lsort ${maxM}M -t\; -k3,3 -n | lsort ${maxM}M -t\; -k2,2 -s | gzip > tk_$pVer${ver}2info.$i.o;
   zcat tk_$pVer${ver}2info.$i.o | perl ~/lookup/tkRefile.perl $i tkns_$pVer${ver}
   echo tkRefile.perl $i tkns_$pVer${ver}
done

fi
if test 'WHAT' = 'toparse'; then

# no longer needed a part of existing token extraction
c=/lustre/isaac/scratch/audris/All.blobs
cd $c

i=FROM
j=PRT
inc=$((73791582/32))
cat tkns$i.$j.idx | ~/lookup/parseAll.perl $i $((inc*j)) $((inc*(j+1))) | gzip > tkns$i.$j.parse
echo tkns$i.$j.parse
zcat tkns$i.$j.parse | perl -I ~/lookup -I ~/lib/perl/perl5 ~/lookup/parseA.perl $i $((inc*j)) $((inc*(j+1))) | gzip > tkns$i.$j.pkg 
echo tkns$i.$j.pkg

fi
# is bb2cf needed? apart for file name resolution doing ctags?
if test 'bb2cfSplit' = 'WHAT'; then

l=FROM
for i in {0..1}
do j=$((i+l*2))
  zcat c2fbbFull$ver$j.s 
done | perl -ane  'chop();@x=split(/;/, $_, -1);$bbc="$x[2];$x[3];$x[0]"; print "$bbc;$x[1]\n" if $bbc =~ /^[0-9a-f]{40};[0-9a-f]{40};[0-9a-f]{40}$/' | uniq | \
       perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl bb2cf.$l. 128 
echo bb2cf.$l.

for i in {0..127}
do zcat bb2cf.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > bb2cf.$l.$i.s
   echo bb2cf.$l.$i.s
done

fi
if test 'WHAT' = 'bb2cfMerge'; then

for k in {0..1}
do i=$((FROM*2+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
  for l in {0..63}
  do str="$str <(zcat bb2cf.$l.$i.s)"
  done
  eval $str | gzip > bb2cfFull$ver$i.s
  echo bb2cfFull$ver$i.s
done

fi
if test 'obb2cfSplit' = 'WHAT'; then

l=FROM
for i in {0..1}
do j=$((i+l*2))
  zcat c2fbbFull$ver$j.s
done | perl -ane  'chop();@x=split(/;/, $_, -1);$bbc="$x[3];$x[2];$x[0]"; print "$bbc;$x[1]\n" if $bbc =~ /^[0-9a-f]{40};[0-9a-f]{40};[0-9a-f]{40}$/' | uniq | \
       perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl obb2cf.$l. 128
echo obb2cf.$l.

for i in {0..127}
do zcat obb2cf.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > obb2cf.$l.$i.s
   echo obb2cf.$l.$i.s
done

fi
if test 'WHAT' = 'obb2cfMerge'; then

for k in {0..3}
do i=$((FROM*4+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
  for l in {0..63}
  do str="$str <(zcat obb2cf.$l.$i.s)"
  done
  eval $str | gzip > obb2cfFull$ver$i.s
  echo obb2cfFull$ver$i.s
done

fi
if test 'ob2btkSplit' = 'WHAT'; then

l=FROM
for i in {0..7}
do j=$((i+l*8))
  zcat bb2cfFull$ver$j.s | cut -d\; -f1-2 | join -t\; <(zcat ../tkns/b2tkFull$ver$j.s) -
done | perl -ane  'chop();@x=split(/;/, $_, -1); $obbtk="$x[2];$x[0];$x[1]";print "$obbtk\n" if $obbtk =~ /^[0-9a-f]{40};[0-9a-f]{40};[0-9a-f]{40}$/;' |\
       perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl ob2btk.$l. 128
echo ob2btk.$l.

for i in {0..127}
do zcat ob2btk.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > ob2btk.$l.$i.s
   echo ob2btk.$l.$i.s
done

fi
if test 'WHAT' = 'ob2btkMerge'; then

for k in {0..7}
do i=$((FROM*8+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
  for l in {0..15}
  do str="$str <(zcat ob2btk.$l.$i.s)"
  done
  #check if b2tkFull$ver$j.s has ob's
  eval $str | join -t\; - <(zcat ../tkns/b2tkFull$ver$i.s) | gzip > obb2tkotkFull$ver$i.s
  echo obb2tkotkFull$ver$i.s
done

fi
if test 'WHAT' = 'tk2otk'; then
l=FROM
for i in {0..7}
do j=$((i+l*8))
  zcat obb2tkotkFull$ver$j.s|perl -ane 'chop();($b,$ob,$tk,$otk)=split(/;/);print "$tk\;$otk\n" if $tk ne $otk;' |uniq
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSec.perl tk2otk.$l. 128

for i in {0..128}
do zcat tk2otk.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > tk2otk.$l.$i.s
   echo tk2otk.$l.$i.s
done

fi
if test 'WHAT' = 'tk2otkMerge'; then

for k in {0..7}
do i=$((FROM*8+$k))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for l in {0..15}
  do str="$str <(zcat tk2otk.$l.$i.s)"
  done
  eval $str | gzip > tk2otkFull$ver$i.s
  echo tk2otkFull$ver$i.s
  done

fi
if test 'WHAT' = 'tk2td'; then
l=FROM
for i in {0..7}
do j=$((i+l*8))
   zcat tk2otkFull$ver$j.s | sed 's|;|_|' | join -t\; - <(zcat tk2otktdR$j.s|sed 's|;|_|') | sed 's|_|;|' | gzip > tk2otktd$j.s
   echo tk2otktd$j.s
   zcat tk2otkFull$ver$j.s | sed 's|;|_|' | join -t\; -v1 - <(zcat tk2otktdR$j.s|sed 's|;|_|') | sed 's|_|;|' | gzip > tk2otkNotd$j.s
   echo tk2otkNotd$j.s
done

fi
if test 'WHAT' = 'defs'; then

# runs on da? ??
#here how the output for defs is produced
for i in {5..127..6}; do (zcat /da5_data/basemaps/gz/blob_$i.defs /da?
_data/All.blobs/blob_TU_$i.defs | grep -vE '^[0-9a-f]{40};(Cs|PY)'; zcat blob_$i.{cs,py}defs) | grep -v ';;' | lsort 100G -t\; -k1,3 -
u | gzip > /da3_data/basemaps/gz/b2defFullU$i.s; done
# blob_$j.jsdefs and blob_$j.defs - > dl2PFull and jsdl2PFull
base=dl
ext=defs
l=FROM
for i in {0..1}
do j=$((l*2+i))
   (zcat blob_$j.defs|grep -Ev ';(JS|PY|Cs);';zcat  blob_$j.{js,py,cs}defs) | \
   perl -ane '@x=split(/;/, $_, -1);$f=pop @x;$b=shift @x;$l=shift @x; for $e (@x){ $e=~s|^\s*||; print "$b;$l;$e;$f" if $e ne ""}' |\
     $HOME/bin/lsort ${maxM}M -t\; -k1,2 -t\; | join -t\; <(zcat b2P128FullT.$j.gz) - |\
   perl -ane 'chop;@x=split(/;/);print "$x[3];$x[2];$x[1];$x[4]\n"' 
done | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl ${base}2Pf.$l. 32

for i in {0..31}
do zcat ${base}2Pf.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > ${base}2Pf.$l.$i.s
   echo ${base}2Pf.$l.$i.s
done

fi
if test 'WHAT' = 'defsm'; then

base=dl
j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
for l in {0..63}
do str="$str <(zcat ${base}2Pf.$l.$j.s)"
done
eval $str | gzip > ${base}2PfFull$ver$j.s
echo ${base}2PfFull$ver$j.s

if [[ $base = 'jsdl' ]] 
then zcat ${base}2PfFull$ver$j.s | grep -v ';.*/' |cut -d\; -f1-3|uniq |gzip > ${base}2PFull$ver$j.s # exclude packages/*json, node_modules/*json
else zcat ${base}2PfFull$ver$j.s |cut -d\; -f1-3|uniq |gzip > ${base}2PFull$ver$j.s
fi

fi
if test 'WHAT' = 'defsmm'; then

base=dl
str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
for l in {0..31}
do str="$str <(zcat ${base}2PfFull$ver$l.s)"
done
eval $str | gzip > ${base}2PfFull$ver.s

fi
if test 'WHAT' = 'def2dep'; then

zcat dl2PfFullT.s |cut -d\; -f1,2|uniq|sed 's/;/|/;s/|Java/|java/' | gzip > dl2nPT.g

#pick first part: eg. gensim.model -> gensim 
#zcat Pkg2lPFull$ver.s 
for i in {0..31}; do zcat Pkg2lP$ver$i.s | cut -d\; -f1,2; done |\
  perl -ane 'chop();s/^\s*//;($p,$l)=split(/;/);$r=$p;($r,@x)=split(/\./,$p) if $p =~ /\./ && $l =~ /^(JS|PY|Dart|java|Cs|Kotlin|rb)$/; ($r,@x)=split(/\//,$p) if $p =~ m|/| && $l =~ /^(TypeScript|rb|jl|Go|Dart)$/;print "$r;$l\n"' | \
  lsort 6G -t\; -k1,2  | uniq -c | sed 's|^\s*||;s| |;|' | \
  perl -ane 'chop();($n,$p,$l)=split(/;/);if ($n > 0){print "$p;$l;$n\n"}' | \
  gzip > Pkg2lP$ver.sPre 

#zcat Pkg2lP$ver.s100Pre | sed 's/;/|/' |~/lookup/grepField.perl dl2nP$ver.g 1 > Infra.100
#cut -d\| -f2 Infra.100|cut -d\; -f1|lsort 1G |uniq -c

#  12756 Cs
#   1251 Go
#  38038 JS
#     99 Kotlin
#  26036 PY
#   2301 R
#   1453 Rust
#      5 Scala
#  13420 java
#    512 pl

# investigate these infrastructure packages in dl to see how widely defined

fi
if test 'WHAT' = 'def2depRaw'; then


zcat dl2PfFullT.s |perl -ane 'chop();s/^\s*//;($p,$l,$P,$f)=split(/;/);$r=$p;($r,@x)=split(/\./,$p) if $p =~ /\./ && $l =~ /^(JS|PY|Dart|java|Cs|Kotlin|rb)$/;($r,@x)=split(/\//,$p) if $p =~ m|/| && $l  =~ /^(TypeScript|rb|jl|Go|Dart)$/;print "$r;$l;$P\n"'| lsort 6G -t\; -k1,4 -u |gzip > Dl2PfFullT.s

fi
if test 'WHAT' = 'def2depRaw1'; then

zcat Pkg2lPFull$ver.s | cut -d\; -f1,2 | perl -ane 'chop();s/^\s*//;($p,$l)=split(/;/);print "$p;$l\n"' | lsort 6G -t\; -k1,2 | uniq -c | sed 's|^\s*||;s| |;|' | perl -ane 'chop();($n,$p,$l)=split(/;/);if ($n > 0){print "$p;$l;$n\n"}' |gzip > Pkg2lP$ver.sPreRaw

fi
if test 'WHAT' = 'def2depRaw2'; then
zcat Pkg2lP$ver.s100PreRaw| sed 's/;/|/' |~/lookup/grepField.perl dl2nP$ver.g 1 > Infra.100Raw
zcat dl2PfFullT.s |cut -d\; -f1,2|uniq|sed 's/;/|/;s/|Java/|java/' | gzip > dl2nPT.g
zcat Pkg2lP$ver.s100PreRaw| sed 's/;/|/' |~/lookup/grepField.perl dl2nP$ver.g 1 > Infra.100Raw
lsort 3G -t\; -k1,1 Infra.100Raw |cut -d\; -f1 | gzip > Infra.100Raw.n
zcat dl2PfFullT.s | sed 's/;/|/;s/|Java/|java/' | ~/lookup/grepField.perl  Infra.100Raw.n 1 |gzip > Infra.100Raw.def
zcat Infra.100Raw.def|cut -d\; -f1,2|uniq|lsort 3G -t\; -k1,2 -u|cut -d\; -f1|uniq -c|perl -ane 'chop();s/^\s*//;s| |;|;($c,$p)=split(/;/);print "$p;$c\n"'|lsort 3G -t\; -k1,1 | gzip > Infra.100Raw.def.c
zcat Infra.100Raw.def.c|join -t\; - <(lsort 3G -t\; -k1,1 Infra.100Raw) |sed 's/|/;/' > Infra.100Raw.depdef.c




fi
if test 'WHAT' = 'infra'; then

zcat Dl2PfFullT.s |cut -d\; -f1,2|uniq|sed 's/;/|/;s/|Java/|java/' | gzip > Dl2nPT.g
lsort 3G -t\; -k1,1 Infra.100 |cut -d\; -f1 | gzip > Infra.100.n
zcat Dl2PfFullT.s | sed 's/;/|/;s/|Java/|java/' | ~/lookup/grepField.perl  Infra.100.n 1 |gzip > Infra.100.Def
zcat Infra.100.Def|cut -d\; -f1,2|uniq|lsort 3G -t\; -k1,2 -u|cut -d\; -f1|uniq -c|perl -ane 'chop();s/^\s*//;s| |;|;($c,$p)=split(/;/);print "$p;$c\n"'|lsort 3G -t\; -k1,1 | gzip > Infra.100.Def.c
zcat Infra.100.Def.c|join -t\; - <(lsort 3G -t\; -k1,1 Infra.100) |sed 's/|/;/' > Infra.100.DepDef.c


# 91260228 export2PLong.85.gz
# 92822392 export2PLong.86.gz
# 93340876 export2PLong.73.gz
# 99014892 ST107.0.gz
#102316168 export2PLong.102.gz
##102859196 export2PLong.11.gz
#103916824 ST19.0.gz
#104885956 export2PLong.95.gz
#261376724 ST99.0.gz

fi
if test 'WHAT' = 'def2P'; then
this is an overall def to project map, should be equivalent to one obtained from c2def

cd /lustre/isaac/scratch/audris/c2fb
l=FROM
for i in {0..3}
do j=$((i+l*4))
  zcat b2defFull$ver$j.s | join -t\; <(zcat b2P128FullU.$j.gz) -
done | perl -ane 'chop();($b,$P,$l,$def,$f)=split(/;/);print "$l:$def;$P\n"' | perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl def2P.$l. 32

for i in {0..31}
do zcat def2P.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > def2P.$l.$i.s
   echo def2P.$l.$i.s
done

fi
if test 'WHAT' = 'def2Pm'; then

cd /lustre/isaac/scratch/audris/c2fb
i=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for l in {0..31}
do str="$str <(zcat def2P.$l.$i.s)"
done
eval $str | gzip > def2PFull$ver$i.s

fi
if test 'WHAT' = 'w2bl'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
for j in {0..3}
do zcat blob_$i.winnow$j | perl ~/lookup/win2bl.perl 25 | uniq | ~/lookup/splitSec.perl w2bl$j.$i. 128 &
done

wait

fi
if test 'WHAT' = 'w2bbin'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat w2bFull$ver$i.s0 | perl ~/lookup/toBin.perl w2b0Full$ver$i 4 20
zcat b2wFull$ver$i.s | perl ~/lookup/toBin.perl b2wFull$ver$i 20 4

fi
if test 'WHAT' = 'w2bfbin'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
#perl ~/lookup/fromBin.perl w2b0Full$ver$i 4 20 | gzip > w2bFull$ver$i.s0.fromBin
perl ~/lookup/fromBin.perl b2wFull$ver$i 20 4 | gzip > b2wFull$ver$i.s.fromBin

fi
if test 'WHAT' = 'blobcheck'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
md5sum blob_$i.bin

fi
if test 'WHAT' = 'w2bcheck'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat w2bFull$ver$i.s0 | perl -ane 'chop();print "'w2bFull$ver$i.s0';$_\n" if $_ !~ /^[0-9a-f]{8};[0-9a-f]{40}$/;'
[[ -f b2wFull$ver$i.s ]] && zcat b2wFull$ver$i.s | perl -ane 'chop();print "'b2wFull$ver$i.s';$_\n" if $_ !~ /^[0-9a-f]{40};[0-9a-f]{8}$/;'


fi
if test 'WHAT' = 'w2bls'; then

maxM=$((maxM/8))
cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
for j in {0..3}
do for k in {0..127}; do zcat w2bl$j.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2bl$j.$i.$k.s; done &
done
for j in {0..3}
do for k in {0..127}; do zcat w2bl$j.$i.$k.gz | awk -F\; '{ print $2";"$1}' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > b2wl$j.$i.$k.s; done &
done
wait

fi
if test 'WHAT' = 'b2wlm'; then

maxM=$((maxM))
cd /lustre/isaac/scratch/audris/All.blobs
i=FROM   

for k in {0..127}
do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for j in {0..3}
  do str="$str <(zcat b2wl$j.$i.$k.s)"
  done
  eval $str | gzip >  b2wl.$i.$k.s
done

str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for k in {0..127}
do str="$str <(zcat b2wl.$i.$k.s)"
done
eval $str | gzip >  b2wlFullU$i.s

fi
if test 'WHAT' = 'w2blm3'; then

maxM=$((maxM))
cd /lustre/isaac/scratch/audris/All.blobs
k=FROM

for i in {96..127}
do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
   for j in {0..3}
   do str="$str <(zcat w2bl$j.$i.$k.s)"
   done
   eval $str | gzip >  w2bl.$i.$k.s
done

str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for i in {96..127}
do str="$str <(zcat w2bl.$i.$k.s)"
done
eval $str | gzip >  w2blFullU$k.s3


fi
if test 'WHAT' = 'w2blmm'; then

maxM=$((maxM))
cd /lustre/isaac/scratch/audris/All.blobs
k=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for i in {0..3}
do str="$str <(zcat w2blFullU$k.s$i)"
done
eval $str | gzip >  w2blFullU$k.s

fi
if test 'WHAT' = 'w2nb3'; then

e=3
cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat w2bFullU$i.s$e | cut -d\; -f1 | uniq -c | awk '{print $2";"$1}' | gzip > w2nbFullU$i.s$e
zcat w2nbFullU$i.s$e | awk -F\; '{if ($2<=5000) print $1";"$2}' | gzip > w2SnbFullU$i.s$e
zcat w2nbFullU$i.s$e | awk -F\; '{if ($2>5000) print $1";"$2}' | gzip > w2LnbFullU$i.s$e
##zcat w2bFullU$i.s0 | join -t\; <(zcat w2SnbFullU$i.s0|cut -d\; -f1) - | gzip > w2SbFullU$i.s0
#zcat w2bFullU$i.s0 |  ~/lookup/grepFieldv.perl w2LnbFullU$i.s0 1 | gzip > w2SbFullU$i.s0

fi
if test 'WHAT' = 'w2Sb'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM

#for i in {0..127}; do str="lsort 3G -t\; -k1,2 --merge";for k in {0..3}; do str="$str <(zcat w2nbFullU$i.s$k)"; done; eval $str | perl -e 'while(<STDIN>){chop();($b,$n)=split(/;/);if($pb ne ""&&$pb ne $b){print "$pb;$ns\n";$ns=0};$ns+=$n;$pb=$b};print "$pb;$ns\n"' | gzip > w2nbFullU$i.s; done 
#for i in {0..127}; do zcat w2nbFullU$i.s | awk -F\; '{if ($2>5000) print $1";"$2}'; done | gzip > w2lnbFullU.s
#for i in {0..127}; do zcat w2lnbFullU$i.s | awk -F\; '{if ($2>500) print $1";"$2}'; done | gzip > w2mnbFullU.s
#for i in {0..127}; do zcat w2lnbFullU$i.s | awk -F\; '{if ($2>4000) print $1";"$2}'; done | gzip > w2MnbFullU.s

#this is official w2mnbFullU$i.s/w2mbFullU$i.s
#(zcat w2nbFullU$i.s | awk -F\; '{if ($2>500) print $1";"$2}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > w2mnbFullU$i.s;zcat w2sbFullU$i.s | ~/lookup/grepFieldv.perl w2mnbFullU$i.s 1 | gzip > w2mbFullU$i.s) &
#for i in {0..127}; do zcat w2nbFullU$i.s | awk -F\; '{if ($2>9000) print $1";"$2}'; done | lsort 3G -t\; -k1,1 | gzip > w2SnbFullU.s &
#this is official w2MnbFullU$i.s/w2MbFullU$i.s
#(zcat w2nbFullU$i.s | awk -F\; '{if ($2>2000) print $1";"$2}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > w2MnbFullU$i.s;zcat w2sbFullU$i.s | ~/lookup/grepFieldv.perl w2MnbFullU$i.s 1 | gzip > w2MbFullU$i.s) &
#for i in {0..127}; do zcat w2nbFullU$i.s | awk -F\; '{if ($2>9000) print $1";"$2}'; done | lsort 3G -t\; -k1,1 | gzip > w2SnbFullU.s &
(zcat w2nbFullU$i.s | awk -F\; '{if ($2>9000) print $1";"$2}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > w2SnbFullU$i.s;zcat w2sbFullU$i.s | ~/lookup/grepFieldv.perl w2SnbFullU$i.s 1 | gzip > w2SbFullU$i.s) &
i=$((i+1))
(zcat w2nbFullU$i.s | awk -F\; '{if ($2>9000) print $1";"$2}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > w2SnbFullU$i.s;zcat w2sbFullU$i.s | ~/lookup/grepFieldv.perl w2SnbFullU$i.s 1 | gzip > w2SbFullU$i.s) &
i=$((i+1))
(zcat w2nbFullU$i.s | awk -F\; '{if ($2>9000) print $1";"$2}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > w2SnbFullU$i.s;zcat w2sbFullU$i.s | ~/lookup/grepFieldv.perl w2SnbFullU$i.s 1 | gzip > w2SbFullU$i.s) &
i=$((i+1))
(zcat w2nbFullU$i.s | awk -F\; '{if ($2>9000) print $1";"$2}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > w2SnbFullU$i.s;zcat w2sbFullU$i.s | ~/lookup/grepFieldv.perl w2SnbFullU$i.s 1 | gzip > w2SbFullU$i.s) &

wait
#zcat w2nbFullU$i.s | awk -F\; '{if ($2>3000) print $1";"$2}' | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > w2MnbFullU$i.s
#zcat w2MnbFullU$i.s|join -t\; -v1 - <(zcat w2lnbFullU.s) | gzip > w2MnbFullU$i.ss
#zcat w2sbFullU$i.s | ~/lookup/grepFieldv.perl w2MnbFullU$i.s 1 | gzip > w2MbFullU$i.s

fi
if test 'WHAT' = 'b2sw'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat b2wFullU$i.s | ~/lookup/grepFieldv.perl w2lnbFullU.s 2 | gzip > b2swFullU$i.s &
i=$((i+1))
zcat b2wFullU$i.s | ~/lookup/grepFieldv.perl w2lnbFullU.s 2 | gzip > b2swFullU$i.s &
i=$((i+1))
zcat b2wFullU$i.s | ~/lookup/grepFieldv.perl w2lnbFullU.s 2 | gzip > b2swFullU$i.s &
i=$((i+1))
zcat b2wFullU$i.s | ~/lookup/grepFieldv.perl w2lnbFullU.s 2 | gzip > b2swFullU$i.s &

wait

fi
if test 'WHAT' = 'b2Sw1'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat b2swFullU$i.s | ~/lookup/grepFieldv.perl w2SnbFullU.s 2 | gzip > b2SwFullU$i.s 


fi
if test 'WHAT' = 'b2Mw1'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat b2SwFullU$i.s | ~/lookup/grepFieldv.perl w2MnbFullU.s 2 | gzip > b2MwFullU$i.s


fi
if test 'WHAT' = 'w2cl1'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat b2wFullU$i.s | join -t\; <(zcat b2slfclFullU$i.s|cut -d\; -f1,5|grep ';') - |awk -F\; '{print $3";"$2}' | ~/lookup/splitSec.perl w2cl.$i. 128 

fi
if test 'WHAT' = 'w2Mbi'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
for k in {0..7}
do zcat w2MbFullU$i.s| awk -F\; '{print $2";"$1}'| ~/lookup/splitSec.perl b2Mw.$i. 128 &
   i=$((i+1))
done
wait

fi
if test 'WHAT' = 'b2Mws'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
for k in {0..15}
do
  for j in {88..127..4}; do zcat b2Mw.$j.$i.gz | lsort ${maxM}M -t\; -k1,2 -u | gzip > b2Mw.$j.$i.s; done &
  for j in {89..127..4}; do zcat b2Mw.$j.$i.gz | lsort ${maxM}M -t\; -k1,2 -u | gzip > b2Mw.$j.$i.s; done &
  for j in {90..127..4}; do zcat b2Mw.$j.$i.gz | lsort ${maxM}M -t\; -k1,2 -u | gzip > b2Mw.$j.$i.s; done &
  for j in {91..127..4}; do zcat b2Mw.$j.$i.gz | lsort ${maxM}M -t\; -k1,2 -u | gzip > b2Mw.$j.$i.s; done &
  wait
  i=$((i+1))
done
wait

fi
if test 'WHAT' = 'b2Mwm'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
for k in {0..3}
do str="lsort ${maxM}M -t\; -k1,2 -u --merge";for l in {0..127}; do str="$str <(zcat b2Mw.$l.$i.s)"; done; eval $str | gzip > b2MwFullU$i.s &
   i=$((i+1))
done
wait

fi
if test 'WHAT' = 'w2cl'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat b2wFullU$i.s | join -t\; <(zcat b2slfclFullU$i.s|cut -d\; -f1,5|grep ';') - |awk -F\; '{print $3";"$2}' | ~/lookup/splitSec.perl w2cl.$i. 128 &
i=$((i+1))
zcat b2wFullU$i.s | join -t\; <(zcat b2slfclFullU$i.s|cut -d\; -f1,5|grep ';') - |awk -F\; '{print $3";"$2}' | ~/lookup/splitSec.perl w2cl.$i. 128 &
i=$((i+1))
zcat b2wFullU$i.s | join -t\; <(zcat b2slfclFullU$i.s|cut -d\; -f1,5|grep ';') - |awk -F\; '{print $3";"$2}' | ~/lookup/splitSec.perl w2cl.$i. 128 &
i=$((i+1))
zcat b2wFullU$i.s | join -t\; <(zcat b2slfclFullU$i.s|cut -d\; -f1,5|grep ';') - |awk -F\; '{print $3";"$2}' | ~/lookup/splitSec.perl w2cl.$i. 128 &
wait

fi
if test 'WHAT' = 'cl2w'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat w2clFullU$i.s | awk -F\; '{print $2";"$1}' | ~/lookup/splitSecNum.perl cl2w.$i. 128 &
i=$((i+1))
zcat w2clFullU$i.s | awk -F\; '{print $2";"$1}' | ~/lookup/splitSecNum.perl cl2w.$i. 128 &
i=$((i+1))
zcat w2clFullU$i.s | awk -F\; '{print $2";"$1}' | ~/lookup/splitSecNum.perl cl2w.$i. 128 &
i=$((i+1))
zcat w2clFullU$i.s | awk -F\; '{print $2";"$1}' | ~/lookup/splitSecNum.perl cl2w.$i. 128 &

wait

fi
if test 'WHAT' = 'w2cls1'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
for k in {0..127..4}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &
for k in {1..127..4}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &
for k in {2..127..4}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &
for k in {3..127..4}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &

wait


fi
if test 'WHAT' = 'cl2ws'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
for k in {0..127}; do zcat cl2w.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w.$i.$k.s; done &
i=$((i+1))
for k in {0..127}; do zcat cl2w.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w.$i.$k.s; done &
i=$((i+1))
for k in {0..127}; do zcat cl2w.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w.$i.$k.s; done &
i=$((i+1))
for k in {0..127}; do zcat cl2w.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w.$i.$k.s; done &

wait

fi
if test 'WHAT' = 'cl2wm'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
for l in {0..3} 
do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..127}
  do str="$str <(zcat cl2w.$k.$i.s)"
  done
  eval $str | gzip >  cl2wFullU$i.s &
  i=$((i+1))
done
wait

i=FROM
for l in {0..3}
do zcat cl2wFullU$i.s | cut -d\; -f1 | uniq -c | awk '{print $2";"$1}' | gzip > cl2nwFullU$i.s &
   i=$((i+1))
done
wait

fi
if test 'WHAT' = 'w2cls'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))

for k in {0..127}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &
i=$((i+1))
for k in {0..127}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &
i=$((i+1))
for k in {0..127}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &
i=$((i+1))
for k in {0..127}; do zcat w2cl.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2cl.$i.$k.s; done &


wait

fi
if test 'WHAT' = 'w2clm1'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for k in {0..127}
do str="$str <(zcat w2cl.$k.$i.s)"
done
eval $str | gzip >  w2clFullU$i.s

fi
if test 'WHAT' = 'w2clm'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))


for j in {0..3}
do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
 for k in {0..127}
 do str="$str <(zcat w2cl.$k.$i.s | perl -ane 'print $_ if m/[0-9a-f]{8};[0-9]+$/')"
 done
 eval $str | gzip >  w2clFullU$i.s &
 i=$((i+1))
done

wait


fi
if test 'WHAT' = 'w2ncl'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat w2clFullU$i.s | cut -d\; -f1 | uniq -c | awk '{print $2";"$1}' | gzip > w2nclFullU$i.s &
i=$((i+1))
zcat w2clFullU$i.s | cut -d\; -f1 | uniq -c | awk '{print $2";"$1}' | gzip > w2nclFullU$i.s &
i=$((i+1))
zcat w2clFullU$i.s | cut -d\; -f1 | uniq -c | awk '{print $2";"$1}' | gzip > w2nclFullU$i.s &
i=$((i+1))
zcat w2clFullU$i.s | cut -d\; -f1 | uniq -c | awk '{print $2";"$1}' | gzip > w2nclFullU$i.s &

wait

i=FROM
zcat w2nbFullU$i.s | join -t\; -a2 <(zcat w2nclFullU$i.s) - | awk -F\; '{if (NF==2){print $1";0;"$2} else print $0}' |  gzip > w2nclbFullU$i.s &
i=$((i+1))
zcat w2nbFullU$i.s | join -t\; -a2 <(zcat w2nclFullU$i.s) - | awk -F\; '{if (NF==2){print $1";0;"$2} else print $0}' |  gzip > w2nclbFullU$i.s &
i=$((i+1))
zcat w2nbFullU$i.s | join -t\; -a2 <(zcat w2nclFullU$i.s) - | awk -F\; '{if (NF==2){print $1";0;"$2} else print $0}' |  gzip > w2nclbFullU$i.s &
i=$((i+1))
zcat w2nbFullU$i.s | join -t\; -a2 <(zcat w2nclFullU$i.s) - | awk -F\; '{if (NF==2){print $1";0;"$2} else print $0}' |  gzip > w2nclbFullU$i.s &

wait

fi
if test 'WHAT' = 'w2sbck0'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
zcat w2bFullU$i.s[0-2] | cut -d\; -f2 | grep ^00 | $HOME/bin/lsort ${maxM}M -u | gzip > b00U$i.s0-2
zcat w2SbFullU$i.s[0-2] | cut -d\; -f2 | grep ^00 | $HOME/bin/lsort ${maxM}M -u | gzip > Sb00U$i.s0-2
zcat w2sbFullU$i.s[0-2] | cut -d\; -f2 | grep ^00 | $HOME/bin/lsort ${maxM}M -u | gzip > sb00U$i.s0-2

fi
if test 'WHAT' = 'w2sb'; then

e=3
cd /lustre/isaac/scratch/audris/All.blobs
i=FROM

str="lsort 3G -t\; -k1,2 --merge";
for e in {0..3} 
do str="$str <(zcat w2nbFullU$i.s$e)"
done
eval $str | perl -e 'while(<STDIN>){chop();($b,$n)=split(/;/);if($pb ne ""&&$pb ne $b){print "$pb;$ns\n";$ns=0};$ns+=$n;$pb=$b};print "$pb;$ns\n"' | gzip > w2nbFullU$i.s 
zcat w2nbFullU$i.s | awk -F\; '{if ($2>20000) print $1";"$2}' | gzip > w2lnbFullU$i.s

for e in {0..3}
do zcat w2bFullU$i.s$e | ~/lookup/grepFieldv.perl w2lnbFullU$i.s 1 | gzip > w2sbFullU$i.s$e &
done 
wait

fi
if test 'WHAT' = 'w2b'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
for j in {0..3}
do zcat blob_$i.winnow$j | perl ~/lookup/win2b.perl | uniq | ~/lookup/splitSec.perl w2b$j.$i. 128 &
done
wait

fi
if test 'WHAT' = 'b2ws'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))

for j in {0..3}
do for k in {0..127}
  do zcat w2b$j.$i.$k.gz | awk -F\; '{ print $2";"$1}' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > b2w$j.$i.$k.s
  done &
done  
wait

fi
if test 'WHAT' = 'w2bs'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))

for j in {0..3}
do for k in {0..127}
   do zcat w2b$j.$i.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > w2b$j.$i.$k.s 
   done &
done
wait

fi
if test 'WHAT' = 'b2wm'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))

for j in {0..3}
do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
   for k in {0..127}
   do str="$str <(zcat b2w$j.$i.$k.s)"
   done
   eval $str | gzip >  b2w$j.$i.s &
done
wait

fi
if test 'WHAT' = 'b2wmm'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM

str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for j in {0..3}
do str="$str <(zcat b2w$j.$i.s)"
done
eval $str | gzip >  b2wFull$ver$i.s 


fi
if test 'WHAT' = 'w2bm'; then

cd /lustre/isaac/scratch/audris/All.blobs
k=FROM  
maxM=$((maxM/5))

str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2bFullU$k.s$j)";done
eval $str | gzip >  w2bFullU$k.s &
k=$((k+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2bFullU$k.s$j)";done
eval $str | gzip >  w2bFullU$k.s &
k=$((k+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2bFullU$k.s$j)";done
eval $str | gzip >  w2bFullU$k.s &
k=$((k+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2bFullU$k.s$j)";done
eval $str | gzip >  w2bFullU$k.s &


wait

fi
if test 'WHAT' = 'w2sbm'; then

cd /lustre/isaac/scratch/audris/All.blobs
k=FROM  
maxM=$((maxM/5))

str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2sbFullU$k.s$j)";done
eval $str | gzip >  w2sbFullU$k.s &
k=$((k+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2sbFullU$k.s$j)";done
eval $str | gzip >  w2sbFullU$k.s &
k=$((k+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2sbFullU$k.s$j)";done
eval $str | gzip >  w2sbFullU$k.s &
k=$((k+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2sbFullU$k.s$j)";done
eval $str | gzip >  w2sbFullU$k.s &


wait

fi
if test 'WHAT' = 'w2bmm3'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))

str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {96..127}; do str="$str <(zcat w2b.$j.$i.s)";done
eval $str | gzip >  w2bFull$ver$i.s3 &
i=$((i+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {96..127}; do str="$str <(zcat w2b.$j.$i.s)";done
eval $str | gzip >  w2bFull$ver$i.s3 &
i=$((i+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {96..127}; do str="$str <(zcat w2b.$j.$i.s)";done
eval $str | gzip >  w2bFull$ver$i.s3 &
i=$((i+1))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {96..127}; do str="$str <(zcat w2b.$j.$i.s)";done
eval $str | gzip >  w2bFull$ver$i.s3 &


wait

fi
if test 'WHAT' = 'w2bma'; then
cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))

for k in {0..127..4}; do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2b$j.$i.$k.s)";done; [[ -f w2b.$i.$k.s ]] || eval $str | gzip >  w2b.$i.$k.s; done &
for k in {1..127..4}; do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2b$j.$i.$k.s)";done; [[ -f w2b.$i.$k.s ]] || eval $str | gzip >  w2b.$i.$k.s; done &
for k in {2..127..4}; do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2b$j.$i.$k.s)";done; [[ -f w2b.$i.$k.s ]] || eval $str | gzip >  w2b.$i.$k.s; done &
for k in {3..127..4}; do str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"; for j in {0..3}; do str="$str <(zcat w2b$j.$i.$k.s)";done; [[ -f w2b.$i.$k.s ]] || eval $str | gzip >  w2b.$i.$k.s; done &

wait

fi
if test 'WHAT' = 'w2bL'; then

cd /lustre/isaac/scratch/audris/All.blobs


j=FROM
zcat w2bFull$ver$j.s | cut -d\; -f1 | uniq -c | awk '{if($1>100) print $2";"$1}' |\
 gzip > w2bLFull$ver$j.s

fi
if test 'WHAT' = 'cl2w5000'; then

	
cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
SZ=5000

zcat bhistnetIslfclL$i.s| join -t\; - <(zcat b2w${SZ}FullU$i.s) | \
	perl -ane 'chop();@x=split(/;/);$cl=$x[5];$nb=$x[6];$w=$x[7];$seg=$cl%128;$h = sprintf "%.2x", $seg; print "$h;$cl;$w;$nb\n"' | \
       uniq | ~/lookup/splitSec.perl cl2w${SZ}.$i. 128 &
i=$((i+32))
zcat bhistnetIslfclL$i.s| join -t\; - <(zcat b2w${SZ}FullU$i.s) | \
	perl -ane 'chop();@x=split(/;/);$cl=$x[5];$nb=$x[6];$w=$x[7];$seg=$cl%128;$h = sprintf "%.2x", $seg; print "$h;$cl;$w;$nb\n"' | \
       uniq | ~/lookup/splitSec.perl cl2w${SZ}.$i. 128 &
i=$((i+32))
zcat bhistnetIslfclL$i.s| join -t\; - <(zcat b2w${SZ}FullU$i.s) | \
	perl -ane 'chop();@x=split(/;/);$cl=$x[5];$nb=$x[6];$w=$x[7];$seg=$cl%128;$h = sprintf "%.2x", $seg; print "$h;$cl;$w;$nb\n"' | \
       uniq | ~/lookup/splitSec.perl cl2w${SZ}.$i. 128 &
i=$((i+32))
zcat bhistnetIslfclL$i.s| join -t\; - <(zcat b2w${SZ}FullU$i.s) | \
	perl -ane 'chop();@x=split(/;/);$cl=$x[5];$nb=$x[6];$w=$x[7];$seg=$cl%128;$h = sprintf "%.2x", $seg; print "$h;$cl;$w;$nb\n"' | \
       uniq | ~/lookup/splitSec.perl cl2w${SZ}.$i. 128 &

wait

fi
if test 'WHAT' = 'cl2w5000s'; then


cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
SZ=5000

for j in {0..127}
do zcat cl2w${SZ}.$i.$j.gz  | cut -d\; -f2- | grep -v ';$' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w${SZ}.$i.$j.s
done &
i=$((i+32))
for j in {0..127}
do zcat cl2w${SZ}.$i.$j.gz  | cut -d\; -f2- | grep -v ';$' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w${SZ}.$i.$j.s
done &
i=$((i+32))
for j in {0..127}
do zcat cl2w${SZ}.$i.$j.gz  | cut -d\; -f2- | grep -v ';$' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w${SZ}.$i.$j.s
done &
i=$((i+32))
for j in {0..127}
do zcat cl2w${SZ}.$i.$j.gz  | cut -d\; -f2- | grep -v ';$' | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > cl2w${SZ}.$i.$j.s
done &


wait

fi
if test 'WHAT' = 'cl2w5000m'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
maxM=$((maxM/5))
SZ=5000
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge";for j in {0..127};do str="$str <(zcat cl2w${SZ}.$j.$i.s)";done
eval $str | gzip > cl2w${SZ}Full$ver$i.s &
i=$((i+32))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge";for j in {0..127};do str="$str <(zcat cl2w${SZ}.$j.$i.s)";done
eval $str | gzip > cl2w${SZ}Full$ver$i.s &
i=$((i+32))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge";for j in {0..127};do str="$str <(zcat cl2w${SZ}.$j.$i.s)";done
eval $str | gzip > cl2w${SZ}Full$ver$i.s &
i=$((i+32))
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge";for j in {0..127};do str="$str <(zcat cl2w${SZ}.$j.$i.s)";done
eval $str | gzip > cl2w${SZ}Full$ver$i.s &

wait

fi
if test 'WHAT' = 'w2b5000'; then
cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
SZ=5000
maxM=$((maxM/5))
perl ~/lookup/fromBin1.perl w2bFullU$i 4 20 0 $SZ | perl ~/lookup/toBin.perl w2b${SZ}Full$ver$i 20 &
i=$((i+32))
perl ~/lookup/fromBin1.perl w2bFullU$i 4 20 0 $SZ | perl ~/lookup/toBin.perl w2b${SZ}Full$ver$i 20 &
i=$((i+32))
perl ~/lookup/fromBin1.perl w2bFullU$i 4 20 0 $SZ | perl ~/lookup/toBin.perl w2b${SZ}Full$ver$i 20 &
i=$((i+32))
perl ~/lookup/fromBin1.perl w2bFullU$i 4 20 0 $SZ | perl ~/lookup/toBin.perl w2b${SZ}Full$ver$i 20 &
wait

fi
if test 'WHAT' = 'win'; then

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
inc=25000000
zcat blob_$i.idxf | ~/swsc/contentMatch/main blob_$i 0 $inc 2> blob_$i.winnow0.err | gzip > blob_$i.winnow0 &
zcat blob_$i.idxf | ~/swsc/contentMatch/main blob_$i $inc $((inc*2)) 2> blob_$i.winnow.err | gzip > blob_$i.winnow1 &
zcat blob_$i.idxf | ~/swsc/contentMatch/main blob_$i $((inc*2)) $((inc*3)) 2> blob_$i.winnow2.err | gzip > blob_$i.winnow2 &
zcat blob_$i.idxf | ~/swsc/contentMatch/main blob_$i $((inc*3)) -1 2> blob_$i.winnow3.err | gzip > blob_$i.winnow3  &
wait

fi
if test 'WHAT' = 'tree'; then

	
module purge
module load bzip2/1.0.8   intel-compilers/2021.2.0

cd /lustre/isaac/scratch/audris/All.blobs
i=FROM
inc=25000000
zcat blob_$i.idxf | head -$inc | gzip > blob_$i.idxf.0 
python3 prs.py $i 0

fi
if test 'WHAT' = 'cofc'; then

cd /lustre/isaac/scratch/audris/c2fb

i=FROM
zcat c2fFullU$i.s | grep -iE 'code\W?(of)?\W?conduct' > $i.c2f1 &
i=$((i+1))
zcat c2fFullU$i.s | grep -iE 'code\W?(of)?\W?conduct' > $i.c2f1 &
i=$((i+1))
zcat c2fFullU$i.s | grep -iE 'code\W?(of)?\W?conduct' > $i.c2f1 &
i=$((i+1))
zcat c2fFullU$i.s | grep -iE 'code\W?(of)?\W?conduct' > $i.c2f1 &

wait

fi

