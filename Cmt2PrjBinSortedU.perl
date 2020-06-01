#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;
use cmt;

my (%tmp, %c2p, %c2p1);
my $sec;
my $nsec = 32;
$nsec = $ARGV[1] + 0 if defined $ARGV[1];

my $fname = "$ARGV[0]";
for $sec (0..($nsec -1)){
  $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if $nsec == 1;
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::ONOLCK,   
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
  my ($hc, $f) = split (/\;/, $_);
  if ($hc !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $c = fromHex ($hc);
  if ($c ne $cp && $cp ne ""){
    $sec = (unpack "C", substr ($cp, 0, 1))%$nsec;
    $nc ++;
    #my $ps = join ';', sort keys %tmp;
    #my $psC = safeComp ($ps);
    large (\%tmp, $cp);
    %tmp = ();
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $cp = $c;
  $tmp{$f}++; 
  if (!($lines%100000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}

$sec = (unpack "C", substr ($cp, 0, 1))%$nsec;
large(\%tmp, $cp);
dumpData ();

sub large {
  my ($ps, $cp) = @_;
  my $len = length (keys %{$ps});
  if ($len > 1000000){
    my $cpH = toHex ($cp);
    print STDERR "too large for $cpH: $len\n";
    open A, ">$fname.large.$cpH";
    my $psC = safeComp(join ';', sort keys %{$ps});
    print A $psC;
    close (A);
  }else{
    for my $v (keys %{$ps}){
      $c2p1{$sec}{$cp}{$v}++;
    }
  } 
}

sub dumpData {
  for my $s (0..($nsec -1)){
    while (my ($c, $v) = each %{$c2p1{$s}}){
      my @v1 = ();
      @v1 = split(/;/, safeDecomp ($c2p{$s}{$c}), -1) if defined $c2p{$s}{$c};
      for my $f (@v1){ $c2p1{$s}{$c}{$f} ++; }
      my $psC = safeComp (join ';', sort keys %{$c2p1{$s}{$c}});
      $c2p{$s}{$c} = $psC;
    }
    %{$c2p1{$s}} = ();
  }
}

for $sec (0..($nsec-1)){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines dumping $nc commits\n";

