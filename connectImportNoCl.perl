use warnings;
use strict;

open A, "gunzip -c $ARGV[0].names|";
my (@num2f);
while(<A>){
	chop();
  my $n = $_;
	push @num2f, $n;
}
close (A);

my $cn = "";
my %cluster = ();
my $ off = 0;
while (<STDIN>){
	chop();
  $cluster{$_}{$off}++;
  $off++;
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
  my %ps;
  for my $p (keys %{$cl}){
    $ps{$p}++ if $p !~ /^cl[0-9]+$/;
  }
	my @fs = sort { length($a) <=> length($b) } (keys %ps);
	for my $i (0 .. $#fs){
		print "$fs[$i]\;$fs[0]\n";
	}
}	
