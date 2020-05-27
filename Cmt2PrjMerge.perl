#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
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


sub safeComp {
  my $code = $_[0];
  try {
    my $codeC = compress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}

sub safeDecomp {
  my $code = $_[0];
  try {
    my $codeC = decompress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}


my %c2p;
tie %c2p, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";


open B, '>:raw', "$ARGV[2]";
open A, "<$ARGV[1]";
binmode(A); 


my $lines = 0;
my %touched;
procBin ($ARGV[1]);
while (my ($k, $v) = each %c2p){
  if (!defined ($touched{$k})){
    out ($k, $v);
  }
}
sub procBin {
  print "processing $ARGV[1]\n";  
  until (eof(A))
  {
    my $buffer;
    my $nread = read (A, $buffer, 20, 0);
    my $c = $buffer;
    $nread = read (A, $buffer, 4, 0);
    my $l = unpack 'L', $buffer;
    $nread = read (A, $buffer, $l, 0);
    my $p = $buffer;
    if (defined $c2p{$c}){
      $touched{$c}++;
      collect ($c, $p, $c2p{$c});
    }else{
      out ($c, $buffer);
    }
    $lines ++;
    print STDERR "$lines done\n" if (!($lines%5000000)); 
  }
}


sub merge {
  my ($v0, $v1) = @_;
  my $ns0 = length($v0)/20;
  my $ns1 = length($v1)/20;
  my %sa = ();
  for my $i (0..($ns0-1)){
    $sa{(substr ($v0, 20*$i, 20))}++;
  }
  for my $i (0..($ns1-1)){
    $sa{(substr ($v1, 20*$i, 20))}++;
  }
  return join '', (sort keys %sa);
}


sub collect {
  my ($c, $v0, $v1) = @_;
  my %tmp = ();
  for my $p (split(/\;/, safeDecomp($v0))){
    $p =~ s/\.git$//;
    $tmp{$p}++;
  }
  for my $p (split(/\;/, safeDecomp($v1))){
    $p =~ s/\.git$//;
    $tmp{$p}++;
  }
  out ($c, safeComp (join ';', keys %tmp));
}

untie %c2p;

sub out {
  my ($k, $v) = @_;
  my $l = length($v);
  my $np = pack "L", $l;
  print B $k;
  print B $np;
  print B $v;
}






