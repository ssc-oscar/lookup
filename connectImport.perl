use warnings;
use strict;

open A, "gunzip -c $ARGV[0].names|";
my (@num2f);
while(<A>){
	chop();
	push @num2f, $_;
}
close (A);
open B, "gunzip < $ARGV[0].clones|";

print STDERR "$num2f[376508]\n";

my $cn = "";
my %cluster = ();
while (<B>){
	chop();
	my ($f, $cl) = split(/\;/, $_, -1);
	$f=$f+0;$cl=$cl+0;
	$cluster{$cl}{$f}++;
}

while (my ($k, $v) = each %cluster){
	my %fs = ();
	for my $f (keys %{$v}){
		$fs{$num2f[$f]}++;
	}
	output (\%fs);
}
undef @num2f;

sub output {
	my $cl = $_[0];
	my @fs = sort { length($a) <=> length($b) } (keys %{$cl});
	for my $i (0 .. $#fs){
		print "$fs[$i]\;$fs[0]\n";
	}
}	
