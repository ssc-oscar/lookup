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
  my ($hc, $f, $hb, $p) = split (/\;/, $_);
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
    #if (defined $c2p{$sec}{$shap}){
    #  print STDERR "input not sorted at $lines pref $hsha followed by seen ".(toHex($shap)).";$p\n";
    #  exit ();     
    #}
    $nc ++;
    my $bs = join '', sort keys %tmp;
    large ($bs, $cp);
    %tmp = ();
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $cp = $c;
  my $b = fromHex ($hb);
  $tmp{$b}++;
  if (!($lines%50000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}

my $bs = join '', sort keys %tmp;
$sec = (unpack "C", substr ($cp, 0, 1))%$nsec;
large ($bs, $cp);
dumpData ();

sub large {
  my ($bs, $cp) = @_;
  if (length ($psC) > 10000000*20){
    my $cpH = toHex ($cp);
    print STDERR "too large for $cpH: ".(length($bs))."\n";
    open A, ">$fname.large.$cpH";
    print A $bs;
    close (A);
  }else{
    $c2p1{$sec}{$cp} = $bs;
  }
}

sub dumpData {
  for my $s (0..($nsec -1)){
    while (my ($c, $v) = each %{$c2p1{$s}}){
      $c2p{$s}{$c} = $v;
    }
    %{$c2p1{$s}} = ();         
  }
}

for $sec (0..($nsec-1)){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines dumping $nc commits\n";

