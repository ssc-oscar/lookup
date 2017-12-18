# Scripts to create various lookup tables

## f2b.md
describes mapping between trees/blobs and file/folder names. It
oprates off blob/tree/commit objects. The remaining maps utilize
c2fbp map split into 80 (1B line) chunks (see below).

## Cmt2Blob.sh
Blob to commit and inverse

## Prj2Cmt.sh
Project to commit and inverse


## c2fbp.[0-9][0-9].gz

There are various ways to construct the commit to filename, blob,  
project map: c2fbp.[0-9][0-9].gz

For example:

updatec2fbp_newpro_faster.perl - completes c2fbp for new data in /fast1/All.sha1c/tree*





