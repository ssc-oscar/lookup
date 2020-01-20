#!/usr/bin/perl -I  /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl

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
my $cp = "";
my $pt = time();
my $p0 = $pt;

while (<STDIN>){
  chop();
  $lines ++;
  my ($hc, $p) = split (/\;/, $_);
  if ($hc !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $c = fromHex ($hc);
  if ($c ne $cp && $cp ne ""){
    $nc ++;
    $tmp =~ s/^;//;
    large ($tmp, $cp);
    $tmp = "";
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $cp = $c;
  $tmp .=";$p"; 
  if (!($lines%100000000)){
    $pt = time();
    my $diff = $lines*3600/($pt - $p0);
    my $all = (1058016728/$lines) * ($pt - $p0) / 3600;
    print STDERR "$lines done at $pt at $diff / hr, all over $all hrs left ".($all-($pt - $p0)/3600)." hrs\n";
    $doDump = 1;
  }
}

$tmp =~ s/^;//;
large ($tmp, $cp);
dumpData ();

sub large {
  my ($psC, $cp) = @_;
  if (length ($psC) > 1000000*20){
    my $cpH = toHex ($cp);
    print STDERR "too large for $cpH: ".(length($psC))."\n";
    open A, ">$fname.large.$cpH";
    print A $psC;
    close (A);
  }else{
    $c2p1{$cp} = safeComp ($psC);
  } 
}

sub dumpData {
  while (my ($c, $v) = each %c2p1){
    $c2p{$c} = $v;
  }
  %c2p1 = ();
}

untie %c2p;

print STDERR "read $lines dumping $nc commits\n";

