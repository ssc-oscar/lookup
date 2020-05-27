#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;

my (%tmp, %c2p, %c2p1);
my $sec;
my $nsec = 8;
$nsec = $ARGV[1] + 0 if defined $ARGV[1];

for $sec (0..($nsec -1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if $nsec == 1;
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

my $lines = 0;
my $f0 = "";
my $cnn = 0;
my $nb = 0;
my $doDump = 0;
my $bp = "";
while (<STDIN>){
  chop();
  $lines ++;
  my ($hc, $f, $hb, $p) = split (/\;/, $_);
  if ($hb !~ m|^[0-9a-f]{40}$|i || defined $badBlob{$hb}){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $b = fromHex ($hb);
  $f =~ s/;/SEMICOLON/g;
  $f =~ s|^/*||;
  next if $f eq "";
  if ($b ne $bp && $bp ne ""){
    $sec = (unpack "C", substr ($bp, 0, 1))%$nsec;
    $nb ++;
    my $ps = join ';', sort keys %tmp;
    my $psC = safeComp ($ps);
    $c2p{$sec}{$bp} = $psC;
    %tmp = ();
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $bp = $b;
  $tmp{$f}++;
  if (!($lines%500000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}

my $ps = join ';', sort keys %tmp;
my $psC = safeComp ($ps);
$sec = (unpack "C", substr ($bp, 0, 1))%$nsec;
$c2p1{$sec}{$bp} = $psC;
dumpData ();


sub dumpData {
  for my $s (0..($nsec -1)){
    while (my ($c, $v) = each %{$c2p1{$s}}){
      $c2p{$s}{$c} = $v;
    }
    %{$c2p1{$s}} = ();         
  }
}

for $sec (0..($nsec -1)){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines dumping $nb blobs\n";

