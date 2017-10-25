use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my %b2f = ();
my $lines = 0;
my $trees = 0;

my %f2b = ();
my $fbasei ="/data/All.blobs/tree_";


while (<STDIN>){
  chop();
  my $sec = $_;
  print STDERR "doing $sec\n";
  open (FD, "$fbasei$sec.bin") or die "$!";
  binmode(FD);
  if ( -f "$fbasei$sec.idx"){
    open A, "$fbasei$sec.idx" or die ($!);
    while (<A>){
      chop ();
      my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
      my $codeC = "";
      my $rl = read (FD, $codeC, $len);
      $trees ++;
      if ($rl == $len){
        my $to = decompress ($codeC);
        while ($to) {
          $lines ++;
          print STDERR "$lines lines and $trees trees done\n" if (!($lines%100000000));
          if ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
            my ($mode, $name, $bytes) = (oct($1),$2,$3);
            if ($mode == 0100644){
              $f2b{$name}{$bytes}++;
              #print "$name\n";
            }
          }
        }
      }
    }
  }
}


print STDERR "writing\n";
my %out;
tie %out, "TokyoCabinet::HDB", "/fast1/All.sha1c/f2b.tch", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open /fast1/All.sha1c/b2f.tch\n";
while (my ($k, $v) = each %b2f){
  $out{$k} = join ".", sort keys %{$v};
  #my $b = unpack "H*", $k;
  #print "$b\;".(join ".", sort keys %{$v})."\n";
}
untie %out;

