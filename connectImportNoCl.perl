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
my $off = 0;
while (<STDIN>){
	chop();
  next if $_ =~ /^$/;
  $cluster{$_}{$off}++;
  $off++;
}
if ($off != $#num2f +1){
  print STDERR "wrong length: $off vs ".($#num2f +1)."\n";
  exit (-1);
}
print STDERR "length: $off\n";
while (my ($k, $v) = each %cluster){
	my %fs = ();
	for my $f (keys %{$v}){
    #print STDERR "$k;$f;$num2f[$f]\n"; 
		$fs{$num2f[$f]}++;
	}
  #print STDERR "$k\n";
	output (\%fs);
}

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
