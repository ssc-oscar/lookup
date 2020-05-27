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


my $sec;
my $nsec = 8;
$nsec = $ARGV[1] if defined $ARGV[1];

my (%c2p, %c2p1);
my $lines = 0;
my $f0 = "";

for $sec (0..($nsec -1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = "$ARGV[0]" if $nsec == 1;
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

while (<STDIN>){
  chop();
  $lines ++;
  #if (!($lines%15000000000)){
  #  output ();
  #  %c2p1 = ();
  #}    
  my ($hsha, $f, $p, $b) = split (/\;/, $_);
  my $sha = fromHex ($hsha);
  $f =~ s/;/SEMICOLON/g;
  $f =~ s|^/*||;
  $c2p1{$f}{$sha}++;
  print STDERR "$lines done\n" if (!($lines%100000000));
}

output ();

for $sec (0..($nsec -1)){
  untie %{$c2p{$sec}};
}



sub output { 
  while (my ($k, $v) = each %c2p1){
    my $str = join '', keys %{$v};
    my $sec = (unpack "C", substr ($k, 0, 1))%$nsec;
    $c2p{$sec}{$k} = $str;
  }
}


