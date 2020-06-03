#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use Compress::LZF;
use TokyoCabinet;

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
sub safeDecomp {
  my $code = $_[0];
  try {
    my $codeC = decompress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}


my (%c2p);
my $sec;
my $nsec = 32;
$nsec = $ARGV[1] + 0 if defined $ARGV[1];

for $sec (0..($nsec -1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if $nsec == 1;
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT |TokyoCabinet::HDB::ONOLCK,   
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $fname\n";
}

my $lines = 0;
my $doDump = 0;
while (<STDIN>){
  chop();
  $lines ++;
  my ($hc, $t, $a) = split (/\;/, $_);
  if ($hc !~ m|^[0-9a-f]{40}$|){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $c = fromHex ($hc);
  $sec = (unpack "C", substr ($c, 0, 1))%$nsec;
  $c2p{$sec}{$c} = "$t;$a";
  if (!($lines%500000000)){
    print STDERR "$lines done\n";
  }
}

for $sec (0..($nsec-1)){
  untie %{$c2p{$sec}};
}

print STDERR "read $lines\n";

