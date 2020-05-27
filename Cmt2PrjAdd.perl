#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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

sub safeDecomp {
  my ($codeC, $n) = @_;
  try {
    my $code = decompress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex; $n\n";
    return "";
  }
}
sub safeComp {
  my ($codeC, $n) = @_;
  try {
    my $code = compress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex; $n\n";
    return "";
  }
}


my $split = 1;
$split = $ARGV[3] + 0 if defined $ARGV[3];

my (%p2c, %p2c1, %p2c2);
for my $sec (0..($split-1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if ($split == 1);
  tie %p2c, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
  $fname = "$ARGV[1].$sec.tch";
  $fname = $ARGV[1] if ($split == 1);
  tie %p2c1, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
  $fname = "$ARGV[2].$sec.tch";
  $fname = $ARGV[2] if ($split == 1);
  tie %p2c2, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
  while (my ($k, $v1) = each %p2c1){
    if (defined $p2c{$k}){
      my $v = $p2c{$k};
      if ($v1 ne $v){
        my %a = ();  
        for my $p (split(/;/, safeDecomp ($v1), -1)){
          $a{$p}++;
        }
        for my $p (split(/;/, safeDecomp ($v), -1)){
          $a{$p}++;
        }
        $v = safeComp (join ';', sort keys %a);
      }
      $p2c2{$k} = $v;
    }else{
      $p2c2{$k} = $v1 
    }
  }
  while (my ($k, $v) = each %p2c){
    if (!defined $p2c1{$k}){
      $p2c2{$k} = $v;
    }
  }
  untie %p2c1;
  untie %p2c;
  untie %p2c2;
}




