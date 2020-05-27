#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

while (<STDIN>){
  chop();
  if (s|;https:_/a:a\@|;| || s|;https:_/|;|){
    s|/|_|;s|/|_|;
  }else{ 
    if(s|;([a-z]{2}):|;${1}_|){
      s|;bb_|;bitbucket.org_|;
      s|;gl_|;gitlab.com_|;
      s|;dr_|;git.drupalcode.org_|;
    }else{
      s|;bioc_|;git.bioconductor.org_|;
      s|;kde.org_|;anongit.kde.org_|;
      s|;git.kde.org_|;anongit.kde.org_|;
      s|;sf_|;git.code.sf.net_p_|;
      s|;gl_|;gitlab.com_|;
      s|;bb_|;bitbucket.org_|;
      s|;git.kernel.org_pub_scm[_/]|;git.kernel.org_|;
      s|;git.kernel.org_|;git.kernel.org_pub_scm_|;
      s|;git.postgresql.org_|;git.postgresql.org_git_|;
      s|;a:a.debian.org_|;salsa.debian.org_|;
      s|;git.debian.org_|;salsa.debian.org_|;
      s|;gl_gnome:|;gitlab.gnome.org_|;
      s|;drupal.com_|;git.drupalcode.org_|;
      s|;git.drupal.com_|;git.drupalcode.org_|;
      s|;git.drupal.org_|;git.drupalcode.org_project_|;
      s|;dev\.eclipse.org_org\.eclipse\.|;git.eclipse.org_r_|;
      #s|;git.gnome.org_archive|;gitlab.gnome.org_Archive|;
      s|;git.gnome.org_|;gitlab.gnome.org_|;
    }
  }
  s|/$||;
  s|\.git$||;
  s|/$||;
  print "$_\n";
}


	#$p =~ s|^git.savannah.gnu.org_git(.*)\.git/|git.savannah.gnu.org$1.git_|;#also change existing ps git.savannah.gnu.org_3dldf.git_ by removing .git_

