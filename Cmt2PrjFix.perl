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
sub safeComp {
  my ($codeC, $n) = @_;
  try {
    my $code = compress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex; $n\n";
    return "";
  }
}



my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

my %fix;
while (<STDIN>){
  chop();
  my ($p, $pc) = split (/\;/, $_, -1);
  $fix{$p} = $pc if $p ne $pc;
}

while (my ($p, $v) = each %p2c){
  my $v1 = safeDecomp ($v);
  my @ps = split(/\;/, $v1, -1);  
  my %tmp;
  my $correct = 0; 
  for my $p (@ps){
	 my $p0 = $p;
	 if (defined $fix{$p}){
	   $correct ++;
      $p0 = $fix{$p};
    }
    $tmp{$p0}++;
  }
  if ($correct){
    $v1 = safeComp (join ';', keys %tmp);
    $p2c{$k} = $v1;
  }
}


untie %p2c;


