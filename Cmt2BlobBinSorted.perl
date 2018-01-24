#!/usr/bin/perl -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 



my (%tmp, %c2p, %c2p1);
my $sec;
my $nsec = 8;
$nsec = $ARGV[1] if defined $ARGV[1];

for $sec (0..($nsec -1)){
  my $fname = "$ARGV[0].$sec.tch";
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

my $lines = 0;
my $f0 = "";
my $cnn = 0;
my $nc = 0;
my $doDump = 0;
my $shap = "";
while (<STDIN>){
  chop();
  $lines ++;
  my ($hsha, $f, $b, $p) = split (/\;/, $_);
  if ($hsha !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }    
  my $sha = fromHex ($hsha);
  if ($b !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
  }
  if ($sha ne $shap && $shap ne ""){
    $sec = (unpack "C", substr ($shap, 0, 1))%$nsec;
    #if (defined $c2p{$sec}{$shap}){
    #  print STDERR "input not sorted at $lines pref $hsha followed by seen ".(toHex($shap)).";$p\n";
    #  exit ();     
    #}
    $nc ++;
    my $ps = join '', sort keys %tmp;
    $c2p1{$sec}{$shap} = $ps;
    %tmp = ();
    if ($doDump){
      dumpData ();
      $doDump = 0;
    }
  }  
  $shap = $sha;
  my $bb = fromHex ($hsha);
  $tmp{$bb}++;
  if (!($lines%500000000)){
    print STDERR "$lines done\n";
    $doDump = 1;
  }
}

my $ps = join '', sort keys %tmp;
$sec = (unpack "C", substr ($shap, 0, 1))%$nsec;
$c2p1{$shap} = $ps;
dumpData ();


sub dumpData {
  for my $s (0..($nsec -1)){
    while (my ($c, $v) = each %{$c2p1{$s}}){
      $c2p{$s}{$c} = $v;
    }
    %{$c2p1{$s}} = ();         
  }
}

for $sec (0..($nsec -1)){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines dumping $nc commits\n";

