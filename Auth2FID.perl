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

#gunzip -c /da4_data/basemaps/f2cFullF.[0-7].lst | grep -v ';1$' | gzip > files2pF.gz
open A, "gunzip -c files2pF.gz|";
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


#./Auth2File.perl Auth2File.tch &> Auth2File.err
#cp -p Auth2File.tch  /fast1/All.sha1c/
my %a2f;
my $fbase="/fast1/All.sha1c/";
tie %a2f, "TokyoCabinet::HDB", "$fbase/Auth2File.tch", TokyoCabinet::HDB::OREADER,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $fbase/Auth2File.tch\n";


open A, "|gzip>$ARGV[0].bina";
open B, "|gzip>$ARGV[0].idxa";
my $idxA = 0;
while (my ($a, $v) = each %a2f){
  reMap ($a, $v);
}
untie %a2f;
close B;

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




