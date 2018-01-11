#!/usr/bin/perl -I /home/audris/lib64/perl5
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

my $preCalc = 0;
$preCalc = $ARGV[1] if defined $ARGV[1];

my (%fhob);
if ($preCalc == 0){
  tie %fhob, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,  
 	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $ARGV[0]\n";
}else{
  for my $seg (0..($preCalc-1)){
    tie %{$fhob{$seg}}, "TokyoCabinet::HDB", "$ARGV[0]$seg.tch", TokyoCabinet::HDB::OREADER,  
 	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $ARGV[0].$seg.tch\n";
  }
}
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

while (<STDIN>){
  chop();
  my $cmt = $_;
  my $bB = fromHex ($cmt);
  my $codeC;
  if ($preCalc){  
    my $sec = hex (substr($cmt, 0, 2)) % $preCalc;
    if (!defined $fhob{$sec}{$bB}){
      print STDERR "no content for $cmt\n";
      next;
    }
    $codeC = $fhob{$sec}{$bB};
  }else{
    if (!defined $fhob{$bB}){
      print STDERR "no content for $cmt\n";
      next;
    }
    $codeC = $fhob{$bB};
  }
  #my $code = safeDecomp ($codeC, $cmt);
  print "$cmt;$codeC\n";
}

untie %fhob;
