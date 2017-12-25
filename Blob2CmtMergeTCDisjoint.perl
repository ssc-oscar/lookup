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

my %b2cI;
my %b2cO;
tie %b2cO, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";


while (<STDIN>){
  chop();
  my $f = $_;
  tie %b2cI, "TokyoCabinet::HDB", "$f", TokyoCabinet::HDB::OREADER, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $f\n";  
  while (my ($k, $v) = each %b2cI){
    if (defined $b2cO{$k}){
       print STDERR "seen key $k before\n";
       last;
    }
    $b2cO{$k} = $v;
  }
  untie %b2cI;
}


untie %b2cO;

