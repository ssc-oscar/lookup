#!/bin/bash
#SBATCH -J updateVER.PRT.WHAT
#SBATCH -A ACF-UTK0011
#SBATCH -p campus-beacon-long
##SBATCH -p campus-skylake
#SBATCH -q campus
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=NTASKS
#SBATCH --time=0-23:59:59
#SBATCH --error updtPT.WHAT.PRT.o%J
#SBATCH --output updtPT.WHAT.PRT.o%J
#SBATCH --mail-user=audris@utk.edu
#SBATCH --mail-type=FAIL
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH

c=/lustre/haven/user/audris/gz
cd $c



maxM=1000
ver=V
prt=PRT

if test 'WHAT' = 'addMoreCs'; then

i=PRT
lsort 2G --merge -t\; -k1,1 <(zcat c2pFullU$i.s) <(zcat c2pExtraU$i.s) | uniq | gzip > c2pFullU$i.s1

fi
if test 'WHAT' = 'addMorePs'; then

i=PRT
lsort 2G --merge -t\; -k1,1 <(zcat p2cFullU$i.s) <(zcat p2cExtraU$i.s) |uniq | gzip > p2cFullU$i.s1

fi
if test 'WHAT' = 'START'; then

cd $ver 
for f in New*.$prt.olist.gz 
do  zcat $f 
done | grep ';commit;' | perl -ane 'chop();s|/;$|;|;s|\.git;||;print "$_\n"' | awk -F\; '{ print $3";"$1}' | perl -ane 'print if $_ =~ m/^[0-f]{40};/' | \
  perl -ane 'chop();s|/$||;s|\.git$||;print "$_\n"' | $HOME/lookup/splitSec.perl c2p.$prt. 128

#for f in $ver/*.p2c
#do zcat $f | awk -F\; '{ print $2";"$1}' | perl -ane 'print if $_ =~ m/^[0-f]{40};/'
#done | $HOME/lookup/splitSec.perl c2p$ver. 128
##done | perl $HOME/lookup/fixP1.perl | $HOME/lookup/splitSec.perl c2p$ver$inc. 32
echo c2p$ver.$prt.

fi
if test 'WHAT' = 'SRT2'; then

cd $ver
for i in {0..15}
do k=$((prt*16+i))
   zcat cmt$k | $HOME/bin/lsort ${maxM}M -t\; -u -k1,1 | gzip > cmt$k.s &
done
wait
echo $prt

fi
if test 'WHAT' = 'SRT0'; then

cd $ver
for k in {0..127..4}
do i=$k 
   zcat c2p.$prt.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -u -k1,2 | gzip > c2p.$prt.$i.s &
   i=$((k+1))
   zcat c2p.$prt.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -u -k1,2 | gzip > c2p.$prt.$i.s &
   i=$((k+2))
   zcat c2p.$prt.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -u -k1,2 | gzip > c2p.$prt.$i.s &
   i=$((k+3))
   zcat c2p.$prt.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -u -k1,2 | gzip > c2p.$prt.$i.s &
   wait
done 
echo $prt

fi
if test 'WHAT' = 'MRG0'; then
# add c2pExtraU to c2pFullU and also to p2cFullU

cd $ver
for k in {0..7}
do i=$((prt*8+k))
	str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
   for j in {00..19} # V
   do str="$str <(zcat c2p.$j.$i.s)"
   done
   eval $str | gzip > ../c2p${ver}.$i.s
   echo c2p${ver}.$i.s
done

fi
if test 'WHAT' = 'MISS'; then

cd $ver
for k in {0..7}
do i=$((prt*8+k))
  #zcat ../c2p${ver}.$i.s |join -t\; -v1 - <(zcat cmt$i.s) | cut -d\; -f2 | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | uniq -c | awk '{print $2";"$1}' | gzip > miss$i
  zcat ../c2p${ver}.$i.s | cut -d\; -f1 | uniq |join -t\; -v1 - <(zcat cmt$i.s) | gzip > missc$i
  zcat ../c2p${ver}.$i.s |join -t\; -v1 -  <(zcat missc$i) | cut -d\; -f2 | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | uniq -c | awk '{print $2";"$1}' | gzip > missp$i
done

fi
if test 'WHAT' = 'MISSM'; then

