#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use Digest::MD5 qw(md5 md5_hex md5_base64);
use TokyoCabinet;
use Compress::LZF;

my $fname="$ARGV[0]";
my (%clones);
if(!tie(%clones, "TokyoCabinet::HDB", "$fname",
		  TokyoCabinet::HDB::OREADER)){
	print STDERR "tie error for $fname\n";
}

sub safeDecomp {
        my ($codeC, $par)  = @_;
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex in $par\n";
                return "";
        }
}

my $dC1 = 0;
my $uP1 = 1;
my $dC2 = 1;
$dC2 = $ARGV[1] if defined $ARGV[1];

 
my $offset = 0;
while (my ($h, $codeC) = each %clones){
        my $hh = $h;
        $hh = unpack 'H*', $h if $uP1 && length($h) == 20;
        my $code = $codeC;
	$code = safeDecomp ($codeC, "$offset;$hh") if $dC2;
        $code =~ s/\r//g;
        #$code =~ s/\n/NEWLINE/g;
        print "$h;$code\n";
	$offset++;
}
untie %clones;
