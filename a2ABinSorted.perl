#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;


my ($tmp, %c2p, %c2p1);
my $fname = $ARGV[0];
tie %c2p, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $fname\n";

my $lines = 0;
my $nc = 0;
my $doDump = 0;
my $ap = "";
my $pt = time();
my $p0 = $pt;

while (<STDIN>){
  chop();
  $lines ++;
  my ($a, $A, $bad0, $bad1) = split (/\;/, $_);
  if ($a eq ""){ # || defined $badCmt{$hc} || defined $badBlob{$hc}){
    print STDERR "empty for A=$A\n";
    next;
  }    
  if ($A eq ""){ # these are on the right side: should be ok || defined $badCmt{$hb} || defined $badBlob{$hb}){
    print STDERR "empty A for $a\n";
  }
  if ($a ne $ap && $ap ne ""){
    $nc ++;
    $tmp =~ s/^;//;
    large ($tmp, $ap);
    $tmp = "";
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $ap = $a;
  if ($bad0+$bad1>0){
    $tmp .= ";$a";
  }else{
    $tmp .= ";$A";
  }
  if (!($lines%100000000)){
    $doDump = 1;
  }
}

$tmp =~ s/^;//;
large ($tmp, $ap);
dumpData ();

sub large {
  my ($bs, $ap) = @_;
  if (length ($bs) > 10000000*20){
    my $apH = sprintf "%.8x", sHashV ($ap);
    print STDERR "too large for $ap $apH: ".(length($bs))."\n";
    open A, "|gzip > $fname.large.$apH";
    print A "$ap\n";
    print A $bs;
    close (A);
  }else{
    $c2p1{$ap} = safeComp($bs);
  }
}

sub dumpData {
  while (my ($c, $v) = each %c2p1){
    $c2p{$c} = $v;
  }
  %c2p1 = ();         
}

untie %c2p;

print STDERR "read $lines dumping $nc authors\n";

