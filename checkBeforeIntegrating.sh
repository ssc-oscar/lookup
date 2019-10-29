
#check if the objects follow git object standard before merging in
pre=gh
nn=0
for t in blob tag commit tree
do ls -f  *$nn.*$t.bin  | sed 's/\.bin$//' | \
  while read i
  do (echo $i; perl -I ~/lib64/perl5/ ~/lookup/checkBin1in.perl $t $i) &>> ../$pre$nn.$t.err
  done
done 
