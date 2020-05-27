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

my %tz2dat;

open A, "tzfreq";
my $tnc = 0;
my $ta = 0;
while (<A>){
  chop();
  my ($tz, $na, $n) = split (/\;/);
  $tz2dat{$tz} = "$na;$n";
  $tnc += $n;
  $ta += $na;
}
my @ts = sort keys %tz2dat;
print "header";
for my $t (@ts){
  print ";$t";
}
print "\nAuthor";
for my $t (@ts){
  my ($na, $n) = split (/;/, $tz2dat{$t}, -1);
  print ";$na";
}
print "\nCommit";
for my $t (@ts){
  my ($na, $n) = split (/;/, $tz2dat{$t}, -1);
  print ";$n";
}
print "\n";

while (<STDIN>){
  chop();
  my ($a, $n, @tzs) = split (/\;/,$_,-1);
  my %tmp = ();
  for my $tz0 (@tzs){
    my ($tz, $n1) = split (/\=/,$tz0,-1);
    $tmp{$tz} = $n1;
  }
  print "$a";
  for my $t (@ts){
    my $val = 0;
    if (defined $tmp{$t}){
      $val = $tmp{$t};
    }
    print ";$val";
  }
  print "\n";
}

