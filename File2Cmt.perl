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

my $fbase="All.sha1c/file_";

my (%f2c, %f2c1);
my $pre = "/fast1";

print STDERR "read\n";

tie %f2c, "TokyoCabinet::HDB", "$pre/${fbase}commit.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/${fbase}commit.tch\n";

my $lines = 0;
my $f0 = "";
while (<STDIN>){
  $lines ++;
  if (!($lines%20000000000)){
     output ();
     %f2c1 = ();
  }
  my ($hsha, $f, $p, $b) = split (/\;/, $_);
  my $sha = fromHex ($hsha);
  $f2c1{$f} .= "$sha";
  print STDERR "$lines done\n" if (!($lines%100000000));
}
output();

sub output {
  while (my ($k, $v) = each %f2c1){
    my $str = "";
    $str = "$f2c{$k};" if defined $f2c{$k};
    $f2c{$k} = $str . $v;
  }
}

untie %f2c;


