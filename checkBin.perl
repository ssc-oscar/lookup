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
                print STDERR "Error: $ex in $msg\n";
                return "";
        }
}
my $sections = 128;

#for my $s (0..($sections-1)){
  my $fname = $ARGV[1];
  open (FD, "$fname.bin") or die "$!";
  binmode(FD);

open A, "tac $fname.idx|";
my $lst = <A>;
my ($nnn, @rest) = split(/;/, $lst, -1);
$lst = $nnn-$ncheck;

  open A, "$fname.idx";
  #my $oback = 0;
  while (<A>){
    chop();
    my @x = split(/\;/);
    my ($o, $l, $s, $hsha, @rest) = @x;
    next if $o < $lst;
    seek (FD, $l, 0) if $lst == $o;
    #$oback -= $s;
    my $sha = fromHex ($hsha);
    my $sec = hex (substr($hsha, 0, 2)) % $sections;
    my $codeC = "";
    #seek (FD, $oback, 2);
    my $rl = read (FD, $codeC, $s);

    #my $off = tell (FD);
    #my @stat = stat "$fname.bin";

    my $msg = "s=$s, hsha=$hsha, o=$o, l=$l sec=$sec";
    my $code = safeDecomp ($codeC, $msg);
    #my $code = $codeC;
    my $len = length ($code);
    #print "$code\n";
    my $hsha1 = sha1_hex ("$type $len\0$code");
    #print "$hsha != $hsha1;$off+$oback+$s != $stat[7];$len == 0;$s;$sec\n" 
    print "$hsha != $hsha1;$len == 0;$s;$sec\n" 
	if $hsha ne $hsha1 || $len == 0;
  }
#}
sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

