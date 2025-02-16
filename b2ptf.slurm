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

c=/lustre/isaac/scratch/audris/All.blobs
cd $c

ver=V
if test 'WHAT' == 't2ptf'; then

inc=$((3776568/2))
k=$((PRT*inc))
i=FROM
perl $HOME/lookup/t2ptf.perl $i $k $((k+inc)) | gzip > t2ptfV.$i.PRT.gz

fi
if test 'WHAT' == 't2ptf1'; then

inc=$((3776568/2))
k=$((PRT*inc))
i=FROM
j=PRT
./fixtpt.sh $i $j

fi
if test 'WHAT' == 't2ptf2'; then

inc=$((3776568/2))
k=$((PRT*inc))
j=PRT
i=FROM
./fixtpt2.sh $i $j

fi
if test 'WHAT' == 't2ptf3'; then

inc=$((3776568/2))
k=$((PRT*inc))
i=FROM
j=PRT
./fixtpt3.sh $i $j

fi
if test 'WHAT' == 't2ptfSplit'; then

j=PRT
i=FROM
for k in {0..7}
do l=$((i*8+k))
for m in {0..3}
do o=$((j*4+m))
zcat t2ptfV.$l.$o.gz
done
done | perl -I $HOME/lib/perl5 -I $HOME/lookup  $HOME/lookup/splitSec.perl t2ptfV.$i.$j. 128
fi
if test 'WHAT' == 't2ptfSplSrt'; then

j=PRT
i=FROM
for k in {0..127}
do zcat t2ptfV.$i.$j.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > t2ptfV.$i.$j.$k.s
done

fi
if test 'WHAT' == 't2ptfMrgJ'; then


k=PRT
i=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge "
for j in {0..15}
do str="$str <(zcat t2ptfV.$i.$j.$k.s)"
done
eval $str | gzip > t2ptfV.$i.$k.s
echo t2ptfV.$i.$k.s


fi
if test 'WHAT' == 't2ptfMrg'; then

k=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge "
for j in {0..15}
do str="$str <(zcat t2ptfV.$j.$k.s)"
done
eval $str | gzip > t2ptfFullV$k.s

fi


if test 'WHAT' == 'b2ptf'; then

inc=$((3776568/2))
k=$((PRT*inc))
i=FROM
perl $HOME/lookup/b2ptf.perl $i $k $((k+inc)) | gzip > b2ptfV.$i.PRT.gz

fi
if test 'WHAT' == 'b2ptf1'; then
j=PRT
i=FROM
./fixbpt.sh $i $j
fi
if test 'WHAT' == 'b2ptf2'; then
j=PRT
i=FROM
./fixbpt2.sh $i $j
fi
if test 'WHAT' == 'b2ptf3'; then
j=PRT
i=FROM
./fixbpt3.sh $i $j
fi
if test 'WHAT' == 'b2ptf4'; then
j=PRT
i=FROM
./fixbpt4.sh $i $j
fi

if test 'WHAT' == 'b2ptfSplit'; then

j=PRT
i=FROM
for k in {0..7}
do l=$((i*8+k))
for m in {0..3}
do o=$((j*4+m))
  zcat b2ptfV.$l.$o.gz
done
done | perl -I $HOME/lib/perl5 -I $HOME/lookup  $HOME/lookup/splitSec.perl b2ptfV.$i.$j. 128
fi
if test 'WHAT' == 'b2ptfSplSrt'; then

j=PRT
i=FROM
for k in {0..127}
do zcat b2ptfV.$i.$j.$k.gz | $HOME/bin/lsort ${maxM}M -t\; -k1,2 | gzip > b2ptfV.$i.$j.$k.s
done

fi
if test 'WHAT' == 'b2ptfMrgJ'; then


k=PRT
i=FROM
str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge "
for j in {0..15}
do str="$str <(zcat b2ptfV.$i.$j.$k.s)"
done
eval $str | gzip > b2ptfV.$i.$k.s
echo b2ptfV.$i.$k.s


fi

