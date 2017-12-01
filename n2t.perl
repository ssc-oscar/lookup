use strict;
use warnings;
use Compress::LZF;
use TokyoCabinet;
use Time::Local;



my $lines = 0;
my $trees = 0;
my %f2b = ();
my $fbasei ="/data/All.blobs/tree_";
my $outN = $ARGV[0];
$fbasei = $ARGV[1] if defined $ARGV[1];
my $outp = "/fast1/All.sha1c/";
$outp = $ARGV[2] if defined $ARGV[2];

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
        while ($to =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
          $lines ++;
          if (!($lines%100000000)){
            print STDERR "$lines lines and $trees trees done\n";
            #goto DONE;
          }
          my ($mode, $name, $bytes) = (oct($1),$2,$3);
          if ($mode == 040000 && ! defined $f2b{$name}{$bytes}){
            $f2b{$name}{$bytes} = 1;
            #print "$name\n";
          }
        }
      }else{
        print STDERR "problem reading at nn=$nn, of=$of, len=$len, got $rl\n";
        exit (-1);
      }
    }
  }
}

DONE: 

print STDERR "writing\n";
my %out;
tie %out, "TokyoCabinet::HDB", "$outp/n2t$outN.tch", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $outp/n2t$outN.tch\n";

while (my ($k, $v) = each %f2b){
  $out{$k} = join "", sort keys %{$v};
  #my $b = unpack "H*", $k;
  #print "$b\;".(join "", sort keys %{$v})."\n";
}
untie %out;

