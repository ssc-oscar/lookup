use strict;
use warnings;

# zcat /data/basemaps/gz/aS.s | grep  -Ei 'root|admin' > nadminS  
# grep -Ev '@(live.com|outlook.com|qq.com|users.noreply.github.com|163.com|gmail.com|hotmail.com|yahoo.com|126.com|mail.ru|naver.com|masuit.com|yandex.ru|sina.com|protonmail.com|github.com|icloud.com|oxmail.com|hotmail.fr|me.com|googlemail.com|bit.admin.ch|gmx.de|ukr.net|aliyun.com|yeah.net|syncfusion.com|msn.com|redhat.com|yahoo.fr|web.de|bk.ru|intel.com|foxmail.com|ttimo.net|bitbucket.org|microsoft.com|beetroot.se|ya.ru|ymail.com|yahoo.co.jp|irootech.com|free.fr|windows10.microdone.cn|google.com|live.nl|aol.com|gamil.com|gmai.com|umich.edu|inbox.ru|cisco.com|live.cn|list.ru|gmail|gatech.edu|protonmail.ch|hanmail.net|wp.pl|vip.qq.com|gitlab.com|yahoo.co.in|us.ibm.com|o2.pl|chapman.edu|gmx.net|gladminds.co|utexas.edu|live.fr|laposte.net|in.ibm.com|huawei.com|fpt.edu.vn|yandex.com|yahoo.co.uk|illinois.edu|accenture.com|servicenow.com|njit.edu|epitech.eu|nate.com|tcs.com|mit.edu|cognizant.com|cern.ch|rambler.ru|hotmail.de|wipro.com|gmx.com|colorado.edu|hotmail.it|pearson.com|orange.fr|nyu.edu|hola.org|emc.com|berkeley.edu|abv.bg|uw.edu|ucdavis.edu|rit.edu|quadminds.com|ncsu.edu|mind-roots.com|isoroot.jp|hotmail.es|sap.com|ucsd.edu|yahoo.de|hpe.com|cornell.edu|cn.ibm.com|Gmail.com|usc.edu|sohu.cohcl.com|gmial.com|daum.net|QQ.COM|yahoo.in|ualberta.ca|stanford.edu|riseup.net|dxc.com|grassroots-tech.com|dataroots.io|comcast.net|atlassian.com|vmware.com|tuta.io|tut.by|columbia.edu|vt.edu|zoho.com|infosys.com|rocketmail.com|yahoo.co.id|users.sourceforge.net|hp.com|autorabit.com|atos.net|asu.edu|apiary.io|amazon.com|yahoo.ca|virginia.edu|uniandes.edu.co|ucsc.edu|t-online.de|smu.edu|rediffmail.com|purdue.edu|live.de|khk.ee|kaist.ac.kr|hawk.iit.edu|windowslive.com|upv.edu.mx|somaiya.edu|sjtu.edu.cn|pku.edu.cn|outlook.de|live.jp|libero.it|hotmail.co.jp|gmil.com|esprit.tn|ericsson.com|epam.com|email.arizona.edu|deeproot.in|asciinema.org|36groot.cs.uleth.ca|ynov.com|unal.edu.co|swisscom.com|student.ncut.edu.tw|root9b.com|nvidia.com|my.csun.edu|misena.edu.co|massroots.com|grootan.com|epfl.ch|dell.com|darkstar.example.net|andrew.cmu.edu|winterroot.net|utp.edu.pe|user.noreply.gitee.com|tscc-login1.sdsc.edu|thomsonuk.dnsroot.biz|techmahindra.com|yahoo.it|wisc.edu|ubuntu.com|trinityroots.co.th|talend.com|samsung.com|salesforce.com|rpi.edu|proproots.com|outlook.es|linux.com|jd.com|husky.neu.edu|dataiku.com|yahoo.es|wazuh.com|ucr.edu|ucl.ac.uk|trootech.com|tieto.com|pivotroots.com|openco.ca|nokia.com|mx.buetow.org|mailinator.com|lntinfotech.com|inspur.com|fhhnet.stadt.hamburg.de|dataroot.asia|csc.com|bu.edu|xuexi.cn|vodafone.com|tudelft.nl|tom.com|teogroup.ru|stud.ntnu.no|sk.com|security.4linux.com.br|rootnet.nl|room9pc01.tedu.cn|poli.ufrj.br|pointlook.com|ntu.edu.tw|msn.cn|mng-ads.com|maxmati.pl|mailbox.org|mail.utoronto.ca|iastate.edu|hotmail.nl|hashroot.com|gmal.com|everis.com|disroot.com|cuberoot.in|cosmoroot.co.jp|contoso.com|citrix.com|cin.ufpe.br|byu.edu|bupt.edu.cn|btinternet.com|bar.admin.ch|atguigu.com|agroscope.admin.ch|adobe.com)' nadminS > nadmin2S
#
my %bad;
open A, "cat ncvs2gitS nadmin2S|";
while (<A>){
  chop ();
  $bad{$_}++;
}

