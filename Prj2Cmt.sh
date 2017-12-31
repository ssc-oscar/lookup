##################################
#now do Project to commit
##################################

#in the future, just get updates only from All.blobs/commit_XX.vs
#get the complete info from All.blobs/commit_XX.vs
cut -d\; -f4,6 /data/All.blobs/commit_*.vs | perl -ane 'chop();($c,$p)=split(/\;/,$_,-1);$p=~s/.*github.com_(.*_.*)/$1/;$p=~s/^bitbucket.org_/bb_/;$p=~s|\.git$||;$p=~s|/*$||;$p=~s/\;/SEMICOLON/g;$p = "EMPTY" if $p eq "";print "$c;$p\n";' | lsort 130G -u | gzip > /data/basemaps/c2p.s 


#get stuff from the missing commits in deltaall
(list of all deltaall in x00-x31)
cat x$i | while read k; do gunzip -c $k; done | perl fgrep.perl cc 1 | gzip > x$i.gz
cat x$i | while read k; do gunzip -c $k; done | perl fgrep.perl cNoFile 1 | gzip > xa$i.gz
for i in x00.gz x01.gz x02.gz x03.gz x04.gz x05.gz x06.gz x07.gz x08.gz x09.gz x10.gz x11.gz x12.gz x13.gz x14.gz x15.gz x16.gz x17.gz x18.gz x19.gz x20.gz x21.gz x22.gz x23.8.gz x23.9.gz x23.gz x24.gz x25.gz x26.gz x27.gz x28.gz x29.gz x30.gz x31.gz xa00.gz xa01.gz xa02.gz xa03.gz xa04.gz xa05.gz xa06.gz xa07.gz xa08.gz xa09.gz xa10.9.gz xa10.gz xa10.gz xa11.gz xa12.gz xa13.gz xa14.gz xa15.gz xa16.8.gz xa16.9.gz xa16.gz xa16.gz xa17.gz xa18.gz xa19.gz xa20.gz xa21.gz xa22.gz xa23.gz xa24.gz xa25.gz xa26.gz xa27.gz xa28.gz xa29.gz xa30.gz xa31.gz
do gunzip -c $cloneDir/$i | cut -d\; -f1,2 | uniq | perl -ane 'chop();($p,$c)=split(/\;/,$_,-1);$p=~s/.*github.com_(.*_.*)/$1/;$p=~s/^bitbucket.org_/bb_/;$p=~s|\.git$||;$p=~s|/*$||;$p=~s/\;/SEMICOLON/g;$p = "EMPTY" if $p eq "";print "$c;$p\n";' | lsort 15G -u | gzip > $cloneDir/c2p.$i
done
gunzip -c c2p.x*.gz | lsort 30G -u |gzip >c2p.miss.gz
gunzip -c c2p.s | join -v2 - <(gunzip -c c2p.miss.gz) | gzip > c2p.s2

#check if all are in
gunzip -c /data/basemaps/c2p.s | cut -d\; -f1 | uniq | join -v2 - <(gunzip -c /data/basemaps/cNotInC2fbp.s) | gzip > /data/basemaps/cNoPrj.s &

#now create tch
gunzip -c /data/basemaps/{c2p.s,c2p.s2} | split -l 1000000000 -da 1 --filter='gzip > $FILE.gz' - c2p
for i in {0..2}; do gunzip -c c2p$i.s | sed 's/;/;;;/' | /da3_data/lookup/Cmt2PrjBin.perl c2p$i.tch; done
for i in {0..2}; do ls -f  c2p$i.tch | /da3_data/lookup/f2nMergeSplit.perl c2p$i 8; done
cp -p c2p$i.[0-7].tch /fast1
for i in {0..7}
do ls -f /fast1/{c2p[0-2],Cmt2Prj}.$i.tch | /da3_data/lookup/f2nMergeSplit.perl Cmt2Prj.$i.tch 1
done
for i in {2..7..2}; do ls -f /fast1/{c2p[0-2],Cmt2Prj}.$i.tch | /da3_data/lookup/f2nMergeSplit.perl Cmt2Prj.$i.tch 1; done &
for i in {3..7..2}; do ls -f /fast1/{c2p[0-2],Cmt2Prj}.$i.tch | /da3_data/lookup/f2nMergeSplit.perl Cmt2Prj.$i.tch 1; done &


