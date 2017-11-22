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


my $lines = 0;
my %p2c0;
procBin ($ARGV[0]);

sub procBin {
  my $fname = $_[0];
  print "processing $fname\n";  
  open A, "<$fname";
  binmode(A); 
  until (eof(A))
  {
    my $buffer;
    my $nread0 = read (A, $buffer, 2, 0);
    my $lk = unpack 'S', $buffer;
    my $nread01 = read (A, $buffer, $lk, 0); 
    my $prj = $buffer;
    my $nread1 = read (A, $buffer, 4, 0);
    my $ns = unpack 'L', $buffer;
    #print "$nread0;$nread01;$nread1;$lk\;$prj;$ns";
    for my $i (0..($ns-1)){
      my $nread11 = read (A, $buffer, 20, 0);
      $p2c0{$prj}{$buffer}++;
      #print ";$nread11:".(toHex($buffer));
    }
    #print "\n";
    $lines ++;
    #last if $lines > 2;
    print "read $lines\n" if !($lines%10000000);
  }
  print "read $fname\n";
}  

my %p2c;
tie %p2c, "TokyoCabinet::HDB", "/fast1/All.sha1c/project_commit.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open project_commit.tch\n";

$lines = 0;
while (my ($p, $v) = each %p2c0){
  if (defined $p2c{$p}){
    list ($p, $p2c{$p}, $v);
  }else{
    if (defined $p2c{"github.com_$p"}){
      list ($p, $p2c{"github.com_$p"}, $v);
    }else{
      if (defined $p2c{"gh_$p"}){
        list ($p, $p2c{"gh_$p"}, $v);
      }else{
        print STDERR "$p";
        while (my ($c, $v0) = each %{$v}){
          print STDERR ";".(toHex($c));
        }
        print STDERR "\n";
      }
    }
  }
  $lines ++;
  print "done $lines\n" if !($lines%100000);
}
untie %p2c;


sub list {
  my ($p, $v1, $v) = @_;
  my $ns = length($v1)/20;
  my %tmp = ();
  for my $i (0..($ns-1)){
    my $c = substr ($v1, 20*$i, 20);
    $tmp{$c}++;
  }
  while (my ($c, $v0) = each %{$v}){
    if (!defined $tmp{$c}){
      print STDERR "$p\;".(toHex($c))."\n";
    }
  }
}


