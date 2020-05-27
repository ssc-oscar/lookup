#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Error qw(:try);

use Digest::MD5 qw(md5 md5_hex md5_base64);
use TokyoCabinet;
use Compress::LZF;

my $sec="$ARGV[0]";
my $hdb = TokyoCabinet::HDB->new();


my %store;
my $fstore = "$ARGV[1]";
tie %store, "TokyoCabinet::HDB", "$fstore.$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT, 
   6777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $fstore\n";

my $fbasec="/fast1/All.sha1o/sha1.blob_";
my (%fhob, %fhost, %fhosc);
open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin";
tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $fbasec$sec.tch\n";

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
  my $blob = $_;
  my $hb = fromHex ($blob);
  my $v = getBlob ($hb);
  $store{$hb} = $v;
} 
untie %store;

sub toHex { 
	return unpack "H*", $_[0]; 
} 
sub fromHex { 
	return pack "H*", $_[0]; 
} 

sub getBlob {
  my ($bB) = $_[0];
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

untie %{$fhosc{$sec}};
my $f = $fhob{$sec};
close $f;


