#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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

my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";
my %c2t;
for my $s (0..127){
  tie %{$c2t{$s}}, "TokyoCabinet::HDB", "$ARGV[1].$s.tch", TokyoCabinet::HDB::OREADER#, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[1]\n";
}
while (my ($p, $v) = each %p2c){
  #my $p = "PatentMonk_synapse_pay-ruby";
  #my $v = $p2c{$p};
  list ($p, $v);
}
untie %p2c;
for my $s (0..127){
  untie %{$c2t{$s}};
}

sub list {
  my ($p, $v) = @_;
  $p =~ s/\n$//;
  my $ns = length($v)/20;
  #print STDERR "$p;$ns\n";
  print "$p;$ns";
  my %tmp;
  for my $i (0..($ns-1)){
    my $c = substr ($v, 20*$i, 20);
    my $sec = (unpack "C", substr ($c, 0, 1))%128;   
    if (defined $c2t{$sec}{$c}){
      my ($t, $a) = unpack "La*", $c2t{$sec}{$c};
      $tmp{$a}{$t}++;
    }else{
      print STDERR "$p;no time;".(toHex ($c))."\n";
    }
  }
  my @as = keys %tmp;
  print ";".($#as+1);
  for my $a (@as){
    my @ts = sort keys %{$tmp{$a}};
    print ";$a;$ts[0];$ts[$#ts]";
  }
  print "\n";
}


