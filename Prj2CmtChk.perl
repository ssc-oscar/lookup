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

my %p2c;
#tie %p2c, "TokyoCabinet::HDB", "project_commit.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
#        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
#     or die "cant open project_commit.tch\n";


my $lines = 0;
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
    my $nread11 = read (A, $buffer, 20*$ns, 0);
    if ($lk == 0 || $nread0 != 2 || $nread1 != 4 || $lk != length($prj) || $nread11 != 20*$ns){
      print STDERR "$nread0;$nread1;$lk;$prj\n";
    }
  }
}  

untie %p2c;






