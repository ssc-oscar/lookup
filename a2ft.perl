#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Error qw(:try);
use TokyoCabinet;
use Compress::LZF;
use cmt;

my $part = $ARGV[0];

my $sections = 32;


my %c2f;
for my $s (0..($sections-1)){
  tie %{$c2f{$s}}, "TokyoCabinet::HDB", "/fast/c2fFullO.$s.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open fast/c2fFullO.$s.tch\n";
}

my %c2ta;
for my $s (0..($sections-1)){
  tie %{$c2ta{$s}}, "TokyoCabinet::HDB", "/fast/c2taFullP.$s.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open fast/c2taFullP.$s.tch\n";
}
my %a2ft;
tie %a2ft, "TokyoCabinet::HDB", "/data/play/dkennard/a2ftFullP.$part.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
		     or die "cant open /data/play/dkennard/a2ftFullP.$part.tch\n";

my %badC;
for my $c (keys %badCmt){
  $badC{fromHex ($c)}++;
}

my $line = 0;
my (@cs, %a2f1);
my $pa = "";

while (<STDIN>){
  chop();
  my ($a, $ch) = split (/\;/, $_, -1);
  my $c = fromHex ($ch);
  if ($pa ne "" && $pa ne $a){
    output ($pa);
    @cs = ();
  }
  push @cs, $c;
  $pa = $a;
  if (!(($line++)%1000000)){
    print STDERR "processed $line lines\n";
  } 
}
output ($pa);

sub output {
  my $a = $_[0];
  my %fs;
  for my $c (@cs){
    my $sec =  segB ($c, $sections);
    if (defined $c2f{$sec}{$c} and defined $c2ta{$sec}{$c}){
      my @fs = split(/\;/, safeDecomp ($c2f{$sec}{$c}, $a), -1);
	  my ($time, $au) = split(/\;/, $c2ta{$sec}{$c}, -1);
      for my $f (@fs){
		if (defined $time and (!defined $fs{$f} or $time < $fs{$f})){
			$fs{$f} = $time;
		}
      }
    }
  }
  $a2ft{$a} = safeComp (join ';', %fs);
}


for my $sec (0..($sections-1)){
  untie %{$c2f{$sec}};
  untie %{$c2ta{$sec}};
}

untie %a2ft