gunzip -c /data/basemaps/c2p.s | /da3_data/lookup/Prj2CmtBin.perl Prj2CmtA.tch
gunzip -c /data/basemaps/c2p.s2 | /da3_data/lookup/Prj2CmtBin.perl Prj2CmtB.tch
for i in A B; do ls -f  Prj2Cmt$i.tch | /da3_data/lookup/f2nMergeSplit.perl Prj2Cmt$i 8
for i in {0..7}; do ls -f /fast1/Prj2Cmt*.$i.tch | /da3_data/lookup/f2bMergeSplit.perl Prj2Cmt.$i.tch 1 &

#somehow bad project names got created
for i in {0..7}		    
do gunzip -c Prj2Cmt.$i.lst | cut -d\; -f1 | perl -ane 'chop();$p0=$_;s/.*github.com_(.*_.*)/$1/;s/^bitbucket.org_/bb_/;s|\.git$||;s|/*$||;s/\;/SEMICOLON/g;$_ = "EMPTY" if $_ eq "";print "$p0;$_\n" if $p0 ne $_;' > Prj2Cmt.$i.fix
done   

s/.*github.com_([.*]_[.*])/$1/

#Collect into one if desired
for i in {0..7}; do ls -f Prj2Cmt.$i.tch;
done | /da3_data/lookup/Blob2CmtMergeTCDisjoint.perl Prj2Cmt.tch


for i in {0..7}; do ls -f Cmt2Prj.$i.tch;
done | /da3_data/lookup/Blob2CmtMergeTCDisjoint.perl Cmt2Prj.tch
		    
# ******** Done **************

#some deltaall files need fixing
gunzip -c gitPnew20140205.3.deltaall.gz | cut -d\; -f2 | uniq | gzip > c.badPrj
replace EMPTY with the 



##########################################

#on beacon
#Produce for each c2fbp.NNN.gz
for i in {00..81}; do sed "s/NNN/$i/g" | doP2CBin.pbs |qsub; done
for i in {00..81}; do sed "s/NNN/$i/g" | doC2POne.pbs |qsub; done
#Premerge
for i in {0..8}; do ls -f /fast1/Prj2Cmt.${i}[0-9].tch | ./f2bMergeSplit.perl Prj2Cmt.${i}0-${i}9 8; done
for i in {0..8}; do ls -f /fast1/Cmt2Prj.${i}[0-9].tch | ./f2nMergeSplit.perl Cmt2Prj.${i}0-${i}9 8; done
#Merge
for k in {0..7}; do 
  for i in 00-09 10-19 20-29 30-39 40-49 50-59 60-69 70-79 80-89
  do echo /fast1/Prj2Cmt.$i.$k.tch; 
  done | ./f2bMerge.perl Prj2Cmt.$k
done

for k in {0..7}; do 
  for i in 00-09 10-19 20-29 30-39 40-49 50-59 60-69 70-79 80-89
  do echo /fast1/Cmt2Prj.$i.$k.tch; 
  done | ./f2nMergeSplit.perl /data/basemaps/Cmt2Prj.$k.tch 1
done




#invert may be faster than merge Cmt2Prj
for i in {0..8}
do time for k in {0..7}; do echo /fast1/Prj2Cmt.$k.tch
   done | ./Prj2CmtInvrt.perl Cmt2PrjI.$i.tch 8 $i
done
#
##################################################
#Results in Prj2Cmt.[0-7].tch and Cmt2Prj.[0-7].tch
##################################################


#the below no longer relevant
##	*****		      See solution above with /data/All.blobs/commit_*.vs
### It seems lots of alldelta are missing, try to complete that
(gunzip -c cs.s;gunzip -c cs.81.gz) | grep -v '[^0-9a-f]'  | lsort 20G -u |gzip > cs.s1
mv cs.s1 cs.s

