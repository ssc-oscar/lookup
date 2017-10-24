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
my $fbase="All.sha1c/project_";
my $pre = "/fast1";
tie %p2c, "TokyoCabinet::HDB", "$pre/${fbase}commit.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/${fbase}commit.tch\n";


open B, '>:raw', "/data/play/prj2cmt/Prj2Cmt.merge";

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
    my $nread = read (A, $buffer, 2, 0);
    my $lk = unpack 'S', $buffer;
    my $prj = "EMPTY";
    if ($lk == 0){
      $lk = length($prj);
    }else{
      $nread = read (A, $buffer, $lk, 0); 
      $prj = $buffer;
    }
    $nread = read (A, $buffer, 4, 0);
    my $ns = unpack 'L', $buffer;
    if (defined $p2c{$prj}){
      my $v0 = $p2c{$prj};
      my $l0 = length($v0)/20;
      my $fst = substr ($v0, 0, 20);
      my $lst = substr ($v0, 20*($l0-1), 20);
      my %sa = ();
      my %sb = ();
      for my $i (0..($ns-1)){
         $nread = read (A, $buffer, 20, 0);
         $sa{$buffer}++ if ( ($buffer cmp $fst) < 0);
         $sb{$buffer}++ if ( ($buffer cmp $lst) > 0);
      }
      out ($prj, ((join "", sort keys %sa).$v0.(join "", sort keys %sb)));
    }else{
      $nread = read (A, $buffer, 20*$ns, 0);
      out ($prj, $buffer);
    }
    $lines ++;
    print STDERR "$lines done\n" if (!($lines%5000000)); 
  }
}  

untie %p2c;

sub out {
  my ($k, $v) = @_;
 
  my $l = length($v)/20;
  my $nsha = pack "L", $l;
  my $lp = pack "S", length($k);
  print B $lp;
  print B $k;
  print B $nsha;
  print B $v;
}






