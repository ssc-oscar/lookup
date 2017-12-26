##################################
#now do Project to commit
##################################

#on beacon

#Produce for each c2fbp.NNN.gz
for i in {00..81}; do sed "s/NNN/$i/g" | doP2CBin.pbs |qsub; done
for i in {00..81}; do sed "s/NNN/$i/g" | doC2POne.pbs |qsub; done
#Premerge
for i in {0..8}; do ls -f /fast1/Prj2Cmt.${i}[0-9].tch | ./f2bMergeSplit.perl Prj2Cmt.${i}0-${i}9.tch 8; done
for i in {0..8}; do ls -f /fast1/Cmt2Prj.${i}[0-9].tch | ./f2nMergeSplit.perl Cmt2Prj.${i}0-${i}9.tch 8; done
#Merge
for k in {0..7}; do 
  for i in 00-09 10-19 20-29 30-39 40-49 50-59 60-69 70-79 80-89
  do echo /fast1/Prj2Cmt.$i.$k.tch; 
  done | ./f2bMerge.perl Prj2Cmt.$k
done
for k in {0..7}; do 
  for i in 00-09 10-19 20-29 30-39 40-49 50-59 60-69 70-79 80-89
  do echo /fast1/Cmt2Prj.$i.$k.tch; 
  done | ./f2nMerge.perl Cmt2Prj.$k
done


#Collect into one
for i in {0..7}; do ls -f Prj2Cmt.$i.tch;
done | ./Blob2CmtMergeTCDisjoint.perl Prj2Cmt.tch
for i in {0..7}; do ls -f Cmt2Prj.$i.tch;
done | ./Blob2CmtMergeTCDisjoint.perl Cmt2Prj.tch



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

