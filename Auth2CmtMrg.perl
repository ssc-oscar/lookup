#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

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

my %fhoa;
tie %fhoa, "TokyoCabinet::HDB", "$ARGV[0].tch", TokyoCabinet::HDB::OREADER,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $ARGV[0]\n";
my %fhob;
tie %fhob, "TokyoCabinet::HDB", "$ARGV[1].tch", TokyoCabinet::HDB::OREADER,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $ARGV[0]\n";
my %fhoc;
tie %fhoc, "TokyoCabinet::HDB", "$ARGV[2].tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $ARGV[0]\n";

my %seen;
my $countA = 0;
while (my ($a, $v) = each %fhob){
  $seen{$a}++;
  $fhoc{$a}=$v;
  $countA++;
}
untie %fhob;
while (my ($a, $v) = each %fhoa){
  if (!defined $seen{$a}){
    $fhoc{$a}=$v;
    $countA++;
  }
}

print "$countA authors added\n";
untie %fhoa;
untie %fhoc;


