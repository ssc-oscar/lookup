##drupal.com_ -> dr_ ? sf_7-zip-homepage -> git.code.sf.net_p/7-zip-homepage/code?; double check gl_ folders as gh; _ are wrong in some existing gl projects: gl_BackslashSoft_Framework_Modules_Resolver; android.googlesource.com_device[_/]; kde.org_->anongit.kde.org_; bioc_packages_vsn > git.bioconductor.org_admin/manifest; sf_sauron git.code.sf.net_p/berbox/code; git.eclipse.org_r_actf/org.eclipse.actf.examples.git/ git.eclipse.org_r/actf/org.eclipse.actf.examples.git/

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

