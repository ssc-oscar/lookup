#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

sub safeComp {
  my $code = $_[0];
  try {
    my $codeC = compress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}
sub safeDecomp {
  my $code = $_[0];
  try {
    my $codeC = decompress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}


my $pa = "";
my %a2z;
while (<STDIN>){
  chop();
  my ($a, $t) = split (/\;/, $_);
  if ($a ne $pa && $pa ne ""){
    output ();
    %a2z=();
  }
  $t =~ s/^\s*//;
  $t =~ s/\s*$//;
  $t =~ s/\s+/ /g;
  my ($t0, $tz) = split (/ /, $t);

  $a2z{tz}{$tz}++;
  $a2z{t}{$t0}++;
  $a2z{n}++;
  $pa = $a;
}
output ();

sub output {
  my $n = $a2z{n};
  my @tzs = sort keys %{$a2z{tz}}; 
  my @ts = sort keys %{$a2z{t}}; 
  my $str = "$pa;$a2z{n}";
  for my $tz (@tzs){
    $str .= ";$tz=$a2z{tz}{$tz}";
  } 
  print "$str\n";
} 

