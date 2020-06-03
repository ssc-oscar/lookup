#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toHex { 
	return unpack "H*", $_[0]; 
} 
sub fromHex { 
	return pack "H*", $_[0]; 
} 

my (%fhob);
tie %fhob, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,  
	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

sub safeDecomp {
        my ($codeC, $n) = @_;
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex; $n\n";
                return "";
        }
}
my $nline = 0;
while (my ($b, $v) = each %fhob){
  my $bb = fromHex ($b);
  my $buf = length($v)/20;
  my $val = pack 'L', $buf;
  $val .= $bb;
  $val .= $v;
  print "$val";
  $nline ++;
  #last if $nline > 2;
}

untie %fhob;
