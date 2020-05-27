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

my %a2i;

if (0){
open A, "gunzip -c Auth2FID.idxa|";
while (<A>){
  chop();
  my ($i, $a) = split (/\;/);
  $a2i{$a} = $i;
}
}
my %t2a;
my %a2t;
my %i2t;
my $itz = 0;
while (<STDIN>){
  chop();
  my ($a, $n, @tzs) = split (/\;/,$_,-1);
  my $ai = $a2i{$a};
  my %tmp;
  for my $tz0 (@tzs){
    my ($tz, $n1) = split (/\=/,$tz0,-1);
    $a2t{$tz} ++;
    $i2t{$tz} += $n;
    #$t2a{$tz}{$ai} = $n1/($n+0.0);
  }
}

for my $tz (keys %i2t){
  print "$tz\;$a2t{$tz};$i2t{$tz}\n";
}


