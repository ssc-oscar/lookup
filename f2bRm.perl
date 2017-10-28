use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my $outN = $ARGV[0];
my %out;
tie %out, "TokyoCabinet::HDB", "$outN.1.tch", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $outN.1.tch\n";

my %in;
tie %in, "TokyoCabinet::HDB", "$outN.tch", TokyoCabinet::HDB::OREADER,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $outN.tch\n";

while (my ($k, $v) = each %in){
  my $lC = length($k);
  my $l = length($v);
  my $v1 = substr($v, 0, 20);
  if ($l > 20){
    if (($l-20)%21){
      print STDERR "wrong length $l;$k\n";
      last;
    }
    for my $i (1..($l-20)/21){
      $v1 .= substr($v, $i*21, 20);
    }
  }
  $out{$k} = $v1;
}
untie %in;
untie %out;

