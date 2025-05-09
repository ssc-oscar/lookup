#!/bin/bash
#SBATCH -J WHAT.FROM
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

c=/lustre/haven/user/audris/gz
c=/lustre/isaac/scratch/audris/gz
c=/nfs/home/audris/work/gz
cd $c


machine=MACHINE
maxM=4000
[[ $machine == monster ]] && maxM=30000
[[ $machine == rho ]] && maxM=900
[[ $machine == sigma ]] && maxM=2900

prt=FROM
ver=VER

if test 'WHAT' = 'T2pcnt'; then

for i in {0..7}
do j=$((prt*8+i))
  zcat T2pFull.${ver}.$j.s| cut -d\; -f1 | uniq -c | awk '{if ($1>=100) print $2";"$1}' | gzip > T2pFull.${ver}.$j.cnt
  zcat c2pFull.${ver}.$j.s| cut -d\; -f1 | uniq -c | awk '{if ($1>=100) print $2";"$1}' | gzip > c2pFull.${ver}.$j.cnt
done

fi
if test 'WHAT' = 'Tp2p'; then

#for i in {0..3}
#do j=$(($prt*4+$i))
j=FROM
zcat T2pFull.${ver}.$j.s | perl -I ~/lib  -I ~/lib64/perl5 ~/lookup/cleanTree.perl | perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > T2pFull.$ver.$j.p2p
echo T2pFull.$ver.$j.p2p
zcat T2pFull.$ver.$j.p2p | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > T2pFull.$ver.$j.p2p.gz
echo T2pFull.$ver.$j.p2p.gz

fi
if test 'WHAT' = 'Tp2ps'; then

j=FROM
zcat T2pFull.$ver.$j.p2p.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > T2pFull.$ver.$j.p2p.s
echo T2pFull.$ver.$j.p2p.s

fi
if test 'WHAT' = 'MERGET'; then

str="lsort $(($maxM))M -t\| --merge"
for i in {0..7}
do j=$((prt*8+i))
	str="$str <(zcat T2pFull.$ver.$j.p2p.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$pstr;$nn\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$pstr;$nn\n";' | \
	        gzip > T2pFull.$ver.p2p.$prt.s
echo T2pFull.$ver.p2p.$prt.s

fi
if test 'WHAT' = 'MERGETM'; then

str="lsort $(($maxM*3))M -t\| --merge"
for i in {0..15}
do str="$str <(zcat  T2pFull.$ver.p2p.$i.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
	   gzip > T2pFull.$ver.np2p.s
echo T2pFull.$ver.np2p.s

fi
if test 'WHAT' = 'p2p'; then

#for i in {0..3}
#do j=$(($prt*4+$i))
j=FROM
zcat c2pFull.${ver}.$j.s | perl -I ~/lib  -I ~/lib64/perl5 ~/lookup/cleanCmt.perl | perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > c2pFull.$ver.$j.p2p
echo c2pFull.$ver.$j.p2p
zcat c2pFull.$ver.$j.p2p | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > c2pFull.$ver.$j.p2p.gz 
echo c2pFull.$ver.$j.p2p.gz

fi
if test 'WHAT' = 'p2ps'; then

j=FROM
zcat c2pFull.$ver.$j.p2p.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > c2pFull.$ver.$j.p2p.s 
echo c2pFull.$ver.$j.p2p.s
#done

fi
if test 'WHAT' = 'MERGE'; then

str="lsort $(($maxM))M -t\| --merge"
for i in {0..7}
do j=$((prt*8+i))
   str="$str <(zcat c2pFull.$ver.$j.p2p.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$pstr;$nn\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$pstr;$nn\n";' | \
     gzip > c2pFull.$ver.p2p.$prt.s
echo c2pFull.$ver.p2p.$prt.s

fi
if test 'WHAT' = 'MERGEM'; then

str="lsort $(($maxM*3))M -t\| --merge"
for i in {0..15}
do str="$str <(zcat  c2pFull.$ver.p2p.$i.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > c2pFull.$ver.np2p.s
echo c2pFull.$ver.np2p.s

fi
if test 'WHAT' = 'defork'; then
#scp -p c2pFull.V2409.np2p.s da5:/data/play/forks
#ver=V2409
#zcat c2pFull.$ver.np2p.s | perl connectExportVw.perl c2pFull.$ver.np2p
#export LD_LIBRARY_PATH=/home/audris/lib64:/home/audris/lib:/home/audris/src/nk/build
#nnodes=$(zcat c2pFull.$ver.np2p.names|wc -l)
#zcat c2pFull.$ver.np2p.versions | /home/audris/src/networkit/cluster $nnodes  | gzip > c2pFull.$ver.np2pu.PLM
#n=c2pFull.$ver.np2p
#zcat ${n}u.PLM | perl rankNew.perl ${n} 1 | gzip >  ${n}.crank.map
#perl reRankV2409.perl ${n}.crank.map 2> p2PFull.$ver.err |gzip > p2PFull.$ver.s
#scp -p da5:/data/play/forks/p2PFull.V2409.s .
#

for i in {0..1}
do j=$((FROM*2+$i))
  #zcat c2pFull$ver$j.s | perl ~/lookup/mp.perl 1 c2pFull$ver.np2pu.PLMmap.forks | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > c2PFull$ver$j.s
  zcat c2pFull.$ver.$j.s | perl ~/lookup/mp.perl 1 p2PFull.$ver.s | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > c2PFull.$ver.$j.s
  echo c2PFull.$ver.$j.s
done

fi
if test 'WHAT' = 'deforkTT'; then

zcat p2PT.s | perl ~/lookup/mp.perl 1 t2PFull$ver.np2pw.crank.map | gzip > p2TT.s

fi
if test 'WHAT' = 'deforkT'; then

for i in 0
do j=$((FROM+$i))
  zcat ../c2fb/b2P128Full$ver.$j.gz | perl ~/lookup/mp.perl 1 t2PFull$ver.np2pw.crank.map | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > ../c2fb/b2TFull$ver$j.s
  echo ../c2fb/b2TFull$ver$j.s
done


fi
if test 'WHAT' = 'deforklw'; then

for i in {0..3}
do j=$((FROM*4+$i))
  zcat c2pFull$ver$j.s | perl ~/lookup/mp.perl 1 c2pFull$ver.np2plw.PLMmap.forks | uniq | lsort ${maxM}M -t\; -k1,2 -u | gzip > c2PuFull$ver$j.s
  echo c2PuFull$ver$j.s
done

fi
if test 'WHAT' = 'deforkP'; then

for i in {0..7}
do j=$((FROM*8+$i))
   zcat c2PFull.$ver.$j.s
done |perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n";' | perl $HOME/lookup/splitSecCh.perl P2cFull.$ver.FROM. 128
echo P2cFull.$ver.$j.s

for j in {0..127}
do zcat P2cFull.$ver.FROM.$j.gz | lsort ${maxM}M -t\; -k1,2 -u | gzip > P2cFull.$ver.FROM.$j.s
done

fi
if test 'WHAT' = 'deforkPm'; then

for i in {0..7}
do j=$((FROM*8+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1b,2 --merge -u"
  for k in {0..15}; do str="$str <(zcat P2cFull.$ver.$k.$j.s)"; done
  eval $str | gzip > P2cFull.$ver.$j.s
  echo P2cFull.$ver.$j.s
done

fi
