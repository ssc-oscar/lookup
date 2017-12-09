#Do complete fresh
for i in {00..80}; do sed "s/NNN/$i/g;" doB2CBin.pbs | qsub; done
for i in {00..80}; do sed "s/NNN/$i/g;" doC2Bbin.pbs | qsub; done

#premerge into fewer chunks
for k in {00..64..16}; do for i in {0..15}; do sed "s/NNN/$k/g;s/MMM/$i/g" doB2Cmerge.pbs | qsub; done; done
for k in {00..64..16}; do for i in {0..15}; do sed "s/NNN/$k/g;s/MMM/$i/g" doC2Bmerge.pbs | qsub; done; done

#merge on da4 (preferably)
for i in {0..15}
do (for k in {00..64..16}; do echo Blob2Cmt.$k-$(($k+15)).$i.tch; done echo Blob2Cmt.80.$i.tch) | ./f2bMerge.perl Blob2Cmt.$i.tch
done
for i in {0..15}
do (for k in {00..64..16}; do echo Cmt2Blob.$k-$(($k+15)).$i.tch; done echo Cmt2Blob.80.$i.tch) | ./f2bMerge.perl Cmt2Blob.$i.tch
done

#!done!

#Older approach, was reading c2fbp icorrectly
for i in {00..80..16}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2Bin.pbs | qsub; done; done
faster simply:
for k in {0..15}
do ls -f Cmt2Blob.[0-8][0-9].$k | f2bMerge.perl Cmt2Blob.$k
   scp -p Cmt2Blob.$k.tch da4:/data/basemaps/
done   
Result is Cmt2Blob.00-80.{0..15}.tch


#now invert
for k in {0..15}
do ./Cmt2BlobInvrt.perl /fast1/All.sha1c/Cmt2Blob.00-80.$k.tch Blob2Cmt.00-80.$k
done

#now merge inverted
for k in {0..15}
do ls -f Blob2Cmt.00-80.{[0-9],1[0-5]}.$k.tch | f2bMerge.perl Blob2Cmt.$k
   scp -p Blob2Cmt.$k.tch da4:/data/basemaps/
done



#older

# too slow to mess with iterative small ram merges
for i in {00..78..02}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge.pbs | qsub; done; done
for i in {00..76..04}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge1.pbs | qsub; done; done
for i in {00..72..08}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge2.pbs | qsub; done; done
for i in {00..64..16}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge3.pbs | qsub; done; done
for i in {00..32..32}; do for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2merge4.pbs | qsub; done; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS.pbs | qsub; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS1.pbs | qsub; done
for j in {0..15}; do sed "s/NNN/$i/g;s/MMM/$j/g" doC2BmergeS2.pbs | qsub; done


#use the result of old Cmt2Blob.perl in commit_blob.tch
mv /fast1/All.sha1c/commit_blob.tch /fast1/All.sha1c/commit_blob.tch.old
./exportObj.perl /fast1/All.sha1c/commit_blob.tch.old | gzip > /data/All.blobs/commit_blob.bin
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Cmt2BlobMerge.perl /data/All.blobs/commit_blob.bin /data/commit_blob.tch
mv /data/commit_blob.tch /fast1/All.sha1c/
#use Cmt2Blob.00-80.{0..15}.tch as produced above instead 

#use old /fast1/All.sha1c/blob_commit.tch 
./exportObj1.perl /fast1/All.sha1c/blob_commit.tch | gzip > /data/All.blobs/blob_commit.bin
# this takes 700G of ram and takese several weeks: avoid
gunzip -c /da0_data/c2fbp/c2fbp.{7[4-9],8[0-9]}.gz | cut -d\; -f1,3 | uniq | perl -I ~/lib64/perl5 Blob2CmtMerge.perl /data/blob_commit.bin /data/blob_commit.tch
mv /data/blob_commit.tch /fast1/All.sha1c/

The alternative is iteratively merge 80 chunks produced 
by doB2CBin.pbs 
via Blob2CmtMergeTC.perl
see doB2Cmerge.pbs
also takes very long time, use split invert/merge as shown above
