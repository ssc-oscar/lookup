use strict;
use warnings;
use Compress::LZF ();

sub fromHex {
  return pack "H*", $_[0];
}

sub toHex {
  return unpack "H*", $_[0];
}


open B, "$ARGV[0]";
binmode (B);

while (<STDIN>){
  chop();
  my ($o, $l, $ll, $d, $c) = split (/;/, $_, -1);
  seek (B, $o, 0);
  my $buff;
  my $x = read (B, $buff, $l);
  $buff = safeDecomp ($buff);
  #print STDERR "read $x bytes decomp int ".(length($buff))."\n";
  while ($buff =~ s/^(.+?)\0//){
    my $n = $1;
    my $h = "";	
    if (length($buff)>=20){
      $h = substr($buff, 0, 20);
	    $buff = substr($buff, 20, length($buff) - 20);
	  } else {
      print STDERR "no hash: $o;$n\n";
	    exit();
    }
    my $t = substr ($n, 0, 1);
    $n = substr ($n, 1, length($n)-1);
    #print STDERR "$c;$t;$n;".(toHex($h)).";".length($buff)."\n";
    my $new = "";
    my $old = "";
    if ($t =~ /[crm]/){
      $new = toHex ($h);
      if ($t eq "r"){
        $old = $1 if ($buff =~ s/^(.+?)\0//);
      }else{
        if ($t eq "m"){
          if (length($buff) >= 20){
            $old = toHex (substr($buff,0,20));
            $buff = substr($buff,20,length($buff) - 20);
          }else{
            print STDERR "1:$n;$o;$c;".(length($buff))."\n";
            exit ();
          }
        }
      }
    }else{
      $old = toHex ($h);
    }
    print "$c;$t;$n;$new;$old\n";
  }
  if ($buff ne ""){
    print STDERR "$o left ".(length($buff))." bytes\n";
  }
}

sub safeDecomp {
 my ($codeC, @rest) = @_;
 try {
  my $len = length($codeC);
  if ($len >= 2147483647){
	 return $codeC;
  }else{
    return Compress::LZF::decompress ($codeC);
  }
 } catch Error with {
  my $ex = shift;
  print STDERR "Error: $ex, for parameters @rest\n";
  return "";
 }
}
