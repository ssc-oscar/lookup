#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
#
use strict;
use warnings;
use Error qw(:try);
use cmt;
use Getopt::Long qw(GetOptions);

use TokyoCabinet;
use Compress::LZF;
my $flat="n"; 
GetOptions('flat=s' => \$flat);

my $cmdl = "@ARGV";

my $type=$ARGV[0];
my $depth=$ARGV[1]+0;

$cmdl =~ s/^$type\s+//;
$cmdl =~ s/^$depth //;

my $obj = $cmdl;

my $cvt="";
if ($type eq "tree"){
  $cvt="t2c";
}
if ($type eq "blob"){
  $cvt="b2c";
}
if ($type eq "a"){
  $cvt="a2c";
}
if ($type eq "p"){
  $cvt="p2c";
}
if ($type eq "P"){
  $cvt="P2c";
}
if ($type eq "f"){
  $cvt="f2c";
}

my $split = 32;
my %dat; 
sub myOpen {
  my ($k, $s) = @_;
  my $ver = "S";
  my $pVer= "R";
  $ver = $pVer if (-f "/da0_data/basemaps/${k}Full$pVer.$s.tch");
  if (!defined $dat{$k}{$s}){
    if (!tie (%{$dat{$k}{$s}}, "TokyoCabinet::HDB", "/da0_data/basemaps/${k}Full$ver.$s.tch",
       TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
      die "tie error for /da0_data/basemaps/${k}Full$ver.$s.tch\n";
    }
  }
}

my %out;
my %center;


my $d = 0;
my %cs;
my %lnk;

if ($cvt eq "t2c" || $cvt eq "b2c"){
  my $t = fromHex ($obj);
  my $s = segB ($t, $split);
  my $k = $cvt;
  my %foundCs;
  myOpen ($k, $s);
  if (defined $dat{$k}{$s}{$t}){
    for my $v (split (/;/, cvt ($k, $dat{$k}{$s}{$t}, -1))){
      $out{$d}{$k}{$obj}{$v}++;
      $lnk{$k}{$obj}{$v}++;
      $foundCs{$v}++;
    }
  }
  for my $c (keys %foundCs){
    getPC ($c);    
  }
}

if ($cvt eq "a2c" || $cvt eq "P2c" || $cvt eq "f2c"){
  my $s = sHash ($obj, $split);
  my $k = $cvt;
  my %foundCs;
  myOpen ($k, $s);
  if (defined $dat{$k}{$s}{$obj}){
    for my $v (split (/;/, cvt ($k, $dat{$k}{$s}{$obj}, -1))){
      $out{$d}{$k}{$obj}{$v}++;
      $lnk{$k}{$obj}{$v}++;
      $foundCs{$v}++;
    }
  }
  for my $c (keys %foundCs){
    getPC ($c);    
  }
}

if ($cvt eq ""){
  #get parents/children
  getPC ($obj);
}


sub getPC {
  my $obj = $_[0];
  my $c = fromHex ($obj);
  $cs{$obj}++;
  my $s = segB ($c, $split);
  for my $k ("c2cc", "c2pc"){
    myOpen ($k, $s);
    if (defined $dat{$k}{$s}{$c}){
      for my $v (split (/;/, cvt ($k, $dat{$k}{$s}{$c}, -1))){
	  	  $out{$d}{$k}{$obj}{$v}++;
        $lnk{$k}{$obj}{$v}++;
        $cs{$v}++;
	   } 
    }
  }
}

$d = 1;
while ($d <= $depth){ 
  for my $k ("c2cc", "c2pc"){
    for my $obj (keys %{$out{$d-1}{$k}}){
      for my $ch (keys %{$out{$d-1}{$k}{$obj}}){
        my $c = fromHex ($ch);
        my $s = segB ($c, $split);
        myOpen ($k, $s);
        for my $ch1 (split (/\;/, cvt ("h", $dat{$k}{$s}{$c}, -1))){
          $out{$d}{$k}{$ch}{$ch1} ++;
          $lnk{$k}{$ch}{$ch1}++;
          $cs{$ch1}++;
        }
      }
    }
  }
  $d += 1;
}

for my $ch (keys %cs){
  my $c = fromHex ($ch);
  my $s = segB ($c, $split);
  for my $k ("c2P", "c2f", "c2ta"){
    myOpen ($k, $s); 
    for my $v (split (/;/, cvt ($k, $dat{$k}{$s}{$c}), -1)){
      $lnk{$k}{$ch}{$v}++;
    }
  }
}

sub cvt {
  my ($k, $v) = @_;
  my $f = "h";
  $f = "cs" if $k =~ /2[Pf]$/;
  $f = "s" if $k =~ /2ta$/;
  my $res="";
  if ($f eq "h"){
    my $n = length($v)/20;
    for my $i (0..($n-1)){
      $res .= ";" . toHex (substr($v, $i*20, 20));
    }
    $res =~ s/^;//;
  }else{
    if ($f eq "cs"){
		$res = safeDecomp($v);
    }else{
		 $res = (split (/;/, $v, -1))[1];
    }
  }
  $res;
}

for my $k (sort keys %lnk){
  for my $c (sort keys %{$lnk{$k}}){
    for my $v (keys %{$lnk{$k}{$c}}){
		  print "$obj;$k;$c;$v\n";
    }
  }
}


