#!/bin/bash
#SBATCH -J WHAT.FROM
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

c=/lustre/isaac/scratch/audris/gz
c=$HOME/work/gz
cd $c

maxM=1000
ver=VER
prt=PRT

maxA=$(($maxM*32))

prt=FROM

if test 'WHAT' == 'splitCA'; then

dt=$((3600*24*365*10))
l=FROM
for i in {0..1}
do j=$((l*2+i)) 
  zcat c2PFull.$ver.$j.s | join -t\; - <(zcat c2datFull.$ver.$j.s|perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[0];$x[1];$x[3]\n" if $x[1] > '$dt';') | \
     perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[2];$x[3];$x[0]\n";' |\
     perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl P2tacFull.$ver.$j. 32
  echo P2tacFull.$ver.$j.

  for i in {0..31}
  do zcat P2tacFull.$ver.$j.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > P2tacFull.$ver.$j.$i.s
     echo P2tacFull.$ver.$j.$i.s
  done
done

fi
if test 'WHAT' == 'mergeCA'; then

j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,4 -u --merge"
for k in {0..127}
do str="$str <(zcat P2tacFull.$ver.$k.$j.s)"
done
eval $str | gzip > P2tacFull.$ver.$j.s
echo P2tacFull.$ver.$j.s


fi
if test 'WHAT' == 'cntCA'; then

j=FROM
zcat P2tacFull.$ver.$j.s | perl -ane 'chop();@x=split(/;/);@a=localtime($x[1]);$m=$a[4]+1;$m="0$m" if $m<10;print "$x[0];$x[2];".($a[5]+1900)."-$m\n";' | uniq -c | \
  perl -ane 'chop();s|^\s*||;s| |;|;($n,$p,$a,$t)=split(/;/);print "$p;$t;$a;$n\n"' | $HOME/bin/lsort ${maxM}M -t\; -k1,3 |  perl -e '$pt="";while(<STDIN>){chop();($p,$t,$a,$n)=split(/;/);if($pt ne "$p;$t" && $pt ne ""){print "$pt;$na;$nc\n";$nc=0;$na=0;$pa=""}$pt="$p;$t";$na++ if $pa ne $a;$nc+=$n;$pa=$a} print "$pt;$na;$nc\n";' | gzip > P2mncFull.$ver.$j.s;


fi
if test 'WHAT' == 'coreCA'; then

j=FROM
zcat P2tacFull.$ver.$j.s | perl ~/lookup/mapA.perl 2 a2AFullH.$ver.s | perl -ane 'chop();@x=split(/;/);print "$x[0];$x[2]\n";' | uniq -c | \
  perl -ane 'chop();s|^\s*||;s| |;|;($n,$p,$a)=split(/;/);print "$p;$a;$n\n"' | \
    perl -e '$pp="";$s=0;while(<STDIN>){chop();($p,$aa,$n)=split(/;/);if ($pp ne "" && $pp ne $p){ $cm=0;print "$pp";for $au (sort {$t{$b}<=>$t{$a}} keys %t){$cm+=$t{$au};print ";$au=$t{$au}";last if $cm >= $s*.8;};print "\n";%t=();$s=0;};$pp=$p;$t{$aa}+=$n;$s+=$n};print "$pp";for $au (sort {$t{$b}<=>$t{$a}} keys %t){$cm+=$t{$au};print ";$au=$t{$au}";last if $cm >= $s*.8;};print "\n";' | gzip > P2coreFull.$ver.$j.s

fi
if test 'WHAT' == 'splitCAA'; then


for j in {0..31}
do zcat P2tacFull.$ver.FROM.$j.s | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[0];$x[2]\n";' | $HOME/bin/lsort $((maxM/2))M -t\; -k1,2 | uniq -c | lsort $((maxM/2))M -rn | perl -ane 'chop();s|^\s*||;s| |;|;($n,$p,$a)=split(/;/);print "$p;$a;$n\n"' | gzip > P2ancFull.$ver.FROM.$j.s
   echo P2ancFull.$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'miss'; then

for i in {0..3}
do j=$((FROM*4+$i))
   zcat ../gz/c2pFullS$j.s | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge - <(zcat ../gz/MissS/c2pMissS.$j.s) | gzip > ../gz/c2pFullS$j.s1
done

fi
if test 'WHAT' = 'P2tspan'; then

dt=$((3600*24*365*10))
l=FROM
for i in {0..7}
do j=$(($i+$l*8))
  zcat ../gz/c2PFull.$ver.$j.s | join -t\; - <(zcat ../gz/c2datFull.$ver.$j.s) | cut -d\; -f2,3
done | perl -e 'while (<STDIN>){chop();($p,$t)=split(/;/,$_,-1);$pmi{$p}=$t if ($pmi{$p}>$t || !defined $pmi{$p}) && $t > '$dt';$pma{$p}=$t if ($pma{$p}<$t || !defined $pma{$p}) && $t > '$dt';} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}'  |\
     perl -I $HOME/lib/perl5 -I $HOME/lookup $HOME/lookup/splitSecCh.perl  ../c2fb/P2tspanFull.$ver.$l. 32
     #done | perl -e 'while (<STDIN>){chop();($p,$t)=split(/;/,$_,-1);$pmi{$p}=$t if ($pmi{$p} > $t  !defined $pmi{$p};$pma{$p}=$t if $pma{$p}<$t || !defined $pma{$p}} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}'  | \
echo P2tspanFull.$ver.$l.

for i in {0..31}
do zcat ../c2fb/P2tspanFull.$ver.$l.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,4 -u | gzip > ../c2fb/P2tspanFull.$ver.$l.$i.s
  echo P2tspanFull.$ver.$l.$i.s
done

fi
if test 'WHAT' = 'P2tspanm'; then

dt=$((3600*24*365*10))
l=FROM
for i in {0..7}
do j=$(($i+$l*8))
   str="$HOME/bin/lsort ${maxM}M -t\; -k1,3 -u --merge"
   for k in {0..15}; do str="$str <(zcat ../c2fb/P2tspanFull.$ver.$k.$j.s)"; done
   eval $str | perl -e 'while (<STDIN>){chop();($p, $t0, $t1)=split(/;/,$_,-1);$pmi{$p}=$t0 if ($pmi{$p}>$t0 || !defined $pmi{$p}) && $t0 > '$dt';$pma{$p}=$t1 if ($pma{$p}<$t1 || !defined $pma{$p}) && $t1 > '$dt';} for $p (sort keys %pmi){print "$p;$pmi{$p};$pma{$p}\n"}' | \
	   gzip > ../c2fb/P2tspanFull.$ver.$j.s
   echo P2tspanFull.$ver.$j.s
done


fi

if test 'WHAT' == 'split'; then

j=FROM
zcat c2pFull.$ver.$j.s | join -t\; - <(zcat c2datFull.$ver.$j.s|perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[0];$x[3]\n";') | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[2]\n" if $x[2] ne "" && $x[1] ne "";' | uniq | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl p2aFull.$ver.FROM. 32
echo p2aFull$ver.FROM.

for j in {0..31}
do zcat p2aFull.$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > p2aFull.$ver.FROM.$j.s 
   echo p2aFull.$ver.FROM.$j.s  
done

fi
if test 'WHAT' == 'merge'; then

j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for k in {0..127}
do str="$str <(zcat p2aFull.$ver.$k.$j.s)"
done
eval $str | gzip > p2aFull.$ver.$j.s 
echo p2aFull.$ver.$j.s

fi
if test 'WHAT' == 't2P'; then

for i in {0..1}
do j=$((FROM*2+$i))
   zcat c2PFull$ver$j.s | join -t\; - <(zcat c2datFull$ver$j.s|perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[0];$x[4]\n";')
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[2];$x[1]\n" if $x[2] =~ /^[0-9a-f]{40}$/ && $x[1] ne "";' | uniq | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSec.perl t2PFull$ver.FROM. 128
echo t2PFull$ver.FROM.

for j in {0..127}
do zcat t2PFull$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > t2PFull$ver.FROM.$j.s
   echo t2PFull$ver.FROM.$j.s
done


fi
if test 'WHAT' == 't2Pm'; then

for i in {0..3}
do j=$((FROM*4+$i))
   str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
   for k in {0..63}
   do str="$str <(zcat t2PFull$ver.$k.$j.s)"
   done
   eval $str | gzip > t2PFull$ver$j.s
   echo t2PFull$ver$j.s
done

fi
if test 'WHAT' == 'a2psplit'; then


for i in {0..3}
do j=$((FROM*4+$i))
   zcat p2aFull.$ver.$j.s | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n";' | uniq 
done | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl a2pFull.$ver.FROM. 32 
echo a2pFull$ver.FROM.

#fi
#if test 'WHAT' == 'a2psort'; then

for j in {0..31}
do zcat a2pFull.$ver.FROM.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > a2pFull.$ver.FROM.$j.s
   echo a2pFull.$ver.FROM.$j.s
done

fi
if test 'WHAT' == 'a2pmerge'; then

j=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
for k in {0..7}
do str="$str <(zcat a2pFull$ver.$k.$j.s)"
done
eval $str | gzip > a2pFull$ver$j.s
echo a2pFull$ver$j.s

fi
if test 'WHAT' == 'P2asplit'; then

for i in {0..7}
do j=$((FROM*8+i))
   zcat c2PFull.$ver.$j.s | join -t\; - <(zcat c2datFull.$ver.$j.s | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[0];$x[3]\n";')
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[2]\n" if $x[2] ne "" && $x[1] ne "";' | \
       uniq  | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl P2aFull.$ver.FROM. 32
echo P2aFull.$ver.FROM.

for i in {0..31}
do zcat P2aFull.$ver.FROM.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > P2aFull.$ver.FROM.$i.s
   echo P2aFull.$ver.FROM.$i.s
done

fi
if test 'WHAT' == 'P2amerge'; then

for i in {0..1}
do j=$((FROM*2+$i))
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..15}
  do str="$str <(zcat P2aFull.${ver}.$k.$j.s)"
  done
  eval $str | gzip > P2aFull.${ver}.$j.s
  echo P2aFull.${ver}.$j.s
done

for i in {0..1}
do j=$((FROM*2+i))
  zcat P2aFull.$ver.$j.s 
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n";' | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl a2PFull.$ver.FROM. 32
echo a2PFull.$ver.FROM.

for i in {0..31}
do zcat a2PFull.$ver.FROM.$i.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > a2PFull.$ver.FROM.$i.s
   echo a2PFull.$ver.FROM.$i.s
done

fi
if test 'WHAT' == 'a2A'; then

for i in {0..1}
do j=$((FROM*2+i))
   zcat P2aFull.$ver.$j.s | perl ~/lookup/mapA.perl 1 a2AFullH.$ver.s | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u  | gzip > P2AFull.$ver.$j.s
   #zcat P2aFull$ver$j.s | perl ~/lookup/mp.perl 1 a2AQ.s | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u  | gzip > P2AFull$ver$j.s
   echo P2AFull.$ver.$j.s
done

for i in {0..1}
do j=$((FROM*2+i))
   zcat P2AFull.$ver.$j.s
done | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[0]\n";' | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl A2PFull.$ver.FROM. 32

fi
if test 'WHAT' == 'a2Asrt'; then


for i in {0..1}
do j=$((FROM*2+i))
   for k in {0..15}
   do zcat A2PFull.$ver.$k.$j.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u  | gzip >  A2PFull.$ver.$k.$j.s
      echo A2PFull.$ver.$k.$j.s
   done
done

fi
if test 'WHAT' == 'A2Pmerge'; then

for i in {0..7}
do j=$((FROM*8+$i))
   str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
   for k in {0..15}
   do str="$str <(zcat A2PFull.${ver}.$k.$j.s)"
   done
   eval $str | gzip > A2PFull.${ver}.$j.s
   echo A2PFull.${ver}.$j.s
done


fi
if test 'WHAT' == 't2Pgraph'; then

for i in {0..1}
do j=$((FROM*2+$i))
   zcat t2PFull.${ver}.$j.s
done | cut -d\; -f1 | uniq -c | awk '{if ($1 > 2)print $0}' | sed 's|^\s*||;s| |;|' | gzip > largeTreesCnt.${ver}.FROM.gz
echo  largeTreesCnt.${ver}.FROM.gz

j=FROM
zcat largeTreesCnt.${ver}.$j.gz | awk -F\; '{if ($1 > CUT)print $2}' | gzip > largeTrees$j.CUT.gz
echo largeTrees$j.CUT.gz

for i in {0..1}
do j=$((FROM*2+$i))
   zcat t2PFull.${ver}.$j.s 
done | ~/lookup/grepFieldv.perl largeTrees$j.CUT.gz 1 | perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > t2PFull.${ver}.FROM.CUT.p2p

j=FROM
zcat t2PFull.$ver.$j.CUT.p2p | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > t2PFull.$ver.$j.CUT.p2p.gz
echo t2PFull.$ver.$j.CUT.p2p.gz
zcat t2PFull.$ver.$j.CUT.p2p.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > t2PFull.$ver.$j.CUT.p2p.s
echo t2PFull.$ver.$j.CUT.p2p.s

fi
if test 'WHAT' = 't2Pgraphm'; then

str="lsort $(($maxM*3))M -t\| --merge"
for i in {0..63}
do str="$str <(zcat  t2PFull.$ver.$i.p2p.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > t2PFull.$ver.np2p.s
echo t2PFull$ver.np2p.s

fi
if test 'WHAT' == 'A2Pgraph'; then

for i in {0..31}
do zcat A2PFull.${ver}.$i.s 
done | perl $HOME/lookup/connectExportPlain.perl A2PFull.${ver}

fi
if test 'WHAT' == 'a2Pmerge'; then

for i in {0..1}
do j=$((FROM*2+$i))
   str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
   for k in {0..15}
   do str="$str <(zcat a2PFull.${ver}.$k.$j.s)"
   done
   eval $str | gzip > a2PFull.${ver}.$j.s
   echo a2PFull.${ver}.$j.s
done


fi
if test 'WHAT' = 'top'; then

cut=10;
for j in {0..31}
do zcat a2PFull.$ver.$j.s 
done | perl -e 'while (<STDIN>){chop();s/\;.*//;$c{$_}++;};while (($k, $v)=each %c){ print "$k;$v\n" if $v > '$cut'}' | gzip > aManyP  

for j in {0..31}
do zcat P2aFull.$ver.$j.s 
done | perl -e 'while (<STDIN>){chop();s/\;.*//;$c{$_}++;};while (($k, $v)=each %c){ print "$k;$v\n" if $v > '$cut'}'  | gzip > PManya  

for j in {0..31}
do zcat A2PFull.$ver.$j.s
done | perl -e 'while (<STDIN>){chop();s/\;.*//;$c{$_}++;};while (($k, $v)=each %c){ print "$k;$v\n" if $v > '$cut'}' | gzip > AManyP

for j in {0..31}
do zcat P2AFull.$ver.$j.s
done | perl -e 'while (<STDIN>){chop();s/\;.*//;$c{$_}++;};while (($k, $v)=each %c){ print "$k;$v\n" if $v > '$cut'}'  | gzip > PManyA


fi

if test 'WHAT' = 'runManual'; then

# AManyP1000S.gz is manually curated!
for j in {0..31}; do zcat P2AFull.${ver}.$j.s; done | perl $HOME/bin/grepFieldv.perl PManyA2000.gz 1 | perl $HOME/bin/grepFieldv.perl AManyP1000$ver.gz 2 | perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > P2AFull.${ver}.A2A.2000
zcat P2AFull.${ver}.A2A.2000 | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > P2AFull${ver}.A2A.2000.gz
zcat P2AFull.${ver}.A2A.2000.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > P2AFull.${ver}.A2A.2000.s

fi
if test 'WHAT' = 'A2Acut'; then


cut=CUT;
[[ -f AManyP$cut.gz ]] || zcat AManyP | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';' | gzip > AManyP$cut.gz
[[ -f PManyA$cut.gz ]] || zcat PManyA | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';' | gzip > PManyA$cut.gz

for i in {0..3}
do j=$((FROM*4+i))
   zcat P2AFull${ver}$j.s
done | perl $HOME/bin/grepFieldv.perl PManyA$cut.gz 1 | perl $HOME/bin/grepFieldv.perl AManyP$cut.gz 2 | \
     perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > P2AFull${ver}FROM.A2A.$cut
echo P2AFull${ver}FROM.A2A.$cut
zcat P2AFull${ver}FROM.A2A.$cut | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > P2AFull${ver}FROM.A2A.$cut.gz
echo P2AFull${ver}FROM.A2A.$cut.gz
zcat P2AFull${ver}FROM.A2A.$cut.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > P2AFull${ver}FROM.A2A.$cut.s
echo P2AFull${ver}FROM.A2A.$cut.s

fi
if test 'WHAT' = 'A2Acutm'; then

str="lsort $(($maxM*3))M -t\| --merge"
for j in {0..7}
do str="$str <(zcat  P2AFull$ver$j.A2A.CUT.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > P2AFull$ver.nA2A.CUT.s
echo P2AFull$ver.nA2A.CUT.s

fi
if test 'WHAT' = 'a2acut'; then


cut=CUT;
zcat aManyP | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';' | gzip > aManyP$cut.gz 
zcat PManya | perl -ane 'chop();@x=split(/;/);print "$x[0]\n" if $x[1] > '$cut';' | gzip > PManya$cut.gz 

for i in {0..3}
do j=$((FROM*4+i))
   zcat P2aFull.${ver}.$j.s 
done | perl $HOME/bin/grepFieldv.perl PManya$cut.gz 1 | perl $HOME/bin/grepFieldv.perl aManyP$cut.gz 2 | \
     perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > P2aFull.${ver}.FROM.a2a.$cut
echo P2aFull.${ver}.FROM.a2a.$cut
zcat P2aFull.${ver}.FROM.a2a.$cut | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > P2aFull.${ver}.FROM.a2a.$cut.gz
echo P2aFull.${ver}.FROM.a2a.$cut.gz
zcat P2aFull.${ver}.FROM.a2a.$cut.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > P2aFull.${ver}.FROM.a2a.$cut.s
echo P2aFull.${ver}.FROM.a2a.$cut.s

fi
if test 'WHAT' = 'a2acutm'; then

str="lsort $(($maxM*3))M -t\| --merge"
for j in {0..7}
do str="$str <(zcat  P2aFull.$ver.$j.a2a.CUT.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > P2aFull.$ver.na2a.CUT.s
echo P2aFull$ver.na2a.CUT.s

fi
if test 'WHAT' = 'a2a'; then

j=FROM
zcat P2aFull.${ver}.$j.s | perl $HOME/lookup/connectExportPreNoExclude.perl | gzip > P2aFull.$ver.$j.a2a
echo P2aFull.$ver.$j.a2a
zcat P2aFull.$ver.$j.a2a | perl -ane 'chop();($c,@x) = split(/;/); print "".(join ";", (sort @x))."\n";' | gzip > P2aFull.$ver.$j.a2a.gz
echo P2aFull.$ver.$j.a2a.gz
zcat P2aFull.$ver.$j.a2a.gz | lsort  ${maxM}M -t\| | uniq -c | perl -ane 'chop();s|^\s*([0-9]*) ||;print "$_;$1\n"' | gzip > P2aFull.$ver.$j.a2a.s
echo P2aFull.$ver.$j.a2a.s

fi
if test 'WHAT' = 'a2amerge'; then

str="lsort $(($maxM*3))M -t\| --merge"
for j in {0..31}
do str="$str <(zcat  P2aFull.$ver.$j.a2a.s)"
done
eval $str | perl -e '$pstr="";$nn=0;while(<STDIN>){chop;(@x)=split(/;/);$n=pop @x;$str=join ";", @x; if ($pstr ne $str && $pstr ne ""){ print "$nn;$pstr\n";$pstr=$str;$nn=$n }else{ $pstr=$str;$nn+=$n}};print "$nn;$pstr\n";'  | \
   gzip > P2aFull.$ver.na2a.s
echo P2aFull.$ver.na2a.s

fi
if test 'WHAT' == 'cut'; then
CUT=100

#for i in {0..3}
#do j=$((FROM*4+$i))
j=FROM
   #need to remove awk here
   zcat p2aFull.$ver.$j.s | cut -d\; -f1 | uniq -c | awk '{ if($1>'$CUT')print $2}' | gzip > p$CUT.$j
   echo p$CUT.$j
   zcat p2aFull.$ver.$j.s | perl $HOME/bin/grepFieldv.perl p$CUT.$j 1 | join -t\; - <(zcat p2aFull.$ver.$j.s | perl $HOME/bin/grepFieldv.perl p$CUT.$j 1) | perl -ane 'chop();@x=split(/;/, $_, -1); print "$x[1];$x[2]\n" if $x[1] ne "" && $x[2] ne "";' | uniq | gzip > a2aFull.${ver}.$CUT.$j.gz 
   echo a2aFull.${ver}.$CUT.$j.gz
   zcat a2aFull.${ver}.$CUT.$j.gz | perl -I ~/lib/perl5 -I ~/lookup $HOME/lookup/splitSecCh.perl a2aFull.${ver}.$CUT.$j. 32 
   echo a2aFull.${ver}.$CUT.$j. 
   for k in {0..31}
   do zcat a2aFull.${ver}.$CUT.$j.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 -u | gzip > a2aFull.${ver}.$CUT.$j.$k.s 
      echo a2aFull.${ver}.$CUT.$j.$k.s
   done
#done

fi
if test 'WHAT' == 'cmerge'; then
CUT=100
for i in {0..3}
do j=$((FROM*4+$i)) 
  str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 -u --merge"
  for k in {0..31}
  do str="$str <(zcat a2aFull.${ver}.$CUT.$k.$j.s)"
  done
  eval $str | gzip > a2aFull.${ver}.$CUT.$j.s 
  echo a2aFull.${ver}.$CUT.$j.s
done

fi

