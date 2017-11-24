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

$fname = $ARGV[0];
output ($n);

sub output {
  my $n = $_[0];
  open A, '>:raw', "$n"; 
  while (my ($k, $v) = each %b2c1){
    my @shas = sort keys %{$v};
    my $nshas = $#shas+1;
    my $nsha = pack "L", $nshas;
    print A $k;
    print A $nsha;
    print A "".(join '', @shas);
  }
}



