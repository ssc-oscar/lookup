use strict;
use warnings;
use Compress::LZF ();
use Digest::SHA qw (sha1_hex sha1);

sub fromHex {
  return pack "H*", $_[0];
}
sub toHex {
  return unpack "H*", $_[0];
}

my $null = "\0" x 20;
my $pc = "";
my $tmp = "";

open A, "tac $ARGV[0].idx|head -1|";
my $str = <A>;
chop($str);
my ($off, $lc, $l, $h, $pc) = split(/;/, $str, -1);

open A, ">>$ARGV[0].idx";
open B, ">>$ARGV[0].bin";
binmode B;

while (<STDIN>){
  chop();
  my ($c, $n, $new, $old) = split (/;/, $_, -1);
  if ($c ne $pc && $pc ne ""){
    out();
	}
  $pc = $c;
  my $type = "m";
  if (! defined $new || $new eq ""){
    $type = "d";
    $new="";
  }else{
    $new = fromHex($new) if $new =~ m/^[0-f]{40}$/;
  }
  if (! defined $old || $old eq ""){
    $type = "c";
    $old = "";
  } else {
    if ($old =~ m/^[0-f]{40}$/){
      $old = fromHex($old);
    }else{
      $type = "r";
      $old =~ s|^/||;
      $old .= "\0";
    }
  }
  $tmp .= "$type$n\0$new$old";
}

out();

sub out {
  my $l = length ($tmp);
  my $tmpC = safeComp ($tmp);
  my $h = sha1_hex ("bdiff $l\0$tmpC");
  my $lc = length($tmpC);
  print A "$off;$lc;$l;$h;$pc\n";
  $off += $lc;
  syswrite B, $tmpC, $lc;
  $tmp = "";
}

sub safeComp {
 my ($code, @rest) = @_;
 try {
  my $len = length($code);
  if ($len >= 2147483647){
    print STDERR "Too large to compress: $len\n";
    return $code;
  }else{
    return Compress::LZF::compress ($code);
  }
 } catch Error with {
  my $ex = shift;
  print STDERR "Error: $ex, for parameters @rest\n";
  return "";
 }
}
