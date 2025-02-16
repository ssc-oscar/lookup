#!/bin/bash
#SBATCH -J WHAT1.FROM
#SBATCH -A ACF-UTK0011
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=NTASKS
#SBATCH --partition=campus
#SBATCH --time=0-23:59:59
#SBATCH --error WHAT.FROM.o%J
#SBATCH --output WHAT.FROM.o%J
#SBATCH --mail-user=audris@utk.edu
#SBATCH --mail-type=FAIL

module purge
module load bzip2/1.0.8  intel-compilers/2021.2.0

LD_LIBRARY_PATH=/nfs/home/audris/lib:/nfs/home/audris/lib64:$LD_LIBRARY_PATH


c=/lustre/isaac/scratch/audris/All.blobs
c=/lustre/isaac24/scratch/audris/All.blobs
cd $c

ver=VER
maxM=1000
maxA=$(($maxM*32*NTASKS))

if test 'WHAT' == 'c2dat'; then

for i in {0..7}
do j=$((FROM*8+i))
	$HOME/lookup/lstCmt.perl 9 $j | \
perl -ane 'chop(); ($cmt,$tree,$parents,$auth,$cmtr,$ta,$tc,$taz,$tcz,$cm)=split(/;/,$_,-1);print "$cmt;$ta;$taz;$auth;$tree;$parents;$cmtr;$tc;$tcz;$cm\n"' |\
   $HOME/bin/lsort ${maxM}M -t\; -k1,5| gzip > ../gz/c2datFull.$ver.$j.s
   echo ../gz/c2datFull.$ver.$j.s
done 

fi
if test 'WHAT' == 'c2dat0'; then
j=FROM
$HOME/lookup/lstCmt.perl 9 $j | \
perl -ane 'chop(); ($cmt,$tree,$parents,$auth,$cmtr,$ta,$tc,$taz,$tcz,$cm)=split(/;/,$_,-1);print "$cmt;$ta;$taz;$auth;$tree;$parents;$cmtr;$tc;$tcz;$cm\n"' |\
   $HOME/bin/lsort ${maxM}M -t\; -k1,5| gzip > ../gz/c2datFull.$ver.$j.s


fi
if test 'WHAT' == 'c2acp'; then

for i in {0..7}
do j=$((FROM*8+$i))
   #$HOME/lookup/lstCmt.perl 8 $j | perl -ane 'chop();($c,$ta,$tc,$a,$cm,$p)=split(/;/); @ps=split(/:/, $p); $s=join ";",@ps; print "$c;$ta;$tc;$a;$cm;$s\n";'| \
	   zcat ../gz/c2datFull.$ver.$j.s | perl -ane 'chop();($cmt,$tree,$parents,$auth,$cmtr,$ta,$tc,$taz,$tcz,$cm)=split(/;/,$_,-1); @ps=split(/:/, $parents); $s=join ";",@ps; print "$c;$ta;$tc;$auth;$cm;$s\n";'| \
   $HOME/bin/lsort ${maxM}M -t\; -k1,5| gzip > ../gz/c2acpFull.$ver.$j.s
   echo c2acpFull.$ver.$j.s
done

fi
if test 'WHAT' == 'Cmt'; then

	
for k in {0..31}
do for i in {0..3}
 do j=$((k*4+i))
   zcat ../gz/c2acpFull.$ver.$j.s
 done | perl -ane '@x=split(/;/);print "$x[3]\n$x[4]\n";' | uniq  | $HOME/bin/lsort ${maxM}M -t\; -k1,1 -u | gzip > Cmt.$ver.$k.s
done

str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 -u --merge"
for k in {0..31}
do str="$str <(zcat Cmt.$ver.$k.s)"
done 
eval $str | perl -I ~/lookup/ -I ~/lib64/perl5/ -I ~/lib/perl5/ -ane 'use woc;chop($_);print "$_;".(join ";", parseAuthorId($_))."\n";'|gzip > ../gz/Cmt.$ver.split

