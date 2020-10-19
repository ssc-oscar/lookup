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



my $type=$ARGV[0];
my $depth=$ARGV[1]+0;
my $obj = $ARGV[2];

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
  $cvt="P2c";
}

my $split = 32;
my %dat; 

sub myOpen {
  my ($k, $s) = @_;
  my $ver = "S";
  my $pVer= "R";
  $ver = $pVer if ( -f "/da0_data/basemaps/${k}Full$pVer.$s.tch")
  if (!tie (%dat{$k}{$s}, "TokyoCabinet::HDB", "/da0_data/basemaps/${k}Full$ver.$s.tch",
       TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK)){
      die "tie error for /da0_data/basemaps/${k}Full$ver.$s.tch\n";
    }
  }
}

my %out;
if ($cvt eq ""){
  #get parents/children
  my $c = fromHex ($obj);
  my $s = segB ($c, $split);
  for my %k ("c2cc", "c2pc", "c2ta", "c2P", "c2f"){
	 $dat{$k}{$s} = myOpen ($k);
    $out{$k} = $dat{$k}{$s}{$c};     
  }
}

sub cvt {
  my ($t, $v) = @_;
  my  $res="";
  if ($t eq "h"){
    my $n = length($v)/20;
    for my $i (0..($n-1)){
      $res .= ";" . toHex (substr($v, $i*20, 20));
    }
    $res =~ s/^;//;
  }else{
  }
  $res;
}

for my $k (keys %out){
  my $val = "";
  $val = cvt ("h", $out{$k}) if $k =~ /2(pc|cc|b)$/;
  if ($k = "c2ta"){
	 my ($t, $a) = split (/;/, $out{$k}, -1);
    $val = $a;
  }
  if ($k = "c2P"){
	 $val = safeDecomp($out{$k});
  }
  print "$obj;$k;$val\n";
}


