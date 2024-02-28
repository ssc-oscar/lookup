#!/usr/bin/zsh

ver=$1
v=$(echo $ver|tr '[A-Z]' '[a-z]')
for h in da0 da1 da2 da3 da4; 
do echo "CREATE TABLE api_$v (api String, from Int32, to Int32, ncmt Int32, nauth Int32, nproj Int32) ENGINE = MergeTree() ORDER BY from" |clickhouse-client --host=$h
   echo "CREATE TABLE api_all AS api_$v ENGINE = Distributed(da, default, api_$v, rand())" | clickhouse-client --host=$h

  echo "CREATE TABLE commit_$v (sha1 FixedString(20), time Int32, tc Int32, tree FixedString(20), parent String, taz String, tcz String, author String, commiter String, project String, comment String) ENGINE = MergeTree() ORDER BY time" |clickhouse-client --host=$h
  #echo "CREATE TABLE commit_all AS commit_$v ENGINE = Distributed(da, default, commit_$v, rand())" | clickhouse-client --host=$h
done
