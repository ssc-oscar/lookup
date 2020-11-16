#!/usr/bin/perl

use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

package woc;
use strict;
use warnings;
use Compress::LZF;

my $s = $ARGV[0];
open A, "zcat blob_$s.idxf2|";
open B, "blob_$s.bin";
my $line = <A>;
my ($n, $off, $len, $cb, @x) = split(/\;/, $line, -1);
%parse = (
	'Rust' => &Rust;
);

while (<STDIN>){
  chop();
  my ($b, $type, $t, $f) = split (/\;/, $_, -1);
  next if defined $badBlob{$b};
  while ($cb ne $b){ 
	 $line = <A>;
    ($n, $off, $sz, $cb, @x) = split(/\;/, $line, -1);
  }
  my $codeC = getBlob ($b);
  $code = safeDecomp ($codeC, "$offset;$hh");
  $code =~ s/\r//g;
  my $base = "$cb";
  $parse{$type} -> ($code, $base);
}

sub Rust {
	my ($code, $base) = @_;
  # two types of match
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^use\s+(\w+)/) {
      $matches{$1}++ if defined $1;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
  $offset++;
}

sub getBlob {
  my ($b) = $_[0];
  seek (B, $off, 0);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  return ($codeC);
}
