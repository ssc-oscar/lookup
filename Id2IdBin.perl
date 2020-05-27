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

my $inverse = $ARGV[1];
my (%c2p1);
my $sec;
my $nsec = 1;
$nsec = $ARGV[1] if defined $ARGV[1];


my $lines = 0;
my $f0 = "";
my $cnn = 0;
my $nc = 0;
while (<STDIN>){
  chop();
  $lines ++;
  my ($f, $p) = split (/\;/, $_);
  my $fp = pack "L*", $f+0;
  my $pp = pack "L*", $p+0;
  if ($inverse){
    $nc ++ if !defined $c2p1{$pp};
    $c2p1{$pp}{$fp}++;
  }else{
    $nc ++ if !defined $c2p1{$fp};
    $c2p1{$fp}{$pp}++;
  }
  print STDERR "$lines done\n" if (!($lines%100000000));
}

print STDERR "read $lines dumping $nc commits\n";
$lines = 0;
outputTC ($ARGV[0]);
print STDERR "dumped $lines\n";

sub outputTC {
  my $n = $_[0];
  my %c2p;
  my $fname = "$ARGV[0]";
  tie %c2p, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
  while (my ($c, $v) = each %c2p1){
    $lines ++;
    print STDERR "$lines done out of $nc\n" if (!($lines%100000000));
    my $ps = join '', sort keys %{$v};
    $c2p{$c} = $ps;
  }
  untie %c2p;
  
}
