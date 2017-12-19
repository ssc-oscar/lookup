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



my (%c2p, %c2p1);
my $lines = 0;
my $f0 = "";
while (<STDIN>){
  $lines ++;
  if (!($lines%15000000000)){
    output ();
    %c2p1 = ();
  }    
  my ($hsha, $f, $p, $b) = split (/\;/, $_);
  my $sha = fromHex ($hsha);
  $f =~ s/;/SEMICOLON/g;
  $c2p1{$sha}{$f}++;
  print STDERR "$lines done\n" if (!($lines%100000000));
}

tie %c2p, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";
output ();
untie %c2p;


sub output { 
  while (my ($k, $v) = each %c2p1){
    my $str = join ';', keys %{$v};
    $c2p{$k} = safeComp ($str);
  }
}


