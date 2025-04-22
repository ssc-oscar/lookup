for i in {0..127}
do for t in tag commit tree blob
  do n=$(tail -1 /da5_data/All.blobs/${t}_$i.idx|cut -d\; -f4 | ~/lookup/showCnt $t | wc -l)
     echo "$t;$i;$n"
  done 
done
