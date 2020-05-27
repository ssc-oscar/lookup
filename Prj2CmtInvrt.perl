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



my $nsec = 1;
my $doSec = 0;
if (defined $ARGV[1]){
  $nsec = $ARGV[1]+0;
  $doSec = $ARGV[2]+0;
}
my %c2p;
my $lines = 0;
my $nc = 0;
while (<STDIN>){
  chop();
  my $n = $_;
  my %p2c;
  tie %p2c, "TokyoCabinet::HDB", $n, TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";
  while (my ($prj, $v) = each %p2c){
    $prj =~ s/\;/SEMICOLON/g;
    my $ns = length($v)/20;
    for my $i (0..($ns-1)){
      my $c = substr ($v, 20*$i, 20);
      if ($nsec > 1){
        my $sec = (unpack "C", substr ($c, 0, 1))%$nsec;
        if ($sec == $doSec){
          $nc ++ if !defined $c2p{$c};
          $c2p{$c}{$prj} ++;
        } 
      }else{
        $c2p{$c}{$prj} ++;
        $nc ++ if !defined $c2p{$c};
      }
    } 
    $lines ++;
    print STDERR "$lines done $nc\n" if (!($lines%10000000)); 
    #last if $lines > 100000; 
  }  
  untie %p2c;
}

sub safeComp {
  my $code = $_[0];
  try {
    my $codeC = compress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}

print STDERR "writing $lines\n";
$lines = 0;

outputTC ($ARGV[0]);
#outputBin ($ARGV[1]);


sub outputTC {
  my $n = $_[0];
  my %c2p1;
  tie %c2p1, "TokyoCabinet::HDB", $n, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
     16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $n\n";
  while (my ($c, $v) = each %c2p){
    $lines ++;
    print STDERR "$lines done out of $nc\n" if (!($lines%100000000));
    my $ps = join ';', sort keys %{$v};
    my $psC = safeComp ($ps);
    #my $s = ((unpack "C", substr($c,0,1))%8);
    $c2p1{$c} = $psC;
  }
  untie %c2p1;
}

sub outputBin {
  my $n = $_[0];
  open A, '>:raw', "$n"; 
  while (my ($k, $v) = each %c2p){
    $lines ++;
    print STDERR "$lines done out of $nc\n" if (!($lines%100000000));
    my @ps = sort keys %{$v};
    my $prj = safeComp(join ';', @ps);
    my $lprj = length ($prj);
    my $nprj = pack "L", $lprj;
    print A $k;
    print A $nprj;
    print A $prj;
  }
}