cut -d\; -f4 /data/All.blobs/commit_*.idx | lsort 40G | gzip > /data/basemaps/cmts.s
gunzip -c /data/basemaps/cmts.s | perl -ane 'chop(); next if length($_) != 40;print "$_\n";' | join -v1 - <(gunzip -c /da0_data/c2fbp/cs.s) | gzip >/data/basemaps/cNotInC2fbp.s
cd /data/update
gunzip -c /data/basemaps/cNotInC2fbp.s | split -l 10000000 -da 2 --filter='gzip > $FILE.gz' - cNotInC2fbp.

cat list1 | while read i; do gunzip -c $i; done | split -d -l 2000000 - list1.
for i in {00..89} {9000..9232}; do cat list1.$i | /da3_data/lookup/updatec2fbp_newpro_faster.perl 2> list1.$i.err | gzip > list1.$i.c2fbp & done
#see what we got
cat list1 | while read i; do  gunzip -c $i | cut -d\; -f2; done | lsort 80G | gzip > list1.cs &
for i in {00..89} {9000..9232}; do gunzip -c list1.$i.c2fbp | cut -d\; -f1; done | lsort 80G -u |gzip > list1.cs1 &
for i in {00..89} {9000..9232}; do gunzip -c list1.$i.c2fbp; done | uniq | gzip > list1.c2fbp &
for i in {00..89} {9000..9232}; do cat list1.$i.c2fbp.err; done | uniq | gzip > list1.c2fbp.err &

#do list2
cat list2 | while read i; do  gunzip -c $i | cut -d\; -f2; done | lsort 180G | gzip > list2.cs &
cat list2 | while read i; do gunzip -c $i; done | split -l 20000000 -d -a 3 --filter='gzip > $FILE.gz' - list2.
for i in {000..02}; do gunzip -c list2.$i.gz | /da3_data/lookup/updatec2fbp_newpro_faster.perl 2> list2.$i.err | gzip > list2.$i.c2fbp & done

for i in {000..}; do gunzip -c list2.$i.c2fbp | cut -d\; -f1; done | lsort 80G -u |gzip > list2.cs1 &
for i in {000..}; do gunzip -c list2.$i.c2fbp; done | uniq | lsort 80G -u | gzip > list2.c2fbp &
for i in {000..}; do cat list2.$i.c2fbp.err; done | uniq | gzip > list2.c2fbp.err &

#do list3
cat list3 | while read i; do  gunzip -c $i | cut -d\; -f2; done | lsort 180G | gzip > list3.cs &
cat list3 | while read i; do gunzip -c $i; done | split -l 20000000 -d -a 3 --filter='gzip > $FILE.gz' - list3.
for i in {000..0}; do gunzip -c list3.$i.gz | /da3_data/lookup/updatec2fbp_newpro_faster.perl 2> list3.$i.err | gzip > list3.$i.c2fbp & done
for i in {000..}; do gunzip -c list3.$i.c2fbp | cut -d\; -f1; done | lsort 80G -u |gzip > list3.cs1 &
for i in {000..}; do gunzip -c list3.$i.c2fbp; done | uniq | lsort 80G -u | gzip > list3.c2fbp &
for i in {000..}; do cat list3.$i.c2fbp.err; done | uniq | gzip > list3.c2fbp.err &



gunzip -c c2fbp.81.gz list[1-3].c2fbp |  split -l 1000000000 --numeric-suffixes=81 -a 2 --filter='gzip > $FILE.gz' - c2fpb81.
ls -f c2fpb81.*.c2fbp | while read i; j=$(echo $i | sed 's/^c2fpb81\./c2fpb./'); mv $i $j; done


###
			      


for i in {00..80}; do sed "s/NNN/$i/g" | doC2Pbin.pbs |qsub; done
# now pack every other into tch
for i in 00 02 04 06 08; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done
seq 10 2 78; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done


cat doP2Cmerge.pbs 
#PBS -N doP2Cmerge-NNN
#PBS -A UT-TENN0241
#PBS -l feature=beacon
#PBS -l partition=beacon
#PBS -l nodes=1:ppn=1,walltime=24:00:00
#PBS -j oe
#PBS -S /bin/bash
cd /lustre/haven/user/audris/c2fbp
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH
cloneDir=/lustre/haven/user/audris/c2fbp
cloneDir1=/lustre/haven/user/audris/c2fbp
i=NNN 
j=$(echo NNN+1|bc)
perl -I ~/lib/perl5 /nics/b/home/audris/lookup/Prj2CmtMerge.perl $cloneDir1/Prj2Cmt.$i.tch $cloneDir1/Prj2Cmt.$j.bin $cloneDir1/Prj2Cmt.$i.merge

