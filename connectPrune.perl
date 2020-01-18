use warnings;
use strict;

print STDERR "starting ".(localtime())."\n";
my (%v);
my $n = 0;
while(<STDIN>){
	chop();
	my (@x) = split(/ /, $_, -1);
	next if $x[0] eq $x[1] || $#x < 1;
	@x = sort @x;
	$v{"@x"}++;
	$n ++;
	if (!($n%1000000000)) { print STDERR "$n lines done\n";}
}
while (my ($k, $val) = each %v){
	print "$k\n";
}

