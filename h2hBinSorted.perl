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
  my ($hc, $hb) = split (/\;/, $_);
  if ($hc !~ m|^[0-9a-f]{40}$|){ # || defined $badCmt{$hc} || defined $badBlob{$hc}){
    print STDERR "bad c sha:$_\n";
    next;
  }    
  my $c = fromHex ($hc);
  if ($hb !~ m|^[0-9a-f]{40}$|){ # these are on the right side: should be ok || defined $badCmt{$hb} || defined $badBlob{$hb}){
    print STDERR "bad b sha:$_\n";
  }
  if ($c ne $cp && $cp ne ""){
    $nc ++;
    my $bs = $tmp;
    large ($bs, $cp);
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
#my $dd = time() - $pt;
    $pt = time();
    my $diff = $lines*3600/($pt - $p0);
    my $all = (1058016728/$lines) * ($pt - $p0) / 3600;
    print STDERR "$lines done at $pt at $diff / hr, all over $all hrs left ".($all-($pt - $p0)/3600)." hrs\n";
    $doDump = 1;
  }
}

my $bs = $tmp;
large ($bs, $cp);
dumpData ();

sub large {
  my ($bs, $cp) = @_;
  if (length ($bs) > 1000000*20){
    my $cpH = toHex ($cp);
    print STDERR "too large for $cpH: ".(length($bs))."\n";
    open A, ">$fname.large.$cpH";
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

