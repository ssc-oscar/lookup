

use strict;
use warnings;
#00000011;11;51700;6823;002882c1e77f74c0601077e7c151bb12a91656cf;libinktomi++/MatcherUtils.cc;14792;7=580f6570;9=a61a9320;10=89ee373b;11=b0886638;

#number of lines to inspect for license
#could also use file type for comment detection
my $maxLines = $ARGV[0];

my %w2b;
my $from = 0;
$from = $ARGV[0] if defined $ARGV[0];
my $n = 0;
while(<STDIN>){
  $n++;
  next if $n < $from;
  chop();
  s/;$//;
  s/;$//;
  my ($n,$s,$o,$siz,$b,$f,$siz1,@wa) = split(/;/, $_, -1);
  # do only c/pl/cs/go/rs
  next if $f !~ /\.(go|cs|rs|rlib|rst|pl|PL|pm|pod|perl|pm6|pl6|p6|plx|ph|[Cch]|cpp|hh|cc|hpp|cxx)$/;
  for my $w (@wa){
    next if !defined $w || $w eq "";
    my ($l, $wc) = split(/=/, $w, -1);
    last if $l > $maxLines; 
    my @wci = split(/,/, $wc, -1);
    for my $ww (@wci){
      print "$ww\;$b;$l;$f\n";
    }
  }
}

#while (my ($wc, $bs) = each %w2b){
#  for my $b (sort keys %{$bs}){
#    print "$wc;$b\n";
#  }
#}

