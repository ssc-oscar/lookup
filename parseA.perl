#!/usr/bin/perl

use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use Compress::LZF;
use strict;
use warnings;


sub safeDecomp {
  my ($codeC, $msg) = @_;
  my $code = "";
  eval { 
    $code = decompress ($codeC);
    return $code;
  } or do {
    my $ex = $@;
    print STDERR "Error: $ex, msg=$msg, code=$code\n";
    eval {
      $code = decompress (substr($codeC, 0, 70));
      return "$code";
    } or do {
      my $ex = $@;;
      print STDERR "Error: $ex, $msg, $code\n";
      return "";
    }
  }
}

my $s = $ARGV[0];
open A, "zcat blob_$s.idxf2|";
open B, "blob_$s.bin";

my %b2t;

my %parse = (
	'Rust' => \&Rust
);

while (<STDIN>){    
  chop();
  my ($b, $type, $t, $f) = split (/\;/, $_, -1);
  $b2t{$b} = $type;
}

my ($n, $off, $len, $cb, @x);

while (<A>){
  ($n, $off, $len, $cb, @x) = split(/\;/, $_, -1);
  if (defined $b2t{$cb} && $b2t{$cb} ne ""){ 
    my $codeC = getBlob ($cb);
    my $code = safeDecomp ($codeC, "$off;$cb");
    $code =~ s/\r//g;
    my $base = "$cb";
    my $type = $b2t{$cb};
    print "$type\n";
    $parse{$type} -> ($code, $base);
  }
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
}

sub getBlob {
  my ($b) = $_[0];
  seek (B, $off, 0);
  my $codeC = "";
  my $rl = read (B, $codeC, $len);
  return ($codeC);
}
