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

my %c2b;
my $fbase="All.sha1c/commit_";
my $pre = "/fast1";
tie %c2b, "TokyoCabinet::HDB", "$pre/${fbase}blob.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/${fbase}blob.tch\n";



my %c2b1;

#open B, '>:raw', "/data/All.blobs/Cmt2Blob.merge";

my $lines = 0;
procBin ($ARGV[0]);

sub procBin {
  my $fname = $_[0];
  print "processing $fname\n";  
  open A, "gunzip -c $fname|";
  binmode(A); 
  until (eof(A))
  {
    my $buffer;
    my $nread = read (A, $buffer, 4, 0);
    my $n = unpack 'L', $buffer;
    #print "$nread;$n\n";
    $nread = read (A, $buffer, 20, 0);
    my $cmt = $buffer;
    #print "".(toHex ($cmt))."\n";
    my %vs = ();
    for my $i (1..$n){
       $nread = read (A, $buffer, 20, 0);
       my $b = substr ($buffer, 0, 20);
       $c2b1{$cmt}{$b}++;
    }
    $lines ++;
    print STDERR "$lines done\n" if (!($lines%5000000)); 
  }
}  

$lines = 0;
while (<STDIN>){
  chop();
  my ($c, $bb) = split(/\;/, $_, -1);
  my $cmt = fromHex ($c);
  my $b = fromHex ($bb);
  $c2b1{$cmt}{$b}++;
  $lines ++;
  print STDERR "$lines read\n" if (!($lines%5000000));
}

while (my ($k, $v) = each %c2b1){
  my $vv = join "", (sort keys %{$v});
  $c2b{$k} = $vv;
}

untie %c2b;

