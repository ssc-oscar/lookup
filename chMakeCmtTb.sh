#!/usr/bin/zsh

for h in da0 da1 da2 da3 da4; 
do echo "CREATE TABLE commit_s (sha1 FixedString(20), time Int32, tc Int32, tree FixedString(20), parent String, taz String, tcz String, author String, commiter String, project String, comment String) ENGINE = MergeTree() ORDER BY time" |clickhouse-client --host=$h
  echo "CREATE TABLE commit_all AS commit_s ENGINE = Distributed(da, default, commit_s, rand())" | clickhouse-client --host=$h
done
