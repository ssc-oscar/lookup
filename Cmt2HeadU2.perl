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

BEGIN { $SIG{'__WARN__'} = sub { if (0) { print STDERR $_[0]; } } };

my $split = 32;

my (%c2h, %c2cc);
my $ver = $ARGV[0];

my %mH;
for my $s (0..($split-1)){
  tie %{$mH{$s}}, "TokyoCabinet::HDB", "/fast/mHeads$ver.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::ONOLCK,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
	   or die "cant open /fast/mHeads$ver.$s.tch";
}
while (<STDIN>){
  chop();
  my ($ch, $hh, $d) = split (/;/, $_, -1);
  my $c = fromHex ($ch);
  my $s = (unpack "C", substr ($c, 0, 1)) % $split;
  $mH{$s}{$c} = "$hh;$d";
}
for my $s (0..($split-1)){
  untie %{$mH{$s}};
}
