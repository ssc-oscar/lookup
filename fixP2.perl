#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

my $off = 0;
$off = $ARGV[0] if defined $ARGV[0];
while (<STDIN>){
  chop();
  my @x = split(/;/, $_, -1);
  my ($h, @y) = split(/_/, $x[$off], -1);
  if ($h =~ /^(dr|bb|gl|git.kernel.org)$/){
   if ($h eq "dr"){
    $h = "git.drupalcode.org";
   }
   if ($h eq "bb"){
    $h = "bitbucket.org";
   }
   if ($h eq "bb"){
    $h = "gitlab.com";
   }
   if ($h eq "git.kernel.org"){
     $y[0] =~ s|/|_|;
     $y[0] =~ s|/$||;
     $y[0] =~ s|\.git$||;
   }
  }else{
    $y[0] =~ s|/|_|;
    $y[0] =~ s|/$||;
    $y[0] =~ s|\.git$||;
  }
  $x[$off] = join "_", ($h, @y);
  print "".(join ";", @x)."\n";
}


	#$p =~ s|^git.savannah.gnu.org_git(.*)\.git/|git.savannah.gnu.org$1.git_|;#also change existing ps git.savannah.gnu.org_3dldf.git_ by removing .git_

