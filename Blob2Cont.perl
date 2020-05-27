#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

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

my $fbase="/lustre/haven/user/audris/All.sha1c/blob_";
my $fbasei ="/lustre/haven/user/audris/All.blobs/blob_";

my (%fhos);
my $sec = $ARGV[0];
{
  my $pre = "/fast1";
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fbase$sec.tch\n";

  open (FD, "$fbasei$sec.bin") or die "$!";
  binmode(FD);
  if ( -f "$fbasei$sec.idx"){
    open A, "$fbasei$sec.idx" or die ($!);
    while (<A>){
      chop ();
      my @x = split (/\;/, $_, -1);
      my $of = $x[1];
      my $len = $x[2];
      my $hash = $x[3];
      if ($#x>4){
        $hash = $x[4]; #hash is on the next column in the beginning
      }
      my $h = fromHex ($hash);

      my $codeC = "";
      #seek (FD, $of, 0);
      my $rl = read (FD, $codeC, $len);
      if (defined $fhos{$sec}{$h}){
        print STDERR "done\n";
        last;
      }
      $fhos{$sec}{$h} = $codeC;      
    }
  }else{
    die "no $fbasei$sec.idx\n";
  }
  untie %{$fhos{$sec}};
}
