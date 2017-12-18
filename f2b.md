#mappingof filename to blobse based on trees in git

```
for i in {0..127}
do echo $i | perl -I ~/lib64/perl5 f2b.perl $i
done 
```

extracts data from each All.blobs/tree_$i.bin

into 

/fast1/All.sha1c/f2b$i.tch

```
ls -f /fast1/All.sha1c/f2b*.tch | perl -I ~/lib64/perl5 f2bMerge.perl /data/f2b  

done 404441554

```

Merges all into a single file which I copy to
/fast1/All.sha1c/f2b.tch


Note very small number of distinct filenames: 40M


To use the data (get the blobs)
```
echo packages.json | perl -I ~/lib64/perl5 f2bSee.perl /data/f2b | cut -c1-50
packages.json;293180;004869cc4b5abcc6835eb8ca9199

echo package.json | perl -I ~/lib64/perl5 f2bSee.perl /data/f2b.tch | cut -c1-50
package.json;125004640;00000b875a159fbbe21bf507a7d
```

14659 (293180/20) blobs for packages.json

6250232 (125004640/20) blobs for package.json


There are also PACKAGE.json, etc.

The blobs can then be used (via seeBlob.perl)
to grep for import strings, package names or anyhing else on the 
much smaller dataset.

To store the extracted blobs: 
```
echo setup.py | ./f2bStore.perl /fast1/All.sha1c/f2b.tch setup.py.tch
```
This takes a bit long time, especially for more common files such as pcakage.json. A
more iterative approch is as follows:

In addition to extracting data, the blob shas can be extracted:
e.g., 
```
echo setup.py | ./f2bPrep.perl /fast1/All.sha1c/f2b.tch > setup.py.prep
```

Once that is done, the following loop can be excecuted in parallel:
```
for i in {0..127}
do grep "^$i;" setup.py.prep | cut -d\; -f2 | extrBlobs.perl $i /fast1/All.sha1c/setup.py
done
```

tosee what was stored:
```
for i in {0..127}
do ./catTC.perl /fast1/All.sha1c/setup.py.$i.tch
done
```


# various other maps
## blob to file name
```
time ./Prj2CmtInvrt.perl /fast1/All.sha1c/f2b.tch b2n0.bin 2 0
time ./Prj2CmtInvrt.perl /fast1/All.sha1c/f2b.tch b2n1.bin 2 1
./Cmt2PrjPack.perl b2n0.bin  b2n0.tch
./Cmt2PrjPack.perl b2n1.bin  b2n1.tch
```

## tree name to tree
```
seq 0 16 112 | while read i; do sed "s/NNN/$i/g" doN2T.pbs | qsub; done
seq 0 8 120 | while read i; do sed "s/NNN/$i/g" doN2Tmerge.pbs | qsub; done
```

finalize on da3:
```
ls -f n2t*-*.tch | perl -I ~/lib/perl5 /nics/b/home/audris/lookup/f2bMerge.perl n2t
```

## tree to tree name
```
time ./Prj2CmtInvrt.perl /fast1/All.sha1c/n2t.tch t2n0 2 0
time ./Prj2CmtInvrt.perl /fast1/All.sha1c/n2t.tch t2n1 2 1
```


#tree to tree parent
```
seq 0 16 112 | while read i; do sed "s/NNN/$i/g" doT2PT.pbs | qsub; done
for l in {0..15}
do i=$(($l*8)); j=$(($i+7)); 
   time seq $i $j | while read k; do echo /fast1/t2pt$k.tch done | ./f2bMergeSplit.perl t2pt$i-$j 8
done
#now merge (on da3 - may need da4)
for k in {0..7}; do 
  for i in 0-7 8-15 16-23 24-31 32-39 40-47 48-55 56-63 64-71 72-79 80-87 88-95 96-103 104-111 112-119 120-127; 
  do cp -p t2pt$i.$k.tch /fast1/ 
  done 
done
for k in {0..7}; do 
  for i in 0-7 8-15 16-23 24-31 32-39 40-47 48-55 56-63 64-71 72-79 80-87 88-95 96-103 104-111 112-119 120-127; 
  do echo /fast1/t2pt$i.$k.tch; 
  done | ./f2bMerge.perl t2pt0-127.$k
done
```

#blob to tree parent (this uses  too much ram on beacon)
```
seq 0 127 | while read i; do sed "s/NNN/$i/g" doB2PTone.pbs | qsub; done
#croaks on beacon, too much ram in a single file (works as two parallel processes on dad2)
seq 0 3 127 | while read i; do
    [[ -f /data/c2fbp/b2pt$i.tch ]] || time echo $i | ./b2pt.perl $i /store/All.blobs/tree_ /data/c2fbp;
done &
seq 1 3 127 | while read i; do
    [[ -f /data/c2fbp/b2pt$i.tch ]] || time echo $i | ./b2pt.perl $i /store/All.blobs/tree_ /data/c2fbp;
done &
seq 2 3 127 | while read i; do
    [[ -f /data/c2fbp/b2pt$i.tch ]] || time echo $i | ./b2pt.perl $i /store/All.blobs/tree_ /data/c2fbp;
done &
```