#now merge pairs
for i in 00 02 04 06 08; do sed "s/NNN/$i/g" | doP2Cmerge.pbs |qsub; done
seq 10 2 78; do sed "s/NNN/$i/g" | doP2Cmerge.pbs |qsub; done


# now pack every merged into tch
for i in 00 04 08; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done
seq 12 4 76; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done

cat doP2Cmerge1.pbs 
#PBS -N doP2Cmerge1-NNN
#PBS -A UT-TENN0241
#PBS -l feature=beacon
#PBS -l partition=beacon
#PBS -l nodes=1:ppn=1,walltime=24:00:00
#PBS -j oe
#PBS -S /bin/bash
cd /lustre/haven/user/audris/c2fbp
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH
cloneDir=/lustre/haven/user/audris/c2fbp
cloneDir1=/lustre/haven/user/audris/c2fbp
i=NNN 
j=$(echo NNN+2|bc)
perl -I ~/lib/perl5 /nics/b/home/audris/lookup/Prj2CmtMerge.perl $cloneDir1/Prj2Cmt.$i.tch $cloneDir1/Prj2Cmt.$j.merge $cloneDir1/Prj2Cmt.$i.merge


#now merge fours
for i in 00 04 08; do sed "s/NNN/$i/g" | doP2Cmerge1.pbs |qsub; done
seq 12 4 76; do sed "s/NNN/$i/g" | doP2Cmerge1.pbs |qsub; done


# now pack every merged into tch
for i in 00 08; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done
seq 16 8 72; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done

cat doP2Cmerge2.pbs
#PBS -N doP2Cmerge2-NNN
#PBS -A UT-TENN0241
#PBS -l feature=beacon
#PBS -l partition=beacon
#PBS -l nodes=1:ppn=1,walltime=24:00:00
#PBS -j oe
#PBS -S /bin/bash
cd /lustre/haven/user/audris/c2fbp
LD_LIBRARY_PATH=$HOME/lib:$HOME/lib64:$LD_LIBRARY_PATH
cloneDir=/lustre/haven/user/audris/c2fbp
cloneDir1=/lustre/haven/user/audris/c2fbp
i=NNN 
j=$(echo NNN+4|bc)
perl -I ~/lib/perl5 /nics/b/home/audris/lookup/Prj2CmtMerge.perl $cloneDir1/Prj2Cmt.$i.tch $cloneDir1/Prj2Cmt.$j.merge $cloneDir1/Prj2Cmt.$i.merge


# now pack every merged into tch
for i in 00 08; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done
seq 16 8 72; do sed "s/NNN/$i/g" | doP2Cpack.pbs |qsub; done

#merge remaining ones manually
#first use old one
gunzip -c c2fbp.0[0-9].gz c2fbp.1[0-9].gz | /da3_data/lookup/Prj2CmtBin.perl  Prj2Cmt.0-9.bin
/da3_data/lookup/Prj2CmtMerge.perl /fast1/All.sha1c/project_commit.tch.old Prj2Cmt.0-9.bin Prj2CmtMerge.bin
/da3_data/lookup/lookup/Prj2CmtPack.perl Prj2CmtMerge.bin /fast1/All.sha1c/Prj2Cmt.0-9.tch

#do the merges until  /fast1/All.sha1c/project_commit.tch is produces
store in da4:/data/basemaps/Prj2Cmt.tch

##################################
#now do Commit to project
##################################

