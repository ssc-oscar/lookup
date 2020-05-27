#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");

use strict;
use warnings;
use Error qw(:try);
use TokyoCabinet;
use Compress::LZF;
use cmt;


my $sections = 32;


my $a2cf = $ARGV[0];
my %a2c;
tie %a2c, "TokyoCabinet::HDB", "$a2cf", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $a2cf\n";

my $c2ff = $ARGV[1];
my %c2f;
for my $sec (0..($sections-1)){
  tie %{$c2f{$sec}}, "TokyoCabinet::HDB", "$c2ff.$sec.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $c2ff.$sec.tch\n";
}

my %a2f1;
tie %a2f1, "TokyoCabinet::HDB", "$ARGV[2]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

my %badC;
for my $c (keys %badCmt){
  $badC{fromHex ($c)}++;
}
my $line = 0;
my %a2f;
while (my ($a, $v) = each %a2c){
  $a2f{$a}{"."}++;
  my $ns = length ($v)/20;
  for my $i (0..($ns-1)){
    my $c = substr ($v, $i*20, 20);
    next if defined $badC{$c}; #ignore humongous commits
    my $sec =  hex (unpack "H*", substr($c, 0, 1)) % $sections;
    if (defined $c2f{$sec}{$c}){
      my @fs = split(/\;/, safeDecomp ($c2f{$sec}{$c}, $a), -1);
      for my $f (@fs){
        $a2f{$a}{$f}++;
      }
    }else{
      #my $c1 = toHex($c);
      #print STDERR "no commit $c1 for $a\n";
    }
  }
  $line ++;
  if (!($line%100000)){
    print STDERR "dumping $line\n";
    dumpData();
    %a2f = ();
  }   
}
untie %a2c;
for my $sec (0..($sections-1)){
  untie %{$c2f{$sec}};
}

sub dumpData { 
  while (my ($a, $v) = each %a2f){
    delete $v ->{"."};
    my $v1 = safeComp (join ";", sort keys %{$v}, $a);
    $a2f1{$a}=$v1;
  }
}
untie %a2f1;


