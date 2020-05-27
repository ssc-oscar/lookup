#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;

my $split = 1;
$split = $ARGV[1] + 0 if defined $ARGV[1];

my %c2f0;
for my $sec (0..($split-1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if ($split == 1);
  tie %{$c2f0{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}

my %c2f = ();
my $psha = "";
while (<STDIN>){
  chop();
  my $str = $_;
  my ($hsha, $f, $p, $b) = split (/\;/, $str, -1);
  next if !defined $hsha  || $hsha !~ m/^[0-f]{40}$/;
  next if defined $badCmt{$hsha};
  $f =~ s/;/SEMICOLON/g;
  $f =~ s|^/*||;
  next if $f eq "";

  my $sha = fromHex ($hsha);
  if ($psha ne $sha){
    %c2f = ();
    $psha = $sha;
    my $sec = (unpack "C", substr ($sha, 0, 1))%$split;
    if (defined $c2f0{$sec}{$sha}){
      for my $f0 (split(/\;/, safeDecomp ($c2f0{$sec}{$sha}), -1)){
        $c2f{$f0}++;
      }
    }
  }
  print "$str\n" if !defined $c2f{$f};
}


for my $sec (0..($split-1)){
  untie %{$c2f0{$sec}};
}

