#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_data/lookup
use strict;
use warnings;
use Error qw(:try);
use cmt;

use Digest::MD5 qw(md5 md5_hex md5_base64);
use TokyoCabinet;
use Compress::LZF;

#my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

my $sec = $ARGV[0];
my (%fhob, %fhosc);
open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin";
tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "/fast/All.sha1o/sha1.blob_$sec.tch", TokyoCabinet::HDB::OREADER,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/All.sha1o/sha1.blob_$sec.tch\n";

my $offset = 0;
while (<STDIN>){
  chop ();
  my ($bh, @rest) = split(/;/, $_, -1);
  next if defined $badBlob{$bh};
  my $b = fromHex($bh);
  my $codeC = getBlob ($b);
  my $hh = $b;
  my $code = $codeC;
  $code = safeDecomp ($codeC, "$offset;$hh");
  $code =~ s/\r//g;
  my $val = extr ($code);
  print "$bh;$val;".(join ';', @rest)."\n";
  print "$code\n" if defined $ARGV[1]; 
  $offset++;
}
sub extr {
  my $code = $_[0];
  my $res = "";
  for my $l (split(/\n/, $code, -1)){
    $res = $1 if $l =~ /^Package:\s*(.*)$/;
  }
  $res;
}
untie %clones;

untie %{$fhosc{$sec}};
my $f = $fhob{$sec};
close $f;


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





