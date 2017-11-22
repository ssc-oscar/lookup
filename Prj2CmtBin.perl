#!/usr/bin/perl -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

my (%c2p1);

my $lines = 0;
my $nn = $ARGV[0];
my $f0 = "";
my $cnn = 0;
while (<STDIN>){
  chop();
  $lines ++;
  my ($hsha, $f, $b, $p) = split (/\;/, $_);
  if (length ($hsha) != 40){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $sha = fromHex ($hsha);
  $p =~ s/^github.com_//;
  $p =~ s/^bitbucket.org_/bb_/;
  $c2p1{$p}{$sha}++;
  print STDERR "$lines done\n" if (!($lines%100000000));
}

print STDERR "$lines dump\n";
output ($nn);
print STDERR "$lines done\n";

sub output {
  my $n = $_[0];
  open A, '>:raw', "/data/Prj2Cmt$n.bin"; 
  while (my ($k, $v) = each %c2p1){
    my @shas = sort keys %{$v};
    my $nshas = $#shas+1;
    my $nsha = pack "L", $nshas;
    my $lp = pack "S", length($k);
    print A $lp;
    print A $k;
    print A $nsha;
    print A "".(join '', @shas);
  }
}



