#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;


my (%tmp, %c2p, %c2p1);
my $fname = "$ARGV[0]";
tie %c2p, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";

my $lines = 0;
my $f0 = "";
my $cnn = 0;
my $nc = 0;
my $doDump = 0;
my $cp = "";
while (<STDIN>){
  chop();
  $lines ++;
  my ($hc, $hb) = split (/\;/, $_);
  if ($hc eq ""){
    print STDERR "empty file :$_\n";
    next;
  }    
  my $c = $hc;

  if ($hb !~ m|^[0-9a-f]{40}$|){ # these are on the right side: should be ok || defined $badCmt{$hb} || defined $badBlob{$hb}){
    print STDERR "bad b sha:$_\n";
  }
  if ($c ne $cp && $cp ne ""){
    $nc ++;
    large (\%tmp, $cp);
    %tmp = ();
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $cp = $c;
  my $b = fromHex ($hb);
  $tmp{$b}++;
  if (!($lines%10000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}

large (\%tmp, $cp);
dumpData ();

sub large {
  my ($bs, $cp) = @_;
  my $len = length (keys %{$bs});
  if ($len > 1000000){
    my $cpH = sHashV ($cp);
    print STDERR "too large for $cpH: $len\n";
    open A, ">$fname.large.$cpH";
    my $bsC = join '', sort keys %{$bs};
    print A $bsC;
    close (A);
  }else{
    for my $v (keys %{$bs}){
      $c2p1{$cp}{$v}++;
    }
  }
}

sub dumpData {
  while (my ($c, $v) = each %c2p1){
    if (defined $c2p{$c}){
      my $v1 = $c2p{$c};
      my $len = length ($v1)/20-1;
      for my $i (0..$len){ $c2p1{$c}{substr($v1,$i*20,20)}++; };
    }
    my $bsC = join '', sort keys %{$c2p1{$c}};
    $c2p{$c} = $bsC;
    %c2p1 = ();
  }
}

untie %c2p;


print STDERR "read $lines dumping $nc files\n";

