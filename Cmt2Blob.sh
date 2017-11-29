#Do fresh

for i in {000..80}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2Bin.pbs | qsub; done; done
for i in {000..78..02}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge.pbs | qsub; done; done
for i in {000..76..04}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge1.pbs | qsub; done; done
for i in {000..72..08}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge2.pbs | qsub; done; done
for i in {000..64..16}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge3.pbs | qsub; done; done
for i in {000..32..32}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge4.pbs | qsub; done; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS.pbs | qsub; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS1.pbs | qsub; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS2.pbs | qsub; done
#resupt is Cmt2Blob.00-80.{0..15}.tch




#use the result of old Cmt2Blob.perl in commit_blob.tch
mv /fast1/All.sha1c/commit_blob.tch /fast1/All.sha1c/commit_blob.tch.old
./exportObj.perl /fast1/All.sha1c/commit_blob.tch.old | gzip > /data/All.blobs/commit_blob.bin
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Cmt2BlobMerge.perl /data/All.blobs/commit_blob.bin /data/commit_blob.tch
mv /data/commit_blob.tch /fast1/All.sha1c/

#use old /fast1/All.sha1c/blob_commit.tch 
./exportObj1.perl /fast1/All.sha1c/blob_commit.tch | gzip > /data/All.blobs/blob_commit.bin
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Blob2CommitMerge.perl /data/blob_commit.bin /data/blob_commit.tch
mv /data/blob_commit.tch /fast1/All.sha1c/