if test 'WHAT' == 'b2ptfMrg'; then

	k=FROM
	str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge "
	for j in {0..15}
	do str="$str <(zcat b2ptfV.$j.$k.s)"
	done
	eval $str | gzip > b2ptfVFullV$k.s

fi

if test 'WHAT' == 'diff'; then

j=PRT
inc=85400
k=$(((j+1)*inc))
i=FROM
echo "UU1.$i.cs |head -$k |tail -$inc"
nl=$(zcat UU1.$i.cs | wc -l)
if [[ $j -eq 9 ]];
then zcat UU1.$i.cs | tail -$((nl-9*inc))
else zcat UU1.$i.cs |head -$k |tail -$inc 
fi | perl -I ~/lib -I ~/lib64/perl5 ~/lookup/cmputeDiff3CT.perl All.sha1o 2> UU1.$i.$j.err | \
gzip > UU1.$i.$j.gz


fi
if test 'WHAT' == 'diffV'; then

j=PRT
inc=55500
k=$(((j+1)*inc))
i=FROM
echo "UV.$i.cs |head -$k |tail -$inc"
nl=$(zcat UV.$i.cs | wc -l)
if [[ $j -eq 99 ]];
then zcat UV.$i.cs | tail -$((nl-99*inc))
else zcat UV.$i.cs |head -$k |tail -$inc
fi | perl -I ~/lib -I ~/lib64/perl5 ~/lookup/cmputeDiff3CT.perl All.sha1o 2> UV.$i.$j.err | \
	gzip > UV.$i.$j.gz


fi
if test 'WHAT' == 'diffV1miss'; then

i=FROM
cat VV1.$i.cs.miss | perl -I ~/lib -I ~/lib64/perl5 ~/lookup/cmputeDiff3CT.perl All.sha1o 2> VV1.$i.65.err |  $HOME/lookup/compactDiff.perl | gzip > VV1.$i.65.gz

fi
if test 'WHAT' == 'diffV2'; then

base=V1_1V2
j=PRT
i=FROM
./V2.sh $i $j $base

fi
if test 'WHAT' == 'diffV2Fix'; then

j=PRT
i=FROM
./fixV2.1.sh $i $j

fi
if test 'WHAT' == 'diffV2Fix1'; then

j=PRT
i=FROM
./fixV2.2.sh $i $j

fi

if test 'WHAT' == 'diffV1_1'; then

i=FROM
zcat V1V1_1.$i.cs | perl -I ~/lib -I ~/lib64/perl5 ~/lookup/cmputeDiff3CT.perl All.sha1o 2> V1V1_1.$i.err | perl $HOME/lookup/compactDiff.perl | gzip > V1V1_1.$i.gz

fi
if test 'WHAT' == 'diffV1'; then
j=PRT
inc=38000
k=$(((j+1)*inc))
i=FROM
echo "VV1.$i.cs |head -$k |tail -$inc"
nl=$(zcat VV1.$i.cs | wc -l)
if [[ $j -eq 64 ]];
then zcat VV1.$i.cs | tail -$((nl-64*inc))
else zcat VV1.$i.cs |head -$k |tail -$inc
fi | perl -I ~/lib -I ~/lib64/perl5 ~/lookup/cmputeDiff3CT.perl All.sha1o 2> VV1.$i.$j.err | \
	        gzip > VV1.$i.$j.gz
fi
if test 'WHAT' == 'diffV1Fix'; then

j=PRT
i=FROM
./fixV1.1.sh $i $j

fi
if test 'WHAT' == 'diffV1Fix2'; then

j=PRT
i=FROM
./fixV1.2.sh $i $j

fi
if test 'WHAT' == 'diffV1Fix3'; then

j=PRT
i=FROM
./fixV2.2.sh $i $j

fi

if test 'WHAT' == 'diffVFix'; then

j=PRT
i=FROM
./fix1.sh $i $j

fi
if test 'WHAT' == 'diffVFix1'; then

j=PRT
i=FROM
./fix4.sh $i $j 1

fi
if test 'WHAT' == 'diffVFix2'; then