#get bots as well?
#zcat /data/basemaps/gz/aS.s | grep --color=auto -Ei '(bot|robot)' > botsS
my %bot;
open A, "cat botsS|";
while (<A>){
  chop ();
  my $f = $_;
  my ($n, $e, $u, $h) = ("", "","", "");
  ($n, $e) = split(/</, $f) if $n =~ /</;
  ($u, $h) = split(/\@/, $e) if $e =~ /@/;
  $bot{$f}++ if $n =~ /\b(bot|robot)\b/ || $e =~ /\b(bot|robot)\b/; 
}


# zcat /data/basemaps/gz/aS.s|perl -ane 'chop();$f=$_;if ($_ =~ m/.*<([^@]+@[^@\.]+\.[^>]+)>/){$e=$1;$e=~s/^\s*//;$e=~s/\s*$//;print "$e;$f\n";}' | lsort 10G -t\; -k1,1 | gzip > /data/basemaps/gz/e2nS.s
# zcat /data/basemaps/gz/a2AQ.s | perl -ane 'chop();($a,$b)=split(/;/); $e="";if ($b =~ m/.*<([^@]+@[^@\.]+\.[^>]+)>/){$e=$1;$e=~s/^\s*//;$e=~s/\s*$//;};$e1="";if ($a =~ m/.*<([^@]+@[^@\.]+\.[^>]+)>/){$e1=$1;$e1=~s/^\s*//;$e1=~s/\s*$//;} print "$e;$e1;$a;$b\n";' | lsort 10G -t\; -k1,1 | gzip > /data/basemaps/gz/e2AQ.s
# zcat /data/basemaps/gz/e2nS.s|perl -e 'while(<STDIN>){($e,$n)=split(/;/);if ($e eq $pe){ print "$e\n"}; $pe=$e}'|uniq -c |gzip > /data/basemaps/gz/e2+S.s
# zcat /data/basemaps/gz/e2+S.s|lsort 1G -rn | sed 's|^\s*||;s| |;|' | perl -ane '($x,$y)=split(/;/);print $y if $x> 10;' > badEmailS
# edit manually (add - in front)!

my %badE;
open A, "badEmailS";
while (<A>){
  chop();
  $badE{$_}++;
}

my %link;
open A, "zcat /data/basemaps/gz/e2+S.s|";
while (<A>){
  chop();
  $link{$_}++ if !defined $badE{$_};
}

my %e2n;
open A, "zcat /data/basemaps/gz/e2nS.s|";
while (<A>){
  chop();
  my ($e, $n) = split (/;/);
  $e2n{$e}{$n}++;
}

my %badR;
open A, "AManyP1000S";
while (<A>){
  chop();
  $bad{$_}++;
}

my %nr2n;
my %n2nr;
open A, "zcat /data/basemaps/gz/e2AQ.s|";
while (<A>){
  chop();
  my ($er, $e, $n, $nr) = split (/;/);
  $nr2n{$nr}{$n}++;
  $n2nr{$nr}{$n}++;
  $badR{$nr} ++ if defined $badE{$e} || defined $badE{$er} || defined  $bad{$n} || defined  $bad{$nr} || defined $bot{$n} || defined $bot{$nr};
  if (defined $e2n{$er}){
    for my $nn (keys %{$e2n{$er}}) { 
      $badR{$nr} ++ if defined  $bad{$nn} || defined $bot{$nn};
      $nr2n{$nr}{$nn}++;
      $n2nr{$nn}{$nr}++;
    }
  }
  if (defined $e2n{$e}){
    for my $nn (keys %{$e2n{$e}}) { 
      $badR{$nr} ++ if defined  $bad{$nn} || defined $bot{$nn};
      $nr2n{$nr}{$nn}++;
      $n2nr{$nn}{$nr}++;
    }
  }
}

my %id;
my %iid;
my $i = 0;
open B, "|gzip > tmp.versions";
for my $n (keys %n2nr){
  if (!defined $id{$n}){
    $id{$n} = $i;
    $iid{$i} = $n;
    $i++;
  }
  for my $t (keys %{$n2nr{$n}}){
    if (!defined $id{$t}){
      $id{$t} = $i;
      $iid{$i} = $t;
      $i++;
    }
    print B "$id{$n} $id{$t}\n"; 
  }
}
close B;
system ("zcat tmp.versions | $ENV{HOME}/bin/connect |gzip > tmp.clones");
open B, "zcat tmp.clones|";
my %cls;
while (<B>){
  chop();
  my ($f, $cl) = split(/\;/, $_, -1);
  $cls{$cl}{$iid{$f}}++;
}

my %final;
for my $cl (keys %cls){
  my @as = sort { return -1 if length($a) < length($b); return 1 if length($a) > length($b); return $a cmp $b; } (keys %{$cls{$cl}});
  for my $t (@as){
    $final{$t} = $as[0];
    $badR{$as[0]}++ if defined $badR{$t};
  }
}

open A, "zcat /data/basemaps/gz/aS.s|";
while (<A>){
  chop();
  my $a = $_;
  my $b = $a;
  $b = $final{$a} if (defined $final{$a});
  my $bad = defined $badR{$a} || defined $badR{$b} ? 1 : 0;
  print "$a;$b;$bad\n";
}
# zcat /data/basemaps/gz/a2AFullS.s| grep ';0$' |cut -d\; -f2 | uniq -c | sed 's|\s*||;s| |;|' | perl -ane 'chop();($n,$f)=split(/\;/);print "$f\n" if $n > 10' > fAs
