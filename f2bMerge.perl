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
for my $k (0..($j-1)){
  while (my ($k, $v) = each %{$in{$k}}){
    get ($k, $v, \%{$res{$k}});
  }
}

while (my ($k, $v) = each %res){
  $out{$k} = join "", sort keys %{$v};  
}

untie %out;
for my $k (0..($j-1)){
  untie %{$in{$k}}
}

