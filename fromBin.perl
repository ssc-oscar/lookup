use strict;
use warnings;

my $f = $ARGV[0];
my $klen = 4;
my $vlen = 20;
$klen = $ARGV[1] if defined $ARGV[1];
$vlen = $ARGV[2] if defined $ARGV[2];


open A, "zcat $f.idx|";
open B, "$f.bin";

my $pre = "";
my $buf;
my $line = 0;
while (! eof (A)){
  read (A, $buf, 100);
  $buf = $pre.$buf;
  readValues (30);
  $pre = $buf;
}
if (length ($pre) > 0){
  $buf = $pre;
  readValues (0);
}
sub readValues {
  my $max = $_[0];
  my $tot = length($buf);
  while ($tot > $max){
    my $w = unpack "H".($klen*2), $buf;
    $buf = substr ($buf, $klen);
    my ($off, $n) = unpack "w2", $buf;
    $buf = substr ($buf, length (pack "w", $off) + length (pack "w", $n));
    $tot = length($buf);
    if (0){
      seek (B, $off * $vlen, 0);
      my $val;
      read (B, $val, $n*$vlen);
      my $vv = unpack "H*", $val;
      print "$off;$n;$w;$vv\n";
    }else{
      print "$off;$n;$w\n";
    }
  }
  $pre = $buf;
}
