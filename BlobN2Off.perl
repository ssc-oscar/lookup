#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");

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

my $fbaseo="All.sha1o/sha1.blob_";
my $fbasei ="/data/All.blobs/blob_";

my (%fhoso);
#for my $sec (0 .. ($sections-1)){
my $sec = $ARGV[0];
my $pre = "/fast";
tie %{$fhoso{$sec}}, "TokyoCabinet::HDB", "$pre/${fbaseo}$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $pre/$fbaseo$sec.tch\n";
my $nn = 0;
if ( -f "$fbasei$sec.idx"){
  open A, "tac $fbasei$sec.idx|" or die ($!);
  while (<A>){
    chop ();
    my @x = split (/\;/, $_, -1);
    my $of = $x[1];
    my $len = $x[2];
    my $hash = $x[3];
    if ($#x > 4){
       $hash = $x[4];
    }
    my $h = fromHex ($hash);
    if (defined $fhoso{$sec}{$h}){
       print "done/updated $nn\n";
       last;
    }
    $nn ++;
    $fhoso{$sec}{$h} = pack ("w w", $of, $len);      
  }
}else{
  die "no $fbasei$sec.idx\n";
}
untie %{$fhoso{$sec}} 


