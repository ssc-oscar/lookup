#tree to commit
for k in {0..120..8}
do sed "s/NNN/$k/g" doT2C.pbs | qsub
done

ls -f t2c* | ./f2bMerge.perl t2c

#tree to parent tree

for k in {0..112..16}
do sed "s/NNN/$k/g" doT2PT.pbs | qsub
done


#tree name to tree

 
for k in {0..112..16}
do sed "s/NNN/$k/g" doN2T.pbs | qsub
done

for k in {0..120..8}
do sed "s/NNN/$k/g" doN2Tmerge.pbs | qsub
done
