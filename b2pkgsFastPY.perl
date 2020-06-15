#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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
  next if defined $badBlob{$_};
  my $b2 = fromHex($_);
  my $codeC = getBlob ($b2);
  my $hh = $b2;
  $hh = unpack 'H*', $b2 if length($b2) == 20;
  my $code = $codeC;
  $code = safeDecomp ($codeC, "$offset;$hh");
  $code =~ s/\r\n/\n/g;
  $code =~ s/\r//g;#in case only cr
  $code =~ s/\\\n//g;#join line continuations
  # two types of match
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^import\s+(.*)/) {
      my $rest = $1;
      $rest =~ s/\s+as\s+.*//;
      while ($rest =~ m/\s*(\w[^\s,]*)[\,\s]*/g){
        #old my @mds = $1 =~ m/(\w+[\,\s]*)*/;
        my $m = $1;
        $m =~ s/\s*$//; 
        $matches{$m}++ if defined $m;
      }
    }
    if ($l =~ m/^from\s+(\w[\w.]*)\s+import\s+(\w*|\*)/) {
       if ($2 ne ""){
         $matches{"$1.$2"} = 1;
#old if ($l =~ m/^\s*from\s+(\w+)/) {
       }else{
         my $m = $1;
         $m =~ s/\s*$//;
         $matches{$m} = 1;
       }
    }
  }
  if (%matches){
    print $_;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
  $offset++;
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





