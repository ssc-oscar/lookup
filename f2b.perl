use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my %b2f = ();
my $lines = 0;

my $sec = $ARGV[0];
print STDERR "doing $sec\n";

my %f2b = ();
my $fbasei ="/data/All.blobs/tree_";
open (FD, "$fbasei$sec.bin") or die "$!";
binmode(FD);
if ( -f "$fbasei$sec.idx"){
  open A, "$fbasei$sec.idx" or die ($!);
  while (<A>){
    chop ();
    my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
    my $codeC = "";
    my $rl = read (FD, $codeC, $len);
    if ($rl == $len){
      my $to = decompress ($codeC);
      while ($to) {
        $lines ++;
        print STDERR "$lines done\n" if (!($lines%1000000));
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


print STDERR "writing $sec\n";
my %out;
tie %out, "TokyoCabinet::HDB", "/fast1/All.sha1c/f2b$sec.tch", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open /fast1/All.sha1c/b2f.tch\n";
while (my ($k, $v) = each %b2f){
  $out{$k} = $v;
  #my $b = unpack "H*", $k;
  #print "$b\;".(join ".", keys %{$v})."\n";
}
untie %out;

