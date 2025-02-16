use warnings;
use strict;
use File::Temp qw/ :POSIX /;

print STDERR "starting ".(localtime())."\n";
#my $tmp = defined $ENV{TMP} ? File::Temp->new(DIR=>$ENV{TMP}) : tmpnam();
my $tmp = $ARGV[0];

open A, "| gzip >$tmp.names";
open B, "| gzip >$tmp.versions";
my (%f2num);
my $i = 0;
while(<STDIN>){
  chop();
  my ($b0, $b1) = split(/\;/, $_, -1);
  for my $a ($b0, $b1){
    if (!defined $f2num{$a}){
      $f2num{$a} = $i+0;
      print A "$a\n";
      $i++;
    }
  }
  print B "$f2num{$b0} $f2num{$b1}\n";
}
undef %f2num;
close B;
close A;
system ("zcat $tmp.versions | $ENV{HOME}/bin/connect | gzip > $tmp.clones");
my @num2f;
open A, "zcat $tmp.names|";
while (<A>){
	chop($_);
	push @num2f, $_;
}

open B, "zcat $tmp.clones|";
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

#once everything works out remove temps
unlink "$tmp.versions";
unlink "$tmp.names";
unlink "$tmp.clones";

sub output {
	my $cl = $_[0];
	my @fs = sort { length($a) <=> length($b) } (keys %{$cl});
	for my $i (0 .. $#fs){
		print "$fs[$i]\;$fs[0]\n";
	}
}	
