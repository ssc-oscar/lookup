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
  my $rl = read (FD, $codeC, $ARGV[3]);
  my $code = $codeC;
  if ($s < 2147483647){# longer than that is not compressed
    $code = safeDecomp ($codeC, "$ARGV[2];$ARGV[3]");
  }
  if ($code ne ""){
    my $code = safeDecomp ($codeC, "$ARGV[2];$ARGV[3]");
    my $h = sha1_hex("$type ".length($code)."\000$code");
    print "$h\n$code\n";
  }else{
    seek (FD, $ARGV[2], 0);
    my $rl = read (FD, $codeC, 10000000);
    for my $s (1..10000000){
       my $tmp = substr ($codeC, 0, $s);
       my $code = safeDecomp ($codeC, "$ARGV[2];$ARGV[3]");
       if ($code ne ""){
         my $h = sha1_hex("tag ".length($code)."\000$code");
         print "$h\n$code\n";
         exit();
       }
    }
  } 
#}
sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

