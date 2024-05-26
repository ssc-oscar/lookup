#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use Digest::SHA qw (sha1_hex sha1);
use TokyoCabinet;
use Compress::LZF;

my $type = $ARGV[0];

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
  #print STDERR "$codeC";

  my $code = safeDecomp ($codeC, "$ARGV[2];$ARGV[3]");
  if ($code ne ""){
    my $lc = length($code);
    my $csha1 = sha1_hex("$type $lc\0$code");
    #print "$ARGV[3];$lc;$code;END\n";
    print "$ARGV[3];$lc;$csha1\n";
  }else{
    print "".(unpack "b*", (substr ($codeC, 0, 1)))."\n";
    print "".(unpack "b*", (substr ($codeC, 1, 1)))."\n";
    print "".(unpack "b*", (substr ($codeC, 2, 1)))."\n";
    print "".(unpack "b*", (substr ($codeC, 3, 1)))."\n";
    print "".(unpack "b*", (substr ($codeC, 4, 1)))."\n";
    print "".(unpack "b*", (substr ($codeC, 5, 1)))."\n";
    seek (FD, $ARGV[2], 0);
    my $rl = read (FD, $codeC, 1000000);
    for my $s (1..(1000000-$ARGV[3])){
       my $tmp = substr ($codeC, $s, $ARGV[3]);
       my $code = safeDecomp ($tmp, ($ARGV[2]+$s).";$ARGV[3]");
       print STDERR "$s\n" if (!($s %10000));
       if ($code ne ""){
         my $lc = length($code);
         my $csha1 = sha1_hex("$type $lc\0$code");
         print "found at ".($ARGV[2]+$s).";$csha1\n";
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

