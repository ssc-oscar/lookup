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

my $sections = 128;

my $fbase="All.sha1c/commit_";

my (%fhoa, %fhoa1, %fhoc);
my $pre = "/fast1";
tie %fhoc, "TokyoCabinet::HDB", "$pre/${fbase}author.tch", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/${fbase}author.tch\n";

while (my ($sha, $v) = each %fhoc){
  my ($auth, $cmtr, $ta, $tc) = split (/\;/, $v);
  $fhoa{$auth}.=$sha;
}
untie %fhoc;

print STDERR "read\n";

tie %fhoa1, "TokyoCabinet::HDB", "$pre/All.sha1c/author_commit.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/${fbase}author.tch\n";

while (my ($a, $v) = each %fhoa){
  $fhoa1{$a}=$v;
}
untie %fhoa1;


