

use strict;
use warnings;
#00000011;11;51700;6823;002882c1e77f74c0601077e7c151bb12a91656cf;libinktomi++/MatcherUtils.cc;14792;7=580f6570;9=a61a9320;10=89ee373b;11=b0886638;

my %w2b;
my $from = "";
$from = $ARGV[0] if defined $ARGV[0];
my $start = 0;
while(<STDIN>){
  chop();
  s/;$//;
  s/;$//;
  my ($n,$s,$o,$siz,$b,$f,$siz1,@w) = split(/;/, $_, -1);
  if ($b eq $from && $start == 0){
    $start++;
    my $now = time();
    print STDERR "REACHED:$now;$b\n";
  }
  next if $from ne "" && $start == 0;
  for my $wi (@w){
    my ($l, $wc) = split(/=/, $wi, -1);
    if (defined $wc && $wc ne ""){
      for my $wci (split(/,/, $wc, -1)){
        print "$wci\;$b\n";
      }
    }
    if ($l =~ /^,/){
      $l =~ s/^,//;
      my @wci = split(/,/, $l, -1);
      if ($#wci >=0){
        $wci[$#wci] = substr($wci[$#wci], 0, 8);
        for my $ww (@wci){
          print "$ww\;$b\n";
        }
      }
    }
  }
}

#while (my ($wc, $bs) = each %w2b){
#  for my $b (sort keys %{$bs}){
#    print "$wc;$b\n";
#  }
#}

