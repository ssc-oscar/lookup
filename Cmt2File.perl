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

my $sections = 128;

my $fbase="All.sha1c/commit_";

my (%c2p, %c2p1);
my $pre = "/fast1";

print STDERR "read\n";

tie %c2p, "TokyoCabinet::HDB", "$pre/${fbase}file.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/${fbase}file.tch\n";

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
  $c2p1{$sha}{$f}++;
  print STDERR "$lines done\n" if (!($lines%100000000));
}

output ();


sub output { 
  while (my ($k, $v) = each %c2p1){
    my $str = "";
    $str = "$c2p{$k};" if defined $c2p{$k};
    $c2p{$k} = $str . (join ';', keys %{$v});
  }
}

untie %c2p;


