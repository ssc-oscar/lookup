#use the result of old Cmt2Blob.perl in commit_blob.tch
mv /fast1/All.sha1c/commit_blob.tch /fast1/All.sha1c/commit_blob.tch.old
./exportObj.perl /fast1/All.sha1c/commit_blob.tch.old | gzip > /data/All.blobs/commit_blob.bin
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Cmt2BlobMerge.perl /data/All.blobs/commit_blob.bin
mv /data/All.blobs/commit_blob.tch /fast1/All.sha1c/

#use old /fast1/All.sha1c/blob_commit.tch 
./exportObj1.perl /fast1/All.sha1c/blob_commit.tch | gzip > /data/All.blobs/blob_commit.bin
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Blob2CommitMerge.perl /data/blob_commit.bin /data/blob_commit.tch
mv /data/blob_commit.tch /fast1/All.sha1c/
