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

