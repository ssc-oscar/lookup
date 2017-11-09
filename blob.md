Blob2content mapping
====================

The mapping proceeds in two stages: first, the file offset for All.blobs/blob_XX.bin
is stored in /fast1/All.sha1o/sha1.blob_XX.tch

As the .bin files are uppdated the script that updates offsets is

```
seq 0 127 | while read i; do ./BlobN2Off.perl $i; done
```


Then showBlob.perl uses the resulting /fast1/All.sha1o/sha1.blob_XX.tch
to get offest and read the blob from All.blobs/blob_XX.bin

TBD


use Blob2Cont.perl to create the /fast1/All.sha1c/blob_XX.tch
that store content associated with each hash.


