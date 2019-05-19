use warnings;
use strict;

open A, "gunzip -c $ARGV[0]|";
my (@num2f, %isA);
while(<A>){
	chop();
	push @num2f, $_;
        $isA{$#num2f} = 1 if $_ =~ /\@/;
}
close (A);

while (<STDIN>){
  chop();
  my @x = split(/;/, $_, -1);
  if (defined $isA{$x[$#x]}){
    print "$num2f[$x[$#x]];".($#x+1);
    for my $i (0..$#x) { print ";$num2f[$x[$i]]"; }
    print "\n";
  }	
}

