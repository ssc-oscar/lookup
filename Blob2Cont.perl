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

my $fbase="All.sha1o/blob_";
my $fbasei ="/data/All.blobs/blob_";

my (%fhos);
my $sec = $ARGV[0];
{
  my $pre = "/fast1";
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbase$sec.tch\n";

  open (FD, "$fbasei$sec.bin") or die "$!";
  binmode(FD);
  if ( -f "$fbasei$sec.idx"){
    open A, "tac $fbasei$sec.idx | " or die ($!);
    while (<A>){
      chop ();
      my ($nn, $of, $len, $hash, $h1) = split (/\;/, $_, -1);
      if (length ($hash) !=40){
        $hash = $h1; #hash is on the next column in the beginning
      }
      my $h = fromHex ($hash);

      my $codeC = "";
      seek (FD, $of, 0);
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