j=PRT
i=FROM
./fix4.sh $i $j 2

fi
if test 'WHAT' == 'diffVFix3'; then

j=PRT
i=FROM
./fix4.sh $i $j 3

fi
if test 'WHAT' == 'diffVFix4'; then

j=PRT
i=FROM
./fix4.sh $i $j 4

fi
if test 'WHAT' == 'diffVFix5'; then

j=PRT
i=FROM
./fix4.sh $i $j 5

fi
if test 'WHAT' == 'diffVFix6'; then

j=PRT
i=FROM
./fix4.sh $i $j 6

fi

if test 'WHAT' == 'diffV1Merge'; then

i=FROM
for j in {0..64}
do zcat VV1.$i.$j.gz | perl $HOME/lookup/compactDiff.perl | lsort 1G -t\; -k1,1 | gzip > VV1.$i.$j.s
done
str="lsort 1G -t\; -k1 --merge"
for j in {0..64}
do str="$str <(zcat VV1.$i.$j.s)"
done
eval $str | gzip > VV1.$i.s


fi

if test 'WHAT' == 'diffV1Compact'; then

i=FROM
zcat VV1.$i.s | perl $HOME/lookup/compactDiff.perl | gzip > VV1.$i.s1

fi

if test "WHAT" = 'b2ptfsplit'; then

for i in {0..3}
do j=$((FROM*4+i))
   zcat b2ptf$j.gz 
done | grep ^b | cut -d\; -f2- | perl -I $HOME/lib/perl5 -I $HOME/lookup  $HOME/lookup/splitSec.perl b2ptf.FROM. 128

fi

if test 'WHAT' == 't2ptfFix'; then


i=PRT
j=FROM
if [[ -f t2ptfV.$i.$j.gz ]]
then zcat t2ptfV.$i.$j.gz &> /dev/null;
  if [[ $? -ne 0 ]]
  then 
     nl=$(zcat t2ptfV.$i.$j.gz|wc -l)
     nl=$((nl-1));
     mv t2ptfV.$i.$j.gz t2ptfV.$i.$j.gz.old
     echo mv t2ptfV.$i.$j.gz t2ptfV.$i.$j.gz.old
     zcat t2ptfV.$i.$j.gz.old | head -$nl | gzip > t2ptfV.$i.$j.gz0
     l=$(zcat t2ptfV.$i.$j.gz0|tail -1 | cut -d\; -f2)
     l1=$(zcat t2ptfV.$i.$((j+1)).gz|head -1|cut -d\; -f2)
     n=$(grep $l tree_$i.idx|cut -d\; -f1)
     n1=$(grep $l1 tree_$i.idx|cut -d\; -f1)
     echo perl $HOME/lookup/t2ptf.perl $j $n $n1 t2ptfV.$i.$j.gz1
     perl $HOME/lookup/t2ptf.perl $i $n $n1 | gzip > t2ptfV.$i.$j.gz1
  fi
fi

fi
if test 'WHAT' == 't2ptfFixD'; then

j=PRT
i=FROM
if [[ -f t2ptfV.$i.$j.gz.old && ! -s t2ptfV.$i.$j.gz1 ]]
then
    l=$(zcat t2ptfV.$i.$j.gz0|tail -1 | cut -d\; -f2)
    l1=$(zcat t2ptfV.$i.$((j+1)).gz|head -1|cut -d\; -f2)
    n=$(grep $l tree_$i.idx|cut -d\; -f1)
    n1=$(grep $l1 tree_$i.idx|cut -d\; -f1)
    inc=$(echo "($n1-$n)/4" | bc)
    perl $HOME/lookup/t2ptf.perl $i $((n+inc*2)) $n1 | gzip > t2ptfV.$i.$j.gz1d
fi

fi
if test 'WHAT' == 't2ptfFixC'; then

