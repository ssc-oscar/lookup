use warnings;
use strict;

open A, "gunzip -c $ARGV[0]|";
my (@num2f);
while(<A>){
	chop();
	push @num2f, $_;
}
close (A);

while (<STDIN>){
	chop();
	my ($a, $d) = split(/\;/, $_, -1);
	print "$num2f[$a];$d\n" if $d%2 == 0;
}

