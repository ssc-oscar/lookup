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


my (%c2m1);
my $lines = 0;
my $f0 = "";
my $cnn = 0;
my $nc = 0;
while (<STDIN>){
  chop();
  $lines ++;
  my ($mid, $mlen, $hsha, $a, $t, $p) = split (/\;/, $_);
  if (length ($hsha) != 40){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $sha = fromHex ($hsha);
  $c2m1{$mid}{$sha}++;
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
  tie %$c2p, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
  }
  while (my ($c, $v) = each %c2m1){
    $lines ++;
    print STDERR "$lines done out of $nc\n" if (!($lines%100000000));
    my $ps = join '', sort keys %{$v};
    $c2m{$c} = $ps;
  }
  untie %c2p;
}
