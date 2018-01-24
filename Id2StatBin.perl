#!/usr/bin/perl -I /home/audris/lib64/perl5
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
  my $fp = pack "L*", ($f+0);
  $c2p1{$fp}+=$p;
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
    my $vp = pack "L*", $v + 0;
    $c2p{$c} = $vp;
  }
  untie %c2p;
}
