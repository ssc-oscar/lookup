for i in blob commit tree tag; do for j in {0..127}; do tail -1 /data/All.blobs/${i}_$j.idx | cut -d\; -f1; done | awk '{print i+=$1,"'$i'"}' | tail -1; done
