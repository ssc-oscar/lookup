#/usr/bin/perl -I /home/audris/lib64/perl5

use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my $outN = $ARGV[0];
my %out;
tie %out, "TokyoCabinet::HDB", "$outN.tch", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $outN.tch\n";


sub get {
  my ($k, $v, $res) = @_;
  my $l = length($v);
  for my $i (0..($l/20)){
    $res->{substr($v, $i*20, 20)}++;
  }
}

my %in;
my $j  = 0;
while (<STDIN>){
  chop();
  my $fname = $_;
  tie %{$in{$j}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
     16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
  $j++;
}

my %res;
my $lines = 0;
for my $k (0..($j-1)){
  while (my ($k, $v) = each %{$in{$k}}){
    print STDERR "$lines done\n" if (!(($lines++)%100000000));
    get ($k, $v, \%{$res{$k}});
  }
}
print STDERR "writing\n";
$lines = 0;
while (my ($k, $v) = each %res){
  $lines++;
  $out{$k} = join "", sort keys %{$v};  
}
print STDERR "done $lines\n";

untie %out;
for my $k (0..($j-1)){
  untie %{$in{$k}}
}

