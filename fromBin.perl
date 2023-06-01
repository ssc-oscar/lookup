use strict;
use warnings;

my $f = $ARGV[0];
my $klen = 4;
my $vlen = 20;
$klen = $ARGV[1] if defined $ARGV[1];
$vlen = $ARGV[2] if defined $ARGV[2];
my $headOnly = 0;
$headOnly = $ARGV[3] if defined $ARGV[3];
my $maxSize = -1;
$maxSize = $ARGV[4] if defined $ARGV[4];
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
    if ($maxSize < 0 || $n < $maxSize){ 
      if (!$headOnly){
        seek (B, $off * $vlen, 0);
        my $val;
        if ($n > 0){
          for my $i (0..($n-1)){
            my $l = read (B, $val, $vlen);
            if ($l == $vlen){
              my $vv = unpack "H*", $val;
              print "$w;$vv\n";
              #print "$w;$vv;$off;$line;$n\n";
            }else{
              print STDERR "no value for $w: $l bytes left\n";
            }
          }
        }      
        #print "$off;$n;$w;$vv\n";
      }else{
        print "$off;$n;$w\n";
      }
    }
    $line++;
  }
  $pre = $buf;
}
