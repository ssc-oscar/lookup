#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use woc;

my (%tmp, %h2hw);

my $fname = "$ARGV[0]";
tie %h2hw, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";

while (<STDIN>){
  chop();
  my ($ch, $rh, $drh, $hh, $dhh, $ph) = split (/\;/, $_);
  my $c = fromHex ($ch);
  my $r = fromHex ($rh);
  my $h = fromHex ($hh);
  my $dr = pack 'w', $drh;
  my $dh = pack 'w', $dhh;
  my $p = pack 'w', $ph;
  $h2hw{$c} = $r.$h.$dr.$dh.$p;
}
untie %h2hw;