#missCnt not a great option, need to pick only one of the projects that has a missing commit - how to optimize? 
cd $ver
str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge"
for i in {0..127}; do str="$str <(zcat missp$i)"; done
eval $str | perl -e 'while(<STDIN>){chop();($a,$n)=split(/;/); if ($p ne "" && $p ne $a){print "$p;$z\n";$z=0}; $z+=$n;$p=$a;}; print "$p;$z\n"' | gzip > missCnt

fi
if test 'WHAT' = 'CLN'; then

#only for Otr.V
for i in {0..127}
do mv c2p${ver}.$i.s c2p${ver}1.$i.s0
   zcat c2p${ver}1.$i.s0 | perl -ane 'chop();s|/$||;s|\.git$||;print "$_\n"'|uniq | gzip > c2p${ver}.$i.s
done

fi
if test 'WHAT' = 'invt'; then

for i in {0..7}
do j=$((prt*8+i))
   zcat c2p${ver}.$j.s 
done | awk -F\; '{print $2";"$1}' | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl p2c${ver}.$prt. 128 
echo p2c${ver}.$prt.

fi
if test 'WHAT' = 'ISRT0'; then

j=$prt
for i in {0..127}
do zcat p2c${ver}.$j.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > p2c${ver}.$j.$i.s 
   echo p2c${ver}.$j.$i.s
done

fi
if test 'WHAT' = 'IMRG0'; then

for i in {0..7}
do j=$((prt*8+i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge"
  for k in {0..15}
  do str="$str <(zcat p2c${ver}.$k.$j.s)"
  done
  eval $str | uniq | gzip > p2c${ver}.$j.s 
  echo p2c${ver}.$j.s
done

fi
if test 'WHAT' = 'MERGEc2p'; then


for i in {0..7}
do j=$(($prt*8+$i))
   $HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge -u <(zcat c2p${ver}.$j.s) <(zcat c2pFullV$j.s) | perl -ane 'print if $_ =~ m/^[0-f]{40};/' | uniq | gzip > c2pFull${ver}.$j.s 
   echo c2pFull${ver}.$j.s
done

fi
if test 'WHAT' = 'MERGEp2c'; then

for i in {0..1}
do j=$(($prt*2+$i))
   $HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge -u <(zcat p2c${ver}.$j.s) <(zcat p2cFullV$j.s) | perl -ane 'print if $_ =~ m/;[0-9a-f]{40}$/' | uniq | gzip > p2cFull${ver}.$j.s 
   echo p2cFull${ver}$j.s
   zcat p2cFull${ver}$j.s|cut -d\; -f1|uniq | gzip > p${ver}$j.s
done

fi
if test 'WHAT' = 'invFull'; then
#looks like p2c misses some projects

for i in $prt
do j=$i
   zcat c2pFull$ver$j.s
done | awk -F\; '{print $2";"$1}' | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl p2cFull$ver.$prt. 128
echo p2cFull$ver.$prt.

fi
if test 'WHAT' = 'isrtFull'; then

j=$prt
for i in {0..127}
do zcat p2cFull$ver.$j.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > p2cFull$ver.$j.$i.s
   echo p2cFull$ver.$j.$i.s
done

fi
if test 'WHAT' = 'imrgFull'; then

j=$prt
str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge"
for k in {0..127}
do str="$str <(zcat p2cFull$ver.$k.$j.s)"
done
eval $str | uniq | gzip > p2cFull$ver$j.s
echo p2cFull$ver$j.s

fi
if test 'WHAT' = 'PS'; then

for i in {0..7}
do j=$(($prt*8+$i))
   zcat p2cFull${ver}$j.s | cut -d\; -f1| uniq | gzip > p$ver.$j.s 
   echo p$ver.$j.s
done

fi
if test 'WHAT' = 'MPS'; then

str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge"
for k in {0..127}
do str="$str <(zcat p$ver$k.s)"
done
eval $str | uniq | gzip > p$ver.s
echo p$ver.s

fi
if test 'WHAT' = 'DEFORK'; then
#see defork in forks.pbs 
#
for i in {0..3}
do j=$(($prt*4+$i))
   zcat c2pFull$ver$j.s | perl ~/lookup/mp.perl 1 p2P$ver.s | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u  | gzip > c2PFull$ver$j.s 
   echo c2PFull$ver$j.s
done
wait
# need to sort, invert for P2c


fi
