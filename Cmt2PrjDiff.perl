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


my $split = 1;
$split = $ARGV[2] + 0 if defined $ARGV[2];

my (%p2c, %p2c1);
for my $sec (0..($split-1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if ($split == 1);
  tie %p2c, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
  $fname = "$ARGV[1].$sec.tch";
  $fname = $ARGV[1] if ($split == 1);
  tie %p2c1, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
   while (my ($k, $v) = each %p2c){
     if (defined $p2c1{$k}){
       my $v1 = $p2c1{$k};
       if ($v1 ne $v){
         my %a = ();  
         my %b = ();  
         for my $p (split(/;/, safeDecomp ($v1), -1)){
           $a{$p}++;
         }
         for my $p (split(/;/, safeDecomp ($v), -1)){
           if (!defined $a{$p}){
             $b{$p}++;
           }
         }
         my $dif = join ';', keys %b;
         if ($dif ne ""){
            my $c = toHex ($k);
            print "$c;$dif\n";
         }
       }
     }else{
       my $vD = safeDecomp ($v);
       my $c = toHex ($k);
       print "$c\;$vD\n";
     }
   }
   untie %p2c1;
   untie %p2c;
}




