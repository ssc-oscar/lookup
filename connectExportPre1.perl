use warnings;
use strict;
use File::Temp qw/ :POSIX /;

print STDERR "starting ".(localtime())."\n";
open A, "|gzip>$ARGV[0].names";
open B, "|gzip>$ARGV[0].versions";
my (%f2num);
my $n = 0;
my $i = 0;
while(<STDIN>){
	chop();
	my ($v0, $v) = split(/\;/, $_, -1);
	if (!defined $f2num{$v0}){
		$f2num{$v0} = $i+0;
		print A "$v0\n";
		$i++;
	}
	if (!defined $f2num{$v}){
		$f2num{$v} = $i+0;
		print A "$v\n";
		$i++;
	}
	print B "$f2num{$v0} $f2num{$v}\n";
	$n ++;
	if (!($n%1000000000)) { print STDERR "$n lines done\n";}
}
print B "".($i-1)." ".($i-1)."\n";#ensure a complete list of vertices

