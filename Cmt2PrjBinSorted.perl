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

sub safeComp {
  my $code = $_[0];
  try {
    my $codeC = compress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}


my (%tmp, %c2p);
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
my $shap = "";
while (<STDIN>){
  chop();
  $lines ++;
  my ($hsha, $f, $b, $p) = split (/\;/, $_);
  if (length ($hsha) != 40){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $sha = fromHex ($hsha);
  $p =~ s/.*github.com_(.*_.*)/$1/;
  $p =~ s/^bitbucket.org_/bb_/;
  $p =~ s/\.git$//;
  $p =~ s|/*$||;
  $p =~ s/\;/SEMICOLON/g;
  $p = "EMPTY" if $p eq "";
  if ($sha ne $shap && $shap ne ""){
    $nc ++;
    my $ps = join ';', sort keys %tmp;
    my $psC = safeComp ($ps);
    $sec = (unpack "C", substr ($shap, 0, 1))%$nsec;
    if (defined $c2p{$sec}{$shap}){
		die "input not sorted at $lines $hsha seen in ".(toHex($shap))."\n";
    }
    $c2p{$sec}{$shap} = $psC;
    %tmp = ();
  }  
  $shap = $sha;
  $tmp{$p}++;
  print STDERR "$lines done\n" if (!($lines%100000000));
}
my $ps = join ';', sort keys %tmp;
my $psC = safeComp ($ps);
$sec = (unpack "C", substr ($shap, 0, 1))%$nsec;
$c2p{$shap} = $psC;

for $sec (0..15){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines dumping $nc commits\n";