zcat ../gz/Cmt.$ver.split|cut -d\; -f2,3 | grep -v '^;'|grep -v ';$' |lsort ${maxM}M -t\; -u -k1,2 |gzip > ../gz/flFull.$ver.s  

zcat flFull.$ver.s|perl -ane 's|[0-9_@"\#!\!\%\$\(\)&*\+\}\{\?\<\>\=\[\`\^\~\]/:\\]||g;print'|sed "s|['0-9]||g" | \
  perl -ane 'chop();($a,$b)=split(/;/);print "$a;$b\n" if(length($a)>1||length($b)>1)'| \
  lsort 1G -u > flFull.$ver.s1

fi
###########################OLD################
if test 'WHAT' == 'c2ch'; then

#for i in {0..3}
for i in 0
do j=$((FROM*1+i))
   #zcat ../gz/c2PFullS$j.s | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge - <(zcat ../gz/MissS/c2PMissS.$j.s) | gzip > ../gz/c2PFullS$j.s1
   #echo ../gz/c2PFullS$j.s1
   $HOME/lookup/lstCmt.perl 9 $j |  gzip > ../gz/c2ch0Full.$ver.$j.gz 
   #$HOME/bin/lsort ${maxM}M -t\; -k1,5 | gzip > ../gz/c2ch0Full.$ver.$j.s 
   #| join -t\; <(zcat ../gz/c2PFull.$ver.$j.s) - | gzip > ../gz/c2chFull.$ver.$j.s
   echo ../gz/c2chFull.$ver.$j.s
done


fi
if test 'WHAT' == 'c2chA'; then
#fix
for i in {0..7}
do j=$((FROM*8+$i))
   zcat ../gz/c2chFull$ver$j.s  | perl ~/lookup/mapAS.perl 4 ../gz/a2AFullH.$ver.s 5 | gzip > ../gz/c2chACFull$ver$j.s
   echo ../gz/c2chACFull$ver$j.s
done

fi
if test 'WHAT' == 'Cmt1'; then
# is this needed??
str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 -u --merge"
for k in {0..31}
do str="$str <(zcat Cmt.$ver.$k.s)"
done 
eval $str | perl -I ~/lookup/ -I ~/lib64/perl5/ -I ~/lib/perl5/ -ane 'use woc;chop($_);print "$_;".(join ";", parseAuthorId($_))."\n";'|gzip > ../gz/Cmt.$ver.split

zcat ../gz/Cmt.$ver.split|cut -d\; -f2,3 | grep -v '^;'|grep -v ';$' |lsort ${maxM}M -t\; -u -k1,2 |gzip > ../gz/fl.$ver.s  

fi

if test 'WHAT' == 'Cmt2'; then
# is this needed??
zcat ../gz/Cmt.$ver.split|cut -d\; -f2,3 | grep -v '^;'|grep -v ';$' |lsort ${maxM}M -t\; -u -k1,2 |gzip > ../gz/fl.$ver.s  

zcat ../gz/fl.$ver.s|perl -ane 's|[0-9_@"\#!\!\%\$\(\)&*\+\}\{\?\<\>\=\[\`\^\~\]/:\\]||g;print'|sed "s|['0-9]||g" | \
  perl -ane 'chop();($a,$b)=split(/;/);print "$a;$b\n" if(length($a)>1||length($b)>1)'| \
  lsort ${maxM}M -u > ../fl.$ver.s1

fi
###################### time verificaion ##################################
if test 'WHAT' == 'checkTime'; then

for i in {0..3}
do j=$((FROM*4+$i))
  zcat ../gz/c2acpFull$ver$j.s 
done | perl -ane 'chop();@x=split(/;/);if($#x>=5){ for $i (5..$#x){ print "$x[$i];$x[0];$x[1];$x[2];$x[3];$x[4]\n"; }}' | ~/lookup/splitSec.perl ../gz/checkTime$ver.FROM. 128
echo checkTime$ver.FROM.

for j in {0..127}
do zcat ../gz/checkTime$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,5 | gzip > ../gz/checkTime$ver.FROM.$j.s
   echo checkTime$ver.FROM.$j.s
