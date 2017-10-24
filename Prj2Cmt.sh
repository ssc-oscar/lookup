# First handle existing c2fbp
cd /da0_data/c2fbp
gunzip -c c2fbp.[0-9].gz c2fbp.1[0-9].gz | perl Prj2CmtBin.perl 0
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
