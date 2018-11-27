#!/usr/bin/perl -I /home/audris/lib64/perl5
use strict;
use warnings;
use Error qw(:try);

use Digest::SHA qw (sha1_hex sha1);
use TokyoCabinet;
use Compress::LZF;

my $type = $ARGV[0];
my $ncheck = 1;
$ncheck = $ARGV[2] if defined $ARGV[2];

sub safeDecomp {
        my ($codeC, $msg) = @_;
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                #print STDERR "Error: $ex in $msg\n";
                return "";
        }
}
my $sections = 128;

#for my $s (0..($sections-1)){
  my $fname = $ARGV[1];
  open (FD, "$fname.bin") or die "$!";
  binmode(FD);

  my $codeC = "";
  seek (FD, $ARGV[2], 0);
  my $s = $ARGV[3];
  my $rl = read (FD, $codeC, $s);
  my $code = $codeC;
  if ($s < 2147483647){# longer than that is not compressed
    $code = safeDecomp ($codeC, "$ARGV[2];$s");
  }
  if ($code ne ""){
    my $code = safeDecomp ($codeC, "$ARGV[2];$s");
    my $h = sha1_hex("$type ".length($code)."\000$code");
    if ($type eq "tree"){
      my $hm5 = sha1_hex("$type ".(length($code)+5)."\000$code\000\000\000\000\000");
      my $hm4 = sha1_hex("$type ".(length($code)+4)."\000$code\000\000\000\000");
      my $hm3 = sha1_hex("$type ".(length($code)+3)."\000$code\000\000\000");
      my $hm2 = sha1_hex("$type ".(length($code)+2)."\000$code\000\000");
      #my $hm5 = sha1_hex("$type ".(length($code)+5)."\000$code");
      #my $hm4 = sha1_hex("$type ".(length($code)+4)."\000$code");
      #my $hm3 = sha1_hex("$type ".(length($code)+3)."\000$code");
      #my $hm2 = sha1_hex("$type ".(length($code)+2)."\000$code");
      my $hp1 = sha1_hex("$type ".(length($code)+1)."\000$code\000");
      print "$h;".(length($code)).";$hm5;$hm4;$hm3;$hm2;$hp1\n";
      shTr($code);
    }else{
      print "$h;".(length($code))."\n$code\n";
      my $hm = sha1_hex("$type ".(length($code)-1)."\000".(substr($code, 0,length($code))));
      my $hn = sha1_hex("$type ".(length($code)+1)."\000".$code."\n");
      print "have:$h nonl:$hm nl:$hn\n";
    }
  }else{
    seek (FD, $ARGV[2], 0);
    my $rl = read (FD, $codeC, 10000000);
    for my $s (1..10000000){
       my $tmp = substr ($codeC, 0, $s);
       my $code = safeDecomp ($codeC, "$ARGV[2];$s");
       if ($code ne ""){
         my $h = sha1_hex("tag ".length($code)."\000$code");
         print "$h\n$code\n";
         exit();
       }
    }
  } 
#}

sub shTr {
  my $code = $_[0];
  my $len = length ($code);
  my $treeobj = $code;
  while ($treeobj) {
    if ($treeobj =~ s/^([0-7]+) (.+?)\0(.{20})//s) {
      my ($mode,$name,$bytes) = (oct($1),$2,$3);
      $name =~ s/\n/__NEWLINE__/g;
      printf "%06o;%s;%s\n",
      $mode, #($mode == 040000 ? "tree" : "blob"),
      unpack("H*", $bytes), $name;
    } else {
      die "$0: unexpected tree entry";
    }
  }
}
sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

