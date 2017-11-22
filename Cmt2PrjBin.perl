use strict;
use warnings;
use Error qw(:try);
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


my (%c2p1);

my $lines = 0;
my $f0 = "";
my $cnn = 0;
while (<STDIN>){
  chop();
  $lines ++;
  my ($hsha, $f, $b, $p) = split (/\;/, $_);
  if (length ($hsha) != 40){
    print STDERR "bad sha:$_\n";
    next;
  }
  my $sha = fromHex ($hsha);
  $p =~ s/^github.com_//;
  $p =~ s/^bitbucket.org_/bb_/;
  $c2p1{$sha}{$p}++;
  print STDERR "$lines done\n" if (!($lines%100000000));
}

print STDERR "$lines dump\n";
output ($ARGV[0]);
print STDERR "$lines done\n";

sub output {
  my $n = $_[0];
  open A, '>:raw', "$n"; 
  while (my ($k, $v) = each %c2p1){
    my @ps = sort keys %{$v};
    my $prj = safeComp(join ';', @ps);
    my $lprj = length ($prj);
    my $nprj = pack "L", $lprj;
    print A $k;
    print A $nprj;
    print A $prj;
  }
}
