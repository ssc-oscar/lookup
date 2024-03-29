#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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
  print "read $rl bytes: sha1 of content:".(sha1_hex($codeC))."\n";
  print STDERR "$codeC";

  my $code = safeDecomp ($codeC, "$ARGV[2];$ARGV[3]");
  if ($code ne ""){
    my $lc = length($code);
    print "$ARGV[3];$lc;$code;END\n";
  }else{
    seek (FD, $ARGV[2], 0);
    my $rl = read (FD, $codeC, 10000000);
    for my $s (1..10000000){
       my $tmp = substr ($codeC, 0, $s);
       my $code = safeDecomp ($codeC, "$ARGV[2];$ARGV[3]");
       if ($code ne ""){
         print "$ARGV[3];$code\n";
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

