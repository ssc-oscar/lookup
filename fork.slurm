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
ver=V
prt=PRT

if test 'WHAT' = 'p2p'; then

#for i in {0..3}
#do j=$(($prt*4+$i))
j=PRT
zcat c2pFull${ver}$j.s | perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > c2pFull$ver$j.p2p
echo c2pFull$ver$j.p2p
zcat c2pFull$ver$j.p2p | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > c2pFull$ver$j.p2p.gz 
echo c2pFull$ver$j.p2p.gz
zcat c2pFull$ver$j.p2p.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > c2pFull$ver$j.p2p.s 
echo c2pFull$ver$j.p2p.s
#done

fi
if test 'WHAT' = 'MERGE'; then

str="lsort $(($maxM))M -t\| --merge"
for i in {0..7}
do j=$((prt*8+i))
   str="$str <(zcat c2pFull$ver$j.p2p.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$pstr;$nn\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$pstr;$nn\n";' | \
     gzip > c2pFull$ver.p2p.$prt.s
echo c2pFull$ver.p2p.$prt.s

fi
if test 'WHAT' = 'MERGEM'; then

str="lsort $(($maxM*3))M -t\| --merge"
for i in {0..15}
do str="$str <(zcat  c2pFull$ver.p2p.$i.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > c2pFull$ver.np2p.s
echo c2pFull$ver.np2p.s

fi
if test 'WHAT' = 'defork'; then

	# use community detection on c2pFull$ver.np2p to get
# c2pFullS.np2p.PLMmap.forks and c2pFullS.np2pw.PLMmap.forks
#zcat p$ver.s | awk -F\; '{print $1";"$1}' | perl ~/lookup/mp.perl 1 c2pFull$ver.np2pu.PLMmap.forks | gzip > p2P$ver.s
#zcat p2P$ver.s | awk -F\; '{print $2";"$1}' | lsort 3G -t\; -k1,2 | gzip > P2p$ver.s 

#zcat c2pFull$ver.np2p.s | perl connectExportVw.perl c2pFull$ver.np2p
#zcat /data/c2pFull$ver.np2p.versions | /home/audris/src/networkit/cluster $(zcat /data/c2pFull$ver.np2p.names|wc -l)  | gzip > /data/c2pFull$ver.np2pu.PLM
#n=c2pFullV5.np2pu
#zcat ${n}.PLM | perl rankNew.perl c2pFull$ver.np2p 1 | gzip >  ${n}.crank.map
#perl reRank.perl 2> err3 | gzip > p2PV.s



for i in {0..1}
do j=$((PRT*2+$i))
  #zcat c2pFull$ver$j.s | perl ~/lookup/mp.perl 1 c2pFull$ver.np2pu.PLMmap.forks | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > c2PFull$ver$j.s
  zcat c2pFull$ver$j.s | perl ~/lookup/mp.perl 1 p2P$ver.s | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > c2PFull$ver$j.s
  echo c2PFull$ver$j.s
done

fi
if test 'WHAT' = 'deforkTT'; then

zcat p2PT.s | perl ~/lookup/mp.perl 1 t2PFull$ver.np2pw.crank.map | gzip > p2TT.s

fi
if test 'WHAT' = 'deforkT'; then

for i in 0
do j=$((PRT+$i))
  zcat ../c2fb/b2P128Full$ver.$j.gz | perl ~/lookup/mp.perl 1 t2PFull$ver.np2pw.crank.map | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > ../c2fb/b2TFull$ver$j.s
  echo ../c2fb/b2TFull$ver$j.s
done


fi
if test 'WHAT' = 'deforklw'; then

for i in {0..3}
do j=$((PRT*4+$i))
  zcat c2pFull$ver$j.s | perl ~/lookup/mp.perl 1 c2pFull$ver.np2plw.PLMmap.forks | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > c2PuFull$ver$j.s
  echo c2PuFull$ver$j.s
done

fi
if test 'WHAT' = 'deforkP'; then

for i in {0..7}
do j=$((PRT*8+$i))
   zcat c2PFull$ver$j.s
done |perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n";' | perl $HOME/lookup/splitSecCh.perl P2cFull$ver.PRT. 128
echo P2cFull$ver$j.s

for j in {0..127}
do zcat P2cFull$ver.PRT.$j.gz | lsort ${maxM}M -t\; -k1,2 -u | gzip > P2cFull$ver.PRT.$j.s
   echo P2cFull$ver.PRT.$j.s
done

fi
if test 'WHAT' = 'deforkPm'; then

for i in {0..7}
do j=$((PRT*8+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1b,2 --merge -u"
  for k in {0..15}; do str="$str <(zcat P2cFull$ver.$k.$j.s)"; done
  eval $str | gzip > P2cFull$ver$j.s
  echo P2cFull$ver$j.s
done

fi
