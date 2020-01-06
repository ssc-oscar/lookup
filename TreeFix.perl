#!/usr/bin/perl -I /home/audris/lib64/perl5

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toHex { 
	return unpack "H*", $_[0]; 
} 

sub fromHex { 
	return pack "H*", $_[0]; 
} 

my $sections = 128;

my $fbaseo="All.sha1/sha1.tree_";
my $fbasei ="/data/All.blobs/tree_";

my (%fhoso);
#for my $sec (0 .. ($sections-1)){
my $sec = $ARGV[0];
my $pre = "/fast";
#tie(%hash, "TokyoCabinet::HDB", path, omode, bnum, apow, fpow, opts, rcnum)
#
#    Tie a hash variable to a hash database file.
# `path' specifies the path of the database file.
# `omode' specifies the connection mode: `TokyoCabinet::HDB::OWRITER' as a writer, `TokyoCabinet::HDB::OREADER' as a reader. If the mode is `TokyoCabinet::HDB::OWRITER', the following may be added by bitwise-or: `TokyoCabinet::HDB::OCREAT', which means it creates a new database if not exist, `TokyoCabinet::HDB::OTRUNC', which means it creates a new database regardless if one exists, `TokyoCabinet::HDB::OTSYNC', which means every transaction synchronizes updated contents with the device. Both of `TokyoCabinet::HDB::OREADER' and `TokyoCabinet::HDB::OWRITER' can be added to by bitwise-or: `TokyoCabinet::HDB::ONOLCK', which means it opens the database file without file locking, or `TokyoCabinet::HDB::OLCKNB', which means locking is performed without blocking. If it is not defined, `TokyoCabinet::HDB::OREADER' is specified.
# `bnum' specifies the number of elements of the bucket array. If it is not defined or not more than 0, the default value is specified. The default value is 131071. Suggested size of the bucket array is about from 0.5 to 4 times of the number of all records to be stored.
# `apow' specifies the size of record alignment by power of 2. If it is not defined or negative, the default value is specified. The default value is 4 standing for 2^4=16.
# `fpow' specifies the maximum number of elements of the free block pool by power of 2. If it is not defined or negative, the default value is specified. The default value is 10 standing for 2^10=1024.
# `opts' specifies options by bitwise-or: `TokyoCabinet::HDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, `TokyoCabinet::HDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, `TokyoCabinet::HDB::TBZIP' specifies that each record is compressed with BZIP2 encoding, `TokyoCabinet::HDB::TTCBS' specifies that each record is compressed with TCBS encoding. If it is not defined, no option is specified.
# `rcnum' specifies the maximum number of records to be cached. If it is not defined or not more than 0, the record cache is disabled. It is disabled by default.
#   If successful, the return value is true, else, it is false.
#
tie %{$fhoso{$sec}}, "TokyoCabinet::HDB", "$pre/${fbaseo}new_$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
      37777217, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $pre/$fbaseo$sec.tch\n";
my $nn = 0;
my $ofN = 0;
open I, "$fbasei$sec.idx" or die ($!);
open BI, "$fbasei$sec.bin" or die ($!);
open O, ">${fbasei}new_$sec.idx" or die ($!);
open BO, ">${fbasei}new_$sec.bin" or die ($!);

while (<I>){
  chop ();
  my $l = $_;
  my @x = split (/\;/, $_, -1);
  my $of = $x[1];
  my $len = $x[2];
  my $hash = $x[3];
  my $h = fromHex ($hash);
  if (!defined $fhoso{$sec} || !defined $fhoso{$sec}{$h}){
    my $nnw = pack 'w', $nn;
    $fhoso{$sec}{$h} = $nnw;
    seek (BI, $of, 0);
    my $cnt = "";
    my $rlen = read (BI, $cnt, $len);
    if ($rlen == $len){
      print O "$nn;$ofN;$len;$hash\n";;
      print BO $cnt;
      $nn++;
      $ofN += $len;
    }else{
      die "can not rea\n";
    }
  }
}
untie %{$fhoso{$sec}};
print "done/updated $nn\n";