j=PRT
i=FROM
if [[ -f t2ptfV.$i.$j.gz.old && ! -s t2ptfV.$i.$j.gz1 ]]
then
    l=$(zcat t2ptfV.$i.$j.gz0|tail -1 | cut -d\; -f2)
    l1=$(zcat t2ptfV.$i.$((j+1)).gz|head -1|cut -d\; -f2)
    n=$(grep $l tree_$i.idx|cut -d\; -f1)
    n1=$(grep $l1 tree_$i.idx|cut -d\; -f1)
    inc=$(echo "($n1-$n)/4" | bc)
    perl $HOME/lookup/t2ptf.perl $i $((n+inc)) $((n+inc*2)) | gzip > t2ptfV.$i.$j.gz1c
fi

fi
if test 'WHAT' == 't2ptfFixB'; then

j=PRT
i=FROM
if [[ -f t2ptfV.$i.$j.gz.old && ! -s t2ptfV.$i.$j.gz1 ]]
then
    l=$(zcat t2ptfV.$i.$j.gz0|tail -1 | cut -d\; -f2)
    l1=$(zcat t2ptfV.$i.$((j+1)).gz|head -1|cut -d\; -f2)
    n=$(grep $l tree_$i.idx|cut -d\; -f1)
    n1=$(grep $l1 tree_$i.idx|cut -d\; -f1)
    inc=$(echo "($n1-$n)/4" | bc)
    perl $HOME/lookup/t2ptf.perl $i $n $((n+inc)) | gzip > t2ptfV.$i.$j.gz1b
fi

fi
if test 'WHAT' == 't2ptfFix2'; then

i=PRT
j=FROM
if [[ -f t2ptfV.$i.$j.gz3 ]]
then zcat t2ptfV.$i.$j.gz3 &> /dev/null;
  if [[ $? -ne 0 ]]
  then nl=$(zcat t2ptfV.$i.$j.gz3|wc -l)
     nl=$((nl-1));
     mv t2ptfV.$i.$j.gz3 t2ptfV.$i.$j.gz3.old
     zcat t2ptfV.$i.$j.gz3.old | head -$nl | gzip > t2ptfV.$i.$j.gz4
     l=$(zcat t2ptfV.$i.$j.gz4|tail -1 | cut -d\; -f2)
     l1=$(zcat t2ptfV.$i.$((j+1)).gz|head -1|cut -d\; -f2)
     n=$(grep $l tree_$i.idx|cut -d\; -f1)
     n1=$(grep $l1 tree_$i.idx|cut -d\; -f1)
     perl $HOME/lookup/t2ptf.perl $j $n $n1 | gzip > t2ptfV.$j.PRT.gz5
   fi
fi

fi
if test 'WHAT' == 't2ptfFix1'; then


i=PRT
j=FROM

if [[ -f t2ptfV.$i.$j.gz1 ]]
then zcat t2ptfV.$i.$j.gz1 &> /dev/null;
  if [[ $? -ne 0 ]]
  then nl=$(zcat t2ptfV.$i.$j.gz1|wc -l)
     nl=$((nl-1));
     mv t2ptfV.$i.$j.gz1 t2ptfV.$i.$j.gz1.old
     zcat t2ptfV.$i.$j.gz1.old | head -$nl | gzip > t2ptfV.$i.$j.gz2
     l=$(zcat t2ptfV.$i.$j.gz2|tail -1 | cut -d\; -f2)
     l1=$(zcat t2ptfV.$i.$((j+1)).gz|head -1|cut -d\; -f2)
     n=$(grep $l tree_$i.idx|cut -d\; -f1)
     n1=$(grep $l1 tree_$i.idx|cut -d\; -f1)
     perl $HOME/lookup/t2ptf.perl $j $n $n1 | gzip > t2ptfV.$j.PRT.gz3
   fi
fi

fi

if test "WHAT" = 'b2ptfsrt'; then
#to complet b2f

for i in {0..127}
do zcat b2ptf.FROM.$i.gz | cut -d\; -f1,3 | $HOME/bin/lsort 12G -t\; -k1,2 -u | gzip > b2tf.FROM.$i.s
   echo b2tf.FROM.$i.s
done

fi
if test "WHAT" = 'b2ptfall'; then

