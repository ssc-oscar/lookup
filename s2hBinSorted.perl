#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;


my ($tmp, %c2p, %c2p1);
my $fname = $ARGV[0];
tie %c2p, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
  507377777, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
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
  my ($c, $hb) = split (/\;/, $_);
  if ($c eq ""){ # || defined $badCmt{$hc} || defined $badBlob{$hc}){
    print STDERR "empty project for $hb\n";
    next;
  }    
  if ($hb !~ m|^[0-9a-f]{40}$|){ # these are on the right side: should be ok || defined $badCmt{$hb} || defined $badBlob{$hb}){
    print STDERR "bad b sha:$_\n";
  }
  if ($c ne $cp && $cp ne ""){
    $nc ++;
    large ($tmp, $cp);
    $tmp = "";
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $cp = $c;
  my $b = fromHex ($hb);
  $tmp .= $b;
  if (!($lines%100000000)){
    $pt = time();
    my $diff = $lines*3600/($pt - $p0);
    my $all = (1058016728/$lines) * ($pt - $p0) / 3600;
    print STDERR "$lines done at $pt at $diff / hr, all over $all hrs left ".($all-($pt - $p0)/3600)." hrs\n";
    $doDump = 1;
  }
}

large ($tmp, $cp);
dumpData ();

sub large {
  my ($bs, $cp) = @_;
  if (length ($bs) > 10000000*20){
    my $cpH = sprintf "%.8x", sHashV ($cp);
    print STDERR "too large for $cp $cpH: ".(length($bs))."\n";
    open A, ">$fname.large.$cpH";
    print A "$cp\n";
    print A $bs;
    close (A);
  }else{
    $c2p1{$cp} = $bs;
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

