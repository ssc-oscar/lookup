#!/usr/bin/perl -I /home/audris/lib64/perl5
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


my $offset = 0;
while (my ($h, $codeC) = each %clones){
        my $hh = unpack 'H*', $h;
	my $code = safeDecomp ($codeC, "$offset;$hh");
        $code =~ s/\r//g;
        #$code =~ s/\n/NEWLINE/g;
        print "$hh;$code\n";
	$offset++;
}
untie %clones;
