#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use woc;
use Compress::LZF;
use MIME::Base64;

my $sections = 128;
my $sec = 0;
$sec = $ARGV[0]+0 if defined $ARGV[0];
my $fbase="blob_";
my $s = $sec;
open A, "$fbase$s.idx";
open FD, "$fbase$s.bin";
binmode(FD);

while (<A>){
  chop();
  my ($nn, $of, $len, $hash, @a) = split (/\;/, $_, -1);
  $hash = $a[0] if ($#a>=0);
  my $h = fromHex ($hash);
  seek (FD, $of, 0);
  my $codeC = "";
  my $rl = read (FD, $codeC, $len);
  my $code = safeDecomp ($codeC, "$sec;$nn;$of;$hash");
  $code = encode_base64($code);
  $code =~ s/\r/\\r/g; #these should not happen, perhaps check why? 
  $code =~ s/\n//g;
  print "$hash;$code\n";
}