done
fi
if test 'WHAT' == 'checkTimeMerge'; then

for i in {0..3}
do j=$((FROM*4+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,5 -u --merge"
  for k in {0..31}
  do str="$str <(zcat ../gz/checkTime$ver.$k.$j.s)"
  done
  eval $str | join -t\; <(zcat ../gz/c2acpFull$ver$j.s | cut -d\; -f1-5) - | gzip > ../gz/checkTime$ver$j.s
done
#zcat checkTimeT0.s|awk -F\; '{if ($2>$3|| $7>$8||$8<$2){print $0}}'|head
fi
if test 'WHAT' == 'checkTimeB'; then

for i in {0..3}
do j=$((FROM*4+$i))
   zcat ../c2fb/b2faFull$ver$j.s| perl -ane 'chop();@x=split(/;/,$_, -1);print "$x[3];$x[0]\n";'
done |perl ~/lookup/splitSec.perl ../c2fb/c2fbFull$ver.FROM. 128

for j in {0..127}
do zcat ../c2fb/c2fbFull$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u  | gzip > ../c2fb/c2fbFull$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'checkTimeB1'; then

for i in {0..3}
do j=$((FROM*4+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..31}
  do str="$str <(zcat ../c2fb/c2fbFull$ver.$k.$j.s)"
  done
  eval $str | gzip > ../c2fb/c2fbFull$ver$j.s
done

fi
if test 'WHAT' == 'checkTimeB2'; then

for i in {0..3}
do j=$((FROM*4+$i))
  zcat ../gz/checkTime$ver$j.s|awk -F\; '{if ($2>$3|| $7>$8||$8<$2){print $0}}'|cut -d\; -f1|uniq | \
    join -t\; - <(zcat ../c2fb/c2fbFull$ver$j.s) | awk -F\; '{print $2";"$1}' | \
     perl ~/lookup/splitSec.perl ../c2fb/badb2fcFull$ver.$j. 128
done
for j in {0..127}
do zcat ../c2fb/badb2fcFull$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u  | gzip > ../c2fb/badb2fcFull$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'checkTimeBm'; then

for i in {0..3}
do j=$((FROM*4+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..31}; do str="$str <(zcat ../c2fb/badb2fcFull$ver.$k.$j.s)"; done
  eval $str | gzip > ../c2fb/badb2fcFull$ver$j.s
done

fi
if test 'WHAT' == 'pc2cacp'; then

for i in {0..3}
do j=$((FROM*4+$i))
  zcat ../gz/c2acpFull$ver$j.s 
done | perl -ane 'chop();@x=split(/;/);if($#x>5){print "$x[5];$x[0];$x[1];$x[2];$x[3];$x[4]"; for $i (6..$#x){print ";$x[$i]";}print "\n";}' | ~/lookup/splitSec.perl ../gz/pc2cacp$ver.FROM. 128
echo pc2cacp$ver.FROM.

for j in {0..127}
do zcat ../gz/pc2cacp$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,5 | gzip > ../gz/pc2cacp$ver.FROM.$j.s
   echo pc2cacp$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'pc2cacpMerge'; then

for i in {0..3}
do j=$((FROM*4+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,5 -u --merge"
  for k in {0..31}
  do str="$str <(zcat ../gz/pc2cacp$ver.$k.$j.s)"
  done
  eval $str | join -t\; <(zcat ../gz/c2acpFull$ver$j.s | cut -d\; -f1-5) - | gzip > ../gz/pcac2cacp$ver$j.s
done

fi
if test 'WHAT' == 'pcac2cacp'; then

for i in {0..127}
do j=$i
  zcat ../gz/pcac2cacp$ver$j.s 
done | perl -ane 'chop();@x=split(/;/);print "$x[10];$x[0];$x[1];$x[2];$x[3];$x[4];$x[5];$x[6];$x[7];$x[8];$x[9]";if($#x>10){for $i (11..$#x){print ";$x[$i]";}}print "\n";' | ~/lookup/splitSec.perl ../gz/pcpcac2cacp$ver. 128
echo pcpcac2cacp$ver.
fi
if test 'WHAT' == 'pcac2cacp1'; then
for j in {0..127}
do zcat ../gz/pcpcac2cacp$ver.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,5 | join -t\; <(zcat ../gz/c2acpFull$ver$j.s | cut -d\; -f1-5) - | gzip > ../gz/pcacpcac2cacp$ver$j.s
   echo pcacpcac2cacp$ver$j.s
done

fi
if test 'WHAT' == 'pcacpcac2cacp'; then

for i in {0..127}
do j=$i
  zcat ../gz/pcacpcac2cacp$ver$j.s
done | perl -ane 'chop();@x=split(/;/);next if $#x < 15;print "$x[15]"; for $i (0..14){print ";$x[$i]";} if($#x>15){for $i (16..$#x){print ";$x[$i]";}}print "\n";' | ~/lookup/splitSec.perl ../gz/pcpcacpcac2cacp$ver. 128
echo pcpcacpcac2cacp$ver.
for j in {0..127}
do zcat ../gz/pcpcacpcac2cacp$ver.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,5 | join -t\; <(zcat ../gz/c2acpFull$ver$j.s|cut -d\; -f1-5) - | gzip > ../gz/pcacpcacpcac2cacp$ver$j.s
   echo pcacpcacpcac2cacp2cacp$ver$j.s
done

fi
if test 'WHAT' == 'pcacpcacpcac2cacp'; then

for i in {0..127}
do j=$i
  zcat ../gz/pcacpcac2cacp$ver$j.s
done | perl -ane 'chop();@x=split(/;/);next if $#x < 20; print "$x[20]"; for $i (0..19){print ";$x[$i]";} if($#x>20){for $i (21..$#x){print ";$x[$i]";}}print "\n";' | ~/lookup/splitSec.perl ../gz/pcpcacpcacpcac2cacp$ver. 128
echo pcpcacpcac2cacp$ver.
for j in {0..127}
do zcat ../gz/pcpcacpcacpcac2cacp$ver.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,5 | join -t\; <(zcat ../gz/c2acpFull$ver$j.s|cut -d\; -f1-5) - | gzip > ../gz/pcacpcacpcacpcac2cacp$ver$j.s
   echo pcacpcacpcacpcac2cacp2cacp$ver$j.s
done

fi
if test 'WHAT' == 'pcAC2cACp'; then

for j in {0..127}
do  zcat ../gz/pcacpcac2cacp$ver$j.s | perl ~/lookup/mapA.perl 3 ../gz/a2AFullH.$ver.s 4 8 9 13 14 | gzip > ../gz/pcACpcAC2cAC$ver$j.s
done

fi
if test 'WHAT' == 'pcACpcAC2cACp'; then

for j in {0..127}
do  zcat ../gz/pcacpcacpcac2cacp$ver$j.s | perl ~/lookup/mapA.perl 3 ../gz/a2AFullH.$ver.s 4 8 9 13 14 18 19 | gzip > ../gz/pcACpcACpcAC2cAC$ver$j.s
done

fi
if test 'WHAT' == 'pcACpcACpcAC2cACp'; then

for j in {0..127}
do  zcat ../gz/pcacpcacpcacpcac2cacp$ver$j.s | perl ~/lookup/mapA.perl 3 ../gz/a2AFullH.$ver.s 4 8 9 13 14 18 19 23 24 | gzip > ../gz/pcACpcACpcACpcAC2cAC$ver$j.s
done

fi
if test 'WHAT' == 'c2ACpCmtr'; then

for i in {0..31}
do j=$((FROM*32+$i))
   zcat ../gz/c2acpFullS$j.s|perl -ane '@x=split(/;/);print "$x[4]\n" if $x[3] ne $x[4];'
done | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,1 -u > ../gz/cmtrs.FROM
echo cmtrs.FROM

fi
if test 'WHAT' == 'c2ACp'; then

for i in {0..7}
do j=$((FROM*8+$i))
 zcat ../gz/c2acpFull$ver$j.s | perl -ane '@x=split(/;/);print $_ if $x[3] ne $x[4];'
done | perl ~/lookup/mapA.perl 3 ../gz/a2AFullH.$ver.s 4 | \
   perl -ane '@x=split(/;/);print "$x[3];$x[4]\n" if $x[3] ne $x[4] && $x[3] ne "" && $x[4] ne "";' | ~/lookup/splitSecCh.perl ../gz/AC$ver.FROM. 32
echo AC$ver.FROM.

fi
if test 'WHAT' == 'c2ACpSrt'; then

for j in {0..31}
do zcat ../gz/AC$ver.FROM.$j.gz | grep -v '^;'| grep -v ';$' | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > ../gz/AC$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'c2ACpMerge'; then

j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for k in {0..15}
do str="$str <(zcat ../gz/AC${ver}.$k.$j.s)"
done
eval $str | gzip > ../gz/AC${ver}$j.s

fi

##########################################################
# this is needed
##########################################################
if test 'WHAT' == 'c2tAsplit'; then

for i in {0..7}
do j=$((FROM*8+$i))
   zcat ../gz/c2datFull$ver$j.s
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[3];$x[0]\n"' | perl ~/lookup/mapA.perl 0 ../gz/a2AFullH.$ver.s | ~/lookup/splitSecCh.perl A2cFull$ver.FROM. 32
echo A2cFull$ver.FROM.

for j in {0..31}
  do zcat A2cFull$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > A2cFull$ver.FROM.$j.s
  echo A2cFull$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'A2cmerge'; then

for i in {0..3}
do j=$((FROM*4+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..15}
  do str="$str <(zcat A2cFull${ver}.$k.$j.s)"
  done
  eval $str | gzip > ../gz/A2cFull${ver}$j.s
  echo ../gz/A2cFull${ver}$j.s
  zcat ../gz/A2cFull$ver$j.s | cut -d\; -f1 | uniq | gzip > ../gz/A$ver$j.s
  echo ../gz/A$ver$j.s
done

fi


if test 'WHAT' == 'c2ta'; then

for i in {0..7}
do j=$((FROM*8+$i))
   zcat ../gz/c2datFull.$ver.$j.s
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[3];$x[0]\n"' | ~/lookup/splitSecCh.perl a2cFull.$ver.FROM. 32
echo a2cFull.$ver.FROM.

for j in {0..31}
  do zcat a2cFull.$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > a2cFull.$ver.FROM.$j.s
  echo a2cFull$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'a2cmerge'; then

for i in {0..3}
do j=$((FROM*4+$i)) 
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..15}
  do str="$str <(zcat a2cFull.${ver}.$k.$j.s)"
  done
  eval $str | gzip > ../gz/a2cFull.${ver}.$j.s 
  echo ../gz/a2cFull.${ver}.$j.s
  zcat ../gz/a2cFull.$ver.$j.s | cut -d\; -f1 | uniq | gzip > ../gz/aFull.$ver.$j.s
  echo ../gz/a$ver.$j.s
done

fi
if test 'WHAT' == 'as'; then

str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 -u --merge"
for i in {0..31}; do str="$str <(zcat ../gz/aFull.$ver.$i.s)"; done 
eval $str | gzip > ../gz/aFull.$ver.s

fi
if test 'WHAT' == 'c2cc'; then

for i in {0..7}
do j=$((FROM*8+$i))
   zcat ../gz/c2datFull.$ver.$j.s
done | perl -ane 'chop();($c,$ta,$tz,$a,$t,$pc)=split(/;/,$_,-1); for $p (split /:/, $pc, -1) { print "$p;$c\n" if $p=~/^[0-9a-f]{40}$/;}' | ~/lookup/splitSec.perl c2ccFull.$ver.FROM. 32
echo c2ccFull$ver.FROM.

for j in {0..31}
  do zcat c2ccFull.$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > c2ccFull.$ver.FROM.$j.s
  echo c2ccFull.$ver.FROM.$j.s
done


fi
if test 'WHAT' == 'c2ccmerge'; then

for i in {0..3}
do j=$((FROM*4+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..15}
  do str="$str <(zcat c2ccFull.${ver}.$k.$j.s)"
  done
  eval $str | gzip > ../gz/c2ccFull.${ver}.$j.s
  echo ../gz/c2ccFull.${ver}.$j.s
done

fi

if test 'WHAT' == 't2csplit'; then

for i in {0..1}
do j=$((FROM*2+$i))
   zcat ../gz/c2datFull.$ver.$j.s
done | perl -ane 'chop();($c,$ta,$tz,$a,$t,$pc)=split(/;/,$_,-1); print "$t;$c\n" if $t=~/^[0-9a-f]{40}$/;' | ~/lookup/splitSec.perl t2cFull.$ver.FROM. 128
echo t2cFull.$ver.FROM.

for j in {0..127}
  do zcat t2cFull.$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > t2cFull.$ver.FROM.$j.s
  echo t2cFull.$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'T2psplit'; then

for i in {0..7}
do j=$((FROM*8+$i))
zcat ../gz/c2datFull.$ver.$j.s | perl -ane 'chop();($c,$ta,$tz,$a,$t,$pc)=split(/;/,$_,-1); print "$c;$t\n" if $t=~/^[0-9a-f]{40}$/;' | \
	join -t\; - <(zcat ../gz/c2pFull.$ver.$j.s) | \
	cut -d\; -f2-3 
done | ~/lookup/splitSec.perl ../gz/T2pFull.$ver.FROM. 128

fi
if test 'WHAT' == 'T2psrt'; then

for i in {0..127}
do zcat ../gz/T2pFull.$ver.FROM.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > ../gz/T2pFull.$ver.FROM.$i.s
done

fi
if test 'WHAT' == 'T2pmerge'; then

for i in {0..3}
do j=$((FROM*4+$i))
 str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
 for k in {0..15}
 do str="$str <(zcat ../gz/T2pFull.${ver}.$k.$j.s)"
 done
 eval $str | gzip > ../gz/T2pFull.${ver}.$j.s
 echo ../gz/T2pFull.${ver}.$j.s
done

fi
if test 'WHAT' == 'c2pc'; then

for i in {0..7}
do j=$((FROM*8+$i))
  zcat ../gz/c2datFull.$ver.$j.s
done | perl -ane 'chop();($c,$ta,$tz,$a,$t,$pc)=split(/;/,$_,-1); for $p (split /:/, $pc, -1) { print "$c;$p\n" if $p=~/^[0-9a-f]{40}$/;}' | ~/lookup/splitSec.perl c2pcFull.$ver.FROM. 32
echo c2pcFull.$ver.FROM.

for j in {0..31}
  do zcat c2pcFull.$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > c2pcFull.$ver.FROM.$j.s
  echo c2pcFull.$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'c2pcmerge'; then

for i in {0..3}
do j=$((FROM*4+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..15}
  do str="$str <(zcat c2pcFull.${ver}.$k.$j.s)"
  done
  eval $str | gzip > ../gz/c2pcFull.${ver}.$j.s
  echo ../gz/c2pcFull.${ver}.$j.s
done

fi
if test 'WHAT' == 'c22pc'; then

n=PRT
n1=$((n+1))
[[ $n == '1' ]] && n=
for i in 0
do j=$((FROM+$i))
   zcat ../gz/c2${n}ccFull$ver$j.s | grep ';' |join -t\; -a1  - <(zcat ../gz/c2pcFull$ver$j.s) 
done | cut -d\; -f2,3 |  ~/lookup/splitSec.perl ../gz/c2${n1}pcFull$ver.FROM. 32
echo ../gz/c2${n1}pcFull$ver.FROM.

for j in {0..31}
  do zcat ../gz/c2${n1}pcFull$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > ../gz/c2${n1}pcFull$ver.FROM.$j.s
  echo ../gz/c2${n1}pcFull$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'cs32'; then

for i in 0
do j=$FROM
  $HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge <(zcat ../gz/csFull$ver$j.s) <(zcat ../gz/csFull$ver$((j+32)).s) <(zcat ../gz/csFull$ver$((j+64)).s) <(zcat ../gz/csFull$ver$((j+96)).s) <(zcat ../gz/c2ccFull$ver$j.s|cut -d\; -f1) |\
    gzip > ../gz/cs32Full$ver$j.s
  zcat ../gz/cs32Full$ver$j.s|join -t\; -v1 - <(zcat ../gz/c2ccFull$ver$j.s) | uniq | gzip > ../gz/c2h0$ver$j.s
  zcat ../gz/cs32Full$ver$j.s|join -t\; -v1 - <(zcat ../gz/c2pcFull$ver$j.s) | uniq | gzip > ../gz/c2r0$ver$j.s
done 

fi
if test 'WHAT' == 'c22cc'; then

n=PRT
n1=$((n+1))
[[ $n == '1' ]] && n=
for i in 0
do j=$((FROM+$i))
   zcat ../gz/c2${n}ccFull$ver$j.s |grep ';' |join -t\; -a1 <(zcat ../gz/c2pcFull$ver$j.s) -
done | cut -d\; -f2,3 |  ~/lookup/splitSec.perl ../gz/c2${n1}ccFull$ver.FROM. 32
echo ../gz/c2${n1}ccFull$ver.FROM.

for j in {0..31}
  do zcat ../gz/c2${n1}ccFull$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > ../gz/c2${n1}ccFull$ver.FROM.$j.s
  echo ../gz/c2${n1}ccFull$ver.FROM.$j.s
done


fi
if test 'WHAT' == 'c22ccm'; then

n=PRT
n1=$((n+1))
n0=$n
[[ $n == '1' ]] && n=
w=c2${n1}cc
for i in 0
do j=$((FROM+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..31}
  do str="$str <(zcat ../gz/${w}Full${ver}.$k.$j.s)"
  done
  eval $str | gzip > ../gz/${w}PreFull${ver}$j.s
  echo ../gz/${w}PreFull${ver}$j.s
  zcat ../gz/${w}PreFull${ver}$j.s | grep -v ';' | join -t\; - <(zcat ../gz/c2ccFull$ver$j.s) | gzip > ../gz/c2h${n0}$ver$j.s
  zcat ../gz/${w}PreFull${ver}$j.s | join -t\; -v1 - <(zcat ../gz/c2h${n0}$ver$j.s|cut -d\; -f1) | gzip >  ../gz/${w}Full${ver}$j.s
done

fi
if test 'WHAT' == 'c22pcm'; then

n=PRT
n0=$n
n1=$((n+1))
[[ $n == '1' ]] && n=
w=c2${n1}pc
for i in 0
do j=$((FROM+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..31}
  do str="$str <(zcat ../gz/${w}Full${ver}.$k.$j.s)"
  done
  eval $str | gzip > ../gz/${w}PreFull${ver}$j.s
  echo ../gz/${w}PreFull${ver}$j.s
  zcat ../gz/${w}PreFull${ver}$j.s|grep -v ';' | join -t\; - <(zcat ../gz/c2pcFull$ver$j.s) | gzip > ../gz/c2r${n0}$ver$j.s 
  zcat ../gz/${w}PreFull${ver}$j.s | join -t\; -v1 - <(zcat ../gz/c2r${n0}$ver$j.s|cut -d\; -f1) | gzip >  ../gz/${w}Full${ver}$j.s
done

fi
if test 'WHAT' == 't2cmerge'; then

for i in {0..1}
do j=$((FROM*2+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..63}
  do str="$str <(zcat t2cFull${ver}.$k.$j.s)"
  done
  eval $str | gzip > ../gz/t2cFull${ver}$j.s
  echo ../gz/t2cFull${ver}$j.s
done

fi



