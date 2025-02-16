#!/bin/bash
#SBATCH -J WHAT.PRT
#SBATCH -A ACF-UTK0011
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=NTASKS
#SBATCH --partition=campus
#SBATCH --time=0-23:59:59
#SBATCH --error WHAT.PRT.o%J
#SBATCH --output WHAT.PRT.o%J
#SBATCH --mail-user=audris@utk.edu
#SBATCH --mail-type=FAIL

module purge
module load bzip2/1.0.8  intel-compilers/2021.2.0

LD_LIBRARY_PATH=/nfs/home/audris/lib:/nfs/home/audris/lib64:$LD_LIBRARY_PATH

c=/lustre/isaac/scratch/audris/gz
cd $c

maxM=1000
ver=V3
pVer=V2
prt=PRT

if test 'WHAT' = 'START'; then

cd $ver 
for f in *.olist.gz 
do  zcat $f 
done | grep ';commit;' | perl -ane 'chop();s|/;$|;|;s|\.git;||;print "$_\n"' | awk -F\; '{ print $3";"$1}' | perl -ane 'print if $_ =~ m/^[0-f]{40};/' | \
  perl -ane 'chop();s|/$||;s|\.git$||;print "$_\n"' | $HOME/lookup/splitSec.perl c2p. 128

#for f in $ver/*.p2c
#do zcat $f | awk -F\; '{ print $2";"$1}' | perl -ane 'print if $_ =~ m/^[0-f]{40};/'
#done | $HOME/lookup/splitSec.perl c2p$ver. 128
##done | perl $HOME/lookup/fixP1.perl | $HOME/lookup/splitSec.perl c2p$ver$inc. 32
echo c2p.

fi
if test 'WHAT' = 'SRT0'; then

cd $ver
i=$prt
for k in {0..7}
do j=$((i*8+k))
   zcat c2p.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -u -k1,2 | gzip > c2p.$j.s
done 
echo $prt

fi
if test 'WHAT' = 'MRG0'; then
# add c2pExtraU to c2pFullU and also to p2cFullU

cd $ver
for k in {0..3}
do i=$((prt*4+k))
$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge <(zcat ../c2pFull.$pVer.$i.s) <(zcat c2p.$i.s) | gzip > ../c2pFull.${ver}.$i.s
$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge <(zcat ../p2cFull.$pVer.$i.s) <(zcat p2c.$i.s) | gzip > ../p2cFull.${ver}.$i.s
echo c2p${ver}.$i.s
done

fi
if test 'WHAT' = 'MRG0p2c'; then

cd $ver
i=$prt
$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge <(zcat ../p2cFull.$pVer.$i.s) <(zcat p2c.$i.s) | gzip > ../p2cFull.${ver}.$i.s
echo p2c${ver}.$i.s

fi
if test 'WHAT' = 'MRG0c2p'; then

cd $ver
i=$prt
$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge <(zcat ../c2pFull.$pVer.$i.s) <(zcat c2p.$i.s) | gzip > ../c2pFull.${ver}.$i.s
echo c2p${ver}.$i.s

fi

if test 'WHAT' = 'MISS'; then
# identify commits that are in c2p but not in commits_*.idx
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
# perhaps unify project name according to the latest naming convention
#only for Otr.V
for i in {0..127}
do mv c2p${ver}.$i.s c2p${ver}1.$i.s0
   zcat c2p${ver}1.$i.s0 | perl -ane 'chop();s|/$||;s|\.git$||;print "$_\n"'|uniq | gzip > c2p${ver}.$i.s
done

fi
if test 'WHAT' = 'invt'; then
# from c2p to p2c on the new
cd $ver
for i in {0..127}
do zcat c2p.$i.gz
done | awk -F\; '{print $2";"$1}' | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl p2c. 128 
echo p2c.

fi
if test 'WHAT' = 'ISRT0'; then
# sort new p2c
cd $ver
i=$prt
for k in {0..7}
do j=$((k+i*8)) 
zcat p2c.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,1 | gzip > p2c.$j.s 
done
echo p2c.$i.s

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
# just list projects
for i in {0..15}
do j=$(($prt*16+$i))
   zcat p2cFull.${ver}.$j.s | cut -d\; -f1| uniq | gzip > pFull.$ver.$j.s 
   echo p$ver.$j.s
done

fi
if test 'WHAT' = 'MPS'; then
# create one list
str="$HOME/bin/lsort ${maxM}M -t\; -k1,1 --merge"
for k in {0..127}
do str="$str <(zcat pFull.$ver.$k.s)"
done
eval $str | uniq | gzip > pFull.$ver.s
echo pFull.$ver.s

fi
if test 'WHAT' = 'DEFORK'; then
#see defork in forks.pbs 
#
for i in {0..3}
do j=$(($prt*4+$i))
   zcat c2pFull.$ver.$j.s | perl ~/lookup/mp.perl 1 p2PFull.$ver.s | uniq | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u  | gzip > c2PFull.$ver.$j.s 
   echo c2PFull.$ver.$j.s
done
wait
# need to sort, invert for P2c


fi
