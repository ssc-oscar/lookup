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
my $sec = $ARGV[0];
my $ver = $ARGV[1];

for my $s (0..($split-1)){
  tie %{$c2h{$s}}, "TokyoCabinet::HDB", "/fast/c2hFull$ver.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::ONOLCK,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open /fast/c2hFull$ver.$s.tch\n";
}
my %mH;
for my $s (0..($split-1)){
  tie %{$mH{$s}}, "TokyoCabinet::HDB", "/fast/mHeads$ver.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::ONOLCK,
     16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
                or die "cant open /fast/mHeads$ver.$s.tch";
}

my $ncalc = 0;
my $nlook = 0;
my $mdepth = 0;


while (my ($c, $v) = each %{$c2h{$sec}}){
 
  if (defined $mH{$sec}{$c}){
    my ($hh, $dh) = split (/;/, $mH{$sec}{$c}, -1);
    $c2h{$sec}{$c} = fromHex($hh).(pack "w", $dh);
    $nlook ++;
  }else{
    my $h = substr($v, 0, 20);
    my $d = unpack "w", substr($v, 20, length($v) - 20);
    my $s = (unpack "C", substr ($h, 0, 1)) % $split;
    if (defined $mH{$s}{$h}){
      my ($hh, $dh) = split (/;/, $mH{$s}{$h}, -1);
      $c2h{$sec}{$c} = fromHex($hh).(pack "w", $d+$dh);
      $ncalc ++;
    }
  }
}

print STDERR "nfixed=$ncalc ntails=$nlook\n";

for my $s (0..($split-1)){ 
  untie %{$c2h{$s}};
  untie %{$mH{$s}};
};




