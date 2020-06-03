#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;


my $split = 1;
$split = $ARGV[1] + 0 if defined $ARGV[1];

my %p2c;
for my $sec (0..($split-1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if ($split == 1);
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}

while (<STDIN>){
  chop();
  my ($p, $p1) = split(/\;/, $_, -1);
  #my $sec = (unpack "C", substr ($p, 0, 1))%$split;
  my $sec = 0;
  $sec = sHash ($p, $split) if $split > 1;
  my $sec1 = 0;
  $sec1 = sHash ($p1, $split) if $split > 1;
  #print "$sec;$p\n";
  if (defined $p2c{$sec}{$p} && defined $p2c{$sec1}{$p1}){
    my ($s, $n, $n1) = list ($p2c{$sec}{$p}, $p2c{$sec1}{$p1});
    print "$p;$p1;$s;$n;$n1\n";
  }else{
    print STDERR "no $p in $sec or $p1 in $sec1\n";
  }
  
}
for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
}


sub list {
  my ($v, $v1) = @_;
  my $ns = length($v)/20;
  my $ns1 = length($v1)/20;
  my %cs = ();
  my $sim = 0;
  if ($ns < $ns1){
    for my $i (0..($ns-1)){
      my $c = substr ($v, 20*$i, 20);
      $cs{$c}++;
    }
    for my $i (0..($ns1-1)){
      my $c = substr ($v1, 20*$i, 20);
      $sim += 1 if defined $cs{$c};
    }
  }else{
    for my $i (0..($ns1-1)){
      my $c = substr ($v1, 20*$i, 20);
      $cs{$c}++;
    }
    for my $i (0..($ns-1)){
      my $c = substr ($v, 20*$i, 20);
      $sim += 1 if defined $cs{$c};
    }
  }
  ($sim, $ns, $ns1);
}


