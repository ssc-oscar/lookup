#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5
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
  if ($hb eq ""){ # these are on the right side: should be ok || defined $badCmt{$hb} || defined $badBlob{$hb}){
    print STDERR "empty file: $c\n";
  }
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
  $tmp .= ";$hb";
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
  my ($bs, $cp) = @_;
  if (length ($bs) > 1000000*20){
    my $cpH = sprintf "%.8x", sHashV ($cp);
    print STDERR "too large for $cp $cpH: ".(length($bs))."\n";
    open A, ">$fname.large.$cpH";
    print A "$cp\n";
    print A $bs;
    close (A);
  }else{
    $c2p1{$cp} = safeComp($bs);
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

