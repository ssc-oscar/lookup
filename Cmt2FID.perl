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

my %fi;
open B, "gunzip -c $ARGV[0].idxf|";
while (<B>){
  chop();
  my ($idx, $f) = split(/\;/, $_, -1);
  $fi{$f} = $idx;
}
close (B);


my $sec = $ARGV[1];
my $idxA = 0;
open B, "|gzip>$ARGV[0].$sec.idxc";
open A, "|gzip>$ARGV[0].$sec.binc";
my $sections = 8;
my $fbase ="/fast1/All.sha1c";
my %c2f;
#for my $sec (0..($sections-1)){
  tie %c2f, "TokyoCabinet::HDB", "$fbase/c2fFull.$sec.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fbase/c2fFull.$sec.tch\n";

  while (my ($a, $v) = each %c2f){
    reMap (toHex ($a), $v);
  }

  untie %c2f;
#}


sub reMap {
  my ($a, $v) = @_;
  my @fs = split(/\;/, safeDecomp ($v), -1);
  my %tmp = ();
  for my $f (@fs){
    $f =~ s/\n$//;
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


