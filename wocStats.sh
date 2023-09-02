ver=V



nP=$(zcat ../gz/P2p$ver.s|cut -d\; -f1 | uniq |wc -l) 
np=$(zcat ../gz/p2P$ver.s|wc -l) 
na=$(zcat ../gz/a2AFullH$ver.s |wc -l) 
nA=$(zcat ../gz/A2aFullH$ver.s | cut -d\; -f1 | uniq | wc -l) 


unset n
declare -A n
echo "|Object|Count|"
echo "|------|-----|"
for t in commit tree blob; do
for i in {0..127}; do 
  ni=$(tail -1 ../All.blobs/${t}_$i.idx|cut -d\; -f1)
  n[$t]=$((${n[$t]}+ni))
done
  echo "|$t|${n[$t]}|" 
done
np=$(zcat ../gz/p2P$ver.s|wc -l) 
na=$(zcat ../gz/a2AFullH$ver.s |wc -l) 
echo "|Projects(repos)|$np|"
echo "|Author IDs|$na|"

nP=$(zcat ../gz/P2p$ver.s|cut -d\; -f1 | uniq |wc -l) 
nA=$(zcat ../gz/A2aFullH$ver.s | cut -d\; -f1 | uniq | wc -l) 
echo "|Projects(deforked)|$nP|"
echo "|Authors (aliased)|$nA|"