for i in {0..7}
do j=$((FROM*8+i))
   str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge -u"
   for k in {0..31}
   do str="$str <(zcat b2tf.$k.$j.s)"
   done
   eval $str | gzip > b2tfFull$ver$j.s 
   echo b2tfFull$ver$j.s
done

fi
if test "WHAT" = 'b2ptsrt'; then
#to track where blob was introduced, hopefully gettting to a commit containing the tree

for i in {0..127}
do zcat b2ptf.FROM.$i.gz | cut -d\; -f1,2 | $HOME/bin/lsort 12G -t\; -k1,2 -u | gzip > b2pt.FROM.$i.s
   echo b2pt.FROM.$i.s
done

fi
if test 'WHAT' == 't2ptfsplit'; then

for i in {0..3}
do j=$((FROM*4+i))
   zcat t2ptf$j.gz
done | grep ^t | cut -d\; -f2- | perl -I $HOME/lib/perl5 -I $HOME/lookup  $HOME/lookup/splitSec.perl t2ptf.FROM. 128
echo t2ptf.FROM.

fi
if test "WHAT" = 't2ptsrt'; then
# for recursing up to find a commit creating the tree

for i in {0..127}
do zcat t2ptf.FROM.$i.gz | cut -d\; -f1,2 | $HOME/bin/lsort 12G -t\; -k1 -u | gzip > t2pt.FROM.$i.s
   echo t2pt.FROM.$i.s
done

fi
if test "WHAT" = 't2ptall'; then

for i in {0..7}
do j=$((FROM*8+i))
   str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge -u"
   for k in {0..31}
   do str="$str <(zcat t2pt.$k.$j.s)"
   done
   eval $str | gzip > t2ptFull$ver$j.s
   echo t2ptFull$ver$j.s
done

fi
if test "WHAT" = 'b2ptall'; then

for i in {0..7}
do j=$((FROM*8+i))
   str="$HOME/bin/lsort ${maxM}M -t\; -k1,2 --merge -u"
   for k in {0..31}
   do str="$str <(zcat b2pt.$k.$j.s)"
   done
   eval $str | gzip > b2ptFull$ver$j.s
   echo b2ptFull$ver$j.s
done

fi
if test "WHAT" = 'b2fExtra'; then

for i in {0..7}
do j=$((FROM*8+i))
   zcat b2tfFullR$j.s | cut -d\; -f1 | uniq | gzip > inb2tf.$j.s
   zcat ../c2fb/b2fallFullR$j.s | cut -d\; -f1 | uniq | gzip >  inb2fall.$j.s
   zcat inb2tf.$j.s | join -v1 - <(zcat inb2fall.$j.s) | join -t\; - <(zcat b2tfFullR$j.s) | gzip > b2fExtra$j.s
   echo inb2tf.$j.s inb2fall.$j.s b2fExtra$j.s
done

fi
if test "WHAT" = 'b2falle'; then

for i in {0..7}
do j=$((FROM*8+i))
  $HOME/bin/lsort 12G -t\; -k1,2 --merge -u <(zcat ../c2fb/b2fallFullR$j.s) <(zcat b2fExtra$j.s) | gzip > ../c2fb/b2falleFullR$j.s
  echo ../c2fb/b2falleFullR$j.s
done

fi
if test 'WHAT' == 'b2size'; then

for i in {0..7}
do j=$((FROM*8+i))
   awk -F\; '{ if (NF>4){print $5";"$3}else{print $4";"$3} }' blob_$j.idx | $HOME/bin/lsort 12G -t\; -k1,1 | gzip > b2size$j.s
done


fi
if test 'WHAT' == 'lasrt'; then


for i in {0..7}
do j=$((FROM*8+i))
   cut -d\; -f6- ../c2fb/tkns$j.idx | $HOME/bin/lsort 12G -t\; -k1,3 | gzip > b2la$j.s
   echo b2la$j.s
   zcat b2la$j.s | join -t\; <(zcat b2size$j.s) - | gzip > b2sla$j.s
   echo b2sla$j.s
done

fi
