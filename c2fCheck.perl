#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /da3_data/lookup
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

my %c2f;
while (<STDIN>){
  chop();
  my $str = $_;
  my ($hsha, $f, $p, $b) = split (/\;/, $str, -1);
  next if defined $badCmt{$hsha};
  my $sha = fromHex ($hsha);
  $f =~ s/;/SEMICOLON/g;
  $f =~ s|^/*||;
  next if $f eq "";
  if (!defined  $c2f{$sha}){
    my $sec = (unpack "C", substr ($sha, 0, 1))%$split;
    for my $f0 (split(/\;/, safeDecomp ($c2f0{$sec}{$sha}), -1)){
		 $c2f{$sha}{$f}++;
    }
  }
  print "$str\n" if !defined $c2f{$sha}{$f};
}


for my $sec (0..($split-1)){
  untie %{$c2f0{$sec}};
}

