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

my %fi;
open B, "|gzip>$ARGV[0].idxf";
open A, "gunzip -c files2p.gz|";
my $idx = 0;
while (<A>){
  chop();
  my ($f, $n) = split(/\;/, $_, -1);
  if (!defined $fi{$f}){
    print B "$idx;$f\n";
    $fi{$f} = $idx;
    $idx ++;
  }
}
close (B);
close (A);

my %a2f;
my $fbase="/fast1/All.sha1c/";
tie %a2f, "TokyoCabinet::HDB", "$fbase/a2fFull.tch", TokyoCabinet::HDB::OREADER,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $fbase/a2fFull.tch\n";


open A, "|gzip>$ARGV[0].bin";
open B, "|gzip>$ARGV[0].idxa";
my $idxA = 0;
while (my ($a, $v) = each %a2f){
  reMap ($a, $v);
}
untie %a2f;
close B;

sub reMap {
  my ($a, $v) = $_[0];
  my @fs = split(/\;/, safeDecomp ($v), -1);
  my %tmp = ();
  for my $f (@fs){
    if (defined $fi{$f}){
      $tmp{$fi{$f}}++; 
    }
  }
  my @is = sort keys %tmp;
  for my $i (@is){
    print A "$idxA;$i\n";
  }
  if ($#is >= 0){
    print B "$idxA;$a\n";
    $idxA ++;
  }
}

sub safeDecomp {
  my ($codeC, $par) = @_;
  try {
    my $code = decompress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex par=$par\n";
    return "";
  }
}
sub safeComp {
  my ($codeC, $par) = @_;
  try {
    my $code = compress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex par=$par\n";
    return "";
  }
}

open B, "|gzip>$ARGV[0].idxc";
my $sections = 8;
my %c2f;
for my $sec (0..($sections-1)){
  tie %c2f, "TokyoCabinet::HDB", "$fbase/c2fFull.$sec.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fbase/c2fFull.$sec.tch\n";

  while (my ($a, $v) = each %c2f){
    reMap (toHex ($a), $v);
  }

  untie %c2f;
}




