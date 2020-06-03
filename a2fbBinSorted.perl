#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;


my ($tmp, %a2b, %a2b1);
my $fname = $ARGV[0];
tie %a2b, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
  507377777, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $fname\n";

my $lines = 0;
my $na = 0;
my $doDump = 0;
my $ap = "";
my $pt = time();
my $p0 = $pt;

while (<STDIN>){
  chop();
  $lines ++;
  my ($a, $hb, $hc) = split (/\;/, $_);
  if ($hb !~ m|^[0-9a-f]{40}$| || $hc !~ m|^[0-9a-f]{40}$|){ # these are on the right side: should be ok || defined $badCmt{$hb} || defined $badBlob{$hb}){
    print STDERR "bad sha:$_\n";
  }
  if ($a ne $ap && $ap ne ""){
    $na ++;
    large ($tmp, $ap);
    $tmp = "";
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $ap = $a;
  my $b = fromHex ($hb);
  my $c = fromHex ($hc);
  $tmp .= $b.$c;
  if (!($lines%100000000)){
    $pt = time();
    my $diff = $lines*3600/($pt - $p0);
    my $all = (1058016728/$lines) * ($pt - $p0) / 3600;
    print STDERR "$lines done at $pt at $diff / hr, all over $all hrs left ".($all-($pt - $p0)/3600)." hrs\n";
    $doDump = 1;
  }
}

large ($tmp, $ap);
dumpData ();

sub large {
  my ($bs, $ap) = @_;
  if (length ($bs) > 10000000*20){
    my $apH = sprintf "%.8x", sHashV ($ap);
    print STDERR "too large for $ap $apH: ".(length($bs))."\n";
    open A, ">$fname.large.$apH";
    print A "$ap\n";
    print A $bs;
    close (A);
  }else{
    $a2b1{$ap} = $bs;
  }
}

sub dumpData {
  while (my ($a, $v) = each %a2b1){
    $a2b{$a} = $v;
  }
  %a2b1 = ();         
}

untie %a2b;

print STDERR "read $lines dumping $na authors\n";

