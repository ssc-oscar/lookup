use strict;
use warnings;
use Compress::LZF ();

sub fromHex {
  return pack "H*", $_[0];
}

sub toHex {
	  return unpack "H*", $_[0];
}


open A, "$ARGV[0].idx";
open B, "$ARGV[0].bin";
binmode (B);

while (<A>){
	chop();
	my ($o, $l, $ll, $d, $c) = split (/;/, $_, -1);
	seek (B, $o, 0);
    my $buff;
	my $x = read (B, $buff, $l);
	$buff = safeDecomp ($buff);
	while ($buff =~ s/^(.+?)\0(.{20})//){
		my $n = $1;
		my $h = $2;
		#print "$n\n";
		my $t = substr ($n, 0, 1);
		$n = substr ($n, 1, length($n)-1);
		my $new = "";
		my $old = "";
		if ($t =~ /[crm]/){
		   $new = toHex ($h);
		   if ($t eq "r"){
		     $buff =~ s/^(.+?)\0//;
		     $old = $1;
		   }else{
			 if ($t eq "m"){
		       $buff =~ s/^(.{20})//;
		       $old = toHex ($1);
			 }
		   }
		}else{
		   $old = toHex ($h);
		}
		print "$c;$t;$n;$new;$old\n";
	}
}

sub safeDecomp {
 my ($codeC, @rest) = @_;
 try {
  my $code = Compress::LZF::decompress ($codeC);
  return $code;
 } catch Error with {
  my $ex = shift;
  print STDERR "Error: $ex, for parameters @rest\n";
  return "";
 }
}