gunzip -c c2fbp.[78][0-9].gz | /da3_data/lookup/Cmt2PrjBin.perl Cmt2Prj.70-80.bin
gunzip -c c2fbp.6[0-9].gz | /da3_data/lookup/Cmt2PrjBin.perl Cmt2Prj.60-69.bin
gunzip -c c2fbp.5[0-9].gz | /da3_data/lookup/Cmt2PrjBin.perl Cmt2Prj.50-59.bin
gunzip -c c2fbp.4[0-9].gz | /da3_data/lookup/Cmt2PrjBin.perl Cmt2Prj.40-49.bin
gunzip -c c2fbp.[23][0-9].gz | /da3_data/lookup/Cmt2PrjBin.perl Cmt2Prj.20-39.bin
gunzip -c c2fbp.[01][0-9].gz | /da3_data/lookup/Cmt2PrjBin.perl Cmt2Prj.00-19.bin

/da3_data/lookup/Cmt2PrjPack.perl Cmt2Prj.00-19.bin Cmt2Prj.00-19.tch
/da3_data/lookup/Cmt2PrjMerge.perl Cmt2Prj.00-19.tch Cmt2Prj.20-39.bin Cmt2Prj.00-39.bin
/da3_data/lookup/Cmt2PrjPack.perl Cmt2Prj.60-69.bin Cmt2Prj.60-69.tch
/da3_data/lookup/Cmt2PrjPack.perl Cmt2Prj.40-49.bin Cmt2Prj.40-49.tch
/da3_data/lookup/Cmt2PrjMerge.perl Cmt2Prj.60-69.tch Cmt2Prj.70-80.bin Cmt2Prj.60-80.bin
/da3_data/lookup/Cmt2PrjMerge.perl Cmt2Prj.40-49.tch Cmt2Prj.50-59.bin Cmt2Prj.40-59.bin
/da3_data/lookup/Cmt2PrjPack.perl Cmt2Prj.40-59.bin Cmt2Prj.40-59.tch
/da3_data/lookup/Cmt2PrjMerge.perl Cmt2Prj.40-59.tch Cmt2Prj.60-80.bin Cmt2Prj.40-80.bin
/da3_data/lookup/Cmt2PrjPack.perl Cmt2Prj.00-39.bin Cmt2Prj.00-39.tch
/da3_data/lookup/Cmt2PrjMerge.perl Cmt2Prj.00-39.tch Cmt2Prj.40-80.bin Cmt2Prj.bin
/da3_data/lookup/Cmt2PrjPack.perl Cmt2Prj.bin commit_project.tch
mv /data/project_commit.tch /fast1/All.sha1c/



#*** this did not quite work, ignore ****
# First handle existing c2fbp: this did not quite work, ignore
Prj2Cmt
cd /da0_data/c2fbp

gunzip -c c2fbp.0[0-9].gz c2fbp.1[0-9].gz | perl Prj2CmtBin.perl 0
gunzip -c c2fbp.[23][0-9].gz | perl Prj2CmtBin.perl 10
gunzip -c c2fbp.[45][0-9].gz | perl Prj2CmtBin.perl 20
gunzip -c c2fbp.[67][0-9].gz | perl Prj2CmtBin.perl 30
gunzip -c /da4_data/play/deltaallMissingInc2fbp.pieces/update.splices.0[0-9]][0-9].gz | awk -F\; '{print $2";;;"$1}' | perl Prj2CmtBin.perl 40
gunzip -c /da4_data/play/deltaallMissingInc2fbp.pieces/update.splices.1[0-9]][0-9].gz | awk -F\; '{print $2";;;"$1}' | perl Prj2CmtBin.perl 50

#now put into the tch
perl -I ~/lib64/perl5 Prj2CmtPack.perl /data/play/prj2cmt/Prj2Cmt0.bin /data/play/prj2cmt/Prj2Cmt.tch
mv /data/play/prj2cmt/Prj2Cmt.tch /fast1/All.sha1c/project_commit.tch

for i in 10 20 3 40 50
do 
  perl -I ~/lib64/perl5 Prj2CmtMerge.perl /data/play/prj2cmt/Prj2Cmt$i.bin
  perl -I ~/lib64/perl5 Prj2CmtPack.perl /data/play/prj2cmt/Prj2Cmt.merge /data/play/prj2cmt/Prj2Cmt.tch
  mv /data/play/prj2cmt/Prj2Cmt.tch /fast1/All.sha1c/project_commit.tch
done

