#!/usr/bin/perl -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);

use Digest::MD5 qw(md5 md5_hex md5_base64);
use TokyoCabinet;
use Compress::LZF;

my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

if(!tie(%clones, "TokyoCabinet::HDB", "$fname",
                  TokyoCabinet::HDB::OREADER)){
        print STDERR "tie error for $fname\n";
}

my %store;
my $fstore = "$ARGV[1]";
tie %store, "TokyoCabinet::HDB", "$fstore", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT, 
   6777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $fstore\n";

my $sections = 128;
my $parts = 2;
my $fbasec="All.sha1o/sha1.blob_";
my (%fhob, %fhost, %fhosc);
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast1";
  open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin";
  $pre = "/fast1" if $sec % $parts;
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbasec$sec.tch\n";
}

sub safeDecomp {
        my $codeC = $_[0];
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex\n";
                return "";
        }
}

my $offset = 0;
while (<STDIN>){
  chop ();
  my $k = $_;
  my $vs = $clones{$k};
  my $l = length($vs);
  for my $i (0..($l/20-1)){
    my $hb = substr($vs, $i*20, 20);
    my $v = getBlob ($hb);
    $store{$hb} = $v;
  }
} 
untie %clones;
untie %store;

sub toHex { 
	return unpack "H*", $_[0]; 
} 
sub fromHex { 
	return pack "H*", $_[0]; 
} 

sub getBlob {
  my ($bB) = $_[0];
  my $sec = hex(unpack "H*", substr($bB, 0, 1)) % $sections;
  if (! defined $fhosc{$sec}{$bB}){
     print STDERR "no blob ".(toHex($bB))." in $sec\n";
     return "";
  }
  my ($off, $len) = unpack ("w w", $fhosc{$sec}{$bB});
  my $f = $fhob{$sec};
  seek ($f, $off, 0);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  return ($codeC);
}

for my $sec (0 .. ($sections-1)){
	untie %{$fhosc{$sec}};
        my $f = $fhob{$sec};
        close $f;
}


