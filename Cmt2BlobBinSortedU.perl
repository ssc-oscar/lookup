#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5
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
my $fname = "$ARGV[0]";
for $sec (0..($nsec -1)){
  $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if $nsec == 1;
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

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
  if ($hc !~ m|^[0-9a-f]{40}$|){ # || defined $badCmt{$hc} || defined $badBlob{$hc}){
    print STDERR "bad c sha:$_\n";
    next;
  }    
  my $c = fromHex ($hc);

  if ($hb !~ m|^[0-9a-f]{40}$|){ # these are on the right side: should be ok || defined $badCmt{$hb} || defined $badBlob{$hb}){
    print STDERR "bad b sha:$_\n";
  }
  if ($c ne $cp && $cp ne ""){
    $sec = (unpack "C", substr ($cp, 0, 1))%$nsec;
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

$sec = (unpack "C", substr ($cp, 0, 1))%$nsec;
large (\%tmp, $cp);
dumpData ();

sub large {
  my ($bs, $cp) = @_;
  my $len = length (keys %{$bs});
  if ($len > 1000000){
    my $cpH = toHex ($cp);
    print STDERR "too large for $cpH: $len\n";
    open A, ">$fname.large.$cpH";
    my $bsC = join '', sort keys %{$bs};
    print A $bsC;
    close (A);
  }else{
    for my $v (keys %{$bs}){
      $c2p1{$sec}{$cp}{$v}++;
    }
  }
}

sub dumpData {
  for my $s (0..($nsec -1)){
    while (my ($c, $v) = each %{$c2p1{$s}}){
      if (defined $c2p{$s}{$c}){
        my $v1 = $c2p{$s}{$c};
        my $len = length ($v1)/20-1;
        for my $i (0..$len){ $c2p1{$s}{$c}{substr($v1,$i*20,20)}++ }
        my $bsC = join '', sort keys %{$c2p1{$s}{$c}};
      $c2p{$s}{$c} = $bsC;
    }
    %{$c2p1{$s}} = ();
  }
}

for $sec (0..($nsec-1)){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines dumping $nc commits\n";

