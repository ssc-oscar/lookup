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

my %b2c;
tie %b2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

my %b2c1;
my $lines = 0;
while (<STDIN>){
  chop();
  my ($c, $bb) = split(/\;/, $_, -1);
  my $cmt = fromHex ($c);
  my $b = fromHex ($bb);
  $b2c1{$b}{$cmt}++;
  $lines ++;
  print STDERR "$lines read\n" if (!($lines%100000000));
}

output ();

untie %b2c;

sub output {
  while (my ($k, $v) = each %b2c1){
    my @shas = sort keys %{$v};
    my $v1 = join '', @shas;
    $b2c{$k} = $v1;
  }
}


