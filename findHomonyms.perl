#!/usr/bin/perl

use warnings;
use strict;
use File::Temp qw/ :POSIX /;

my %fix;
open A, "eMap.fix";
while (<A>){
  chop ();
  my ($a, $b) = split (/\;/);
  $fix{$a} = $b;
}

open A, "zcat /data/basemaps/gz/a2AFullS.s|";


my %bad;
#can add some bad authors that are robots/homonyms
my $badAuthHere =  <<'EOT';
greenkeeper[bot] <greenkeeper[bot]@users.noreply.github.com>
dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
plugin-master <plugin-master@b8457f37-d9ea-0310-8a92-e5e31aec5664>
Google Code Exporter <GoogleCodeExporter@users.noreply.github.com>
Gitberg Autoupdater <autoupdate@gitenberg.org>
GitHub Merge Button <merge-button@github.com>
Try Git <try_git@github.com>
Your Name <you@example.com>
dependabot[bot] <dependabot[bot]@users.noreply.github.com>
AUR Archive Bot <arch@carsten-teibes.de>
dependabot-preview[bot] <27856297+dependabot-preview[bot]@users.noreply.github.com>
Administrator <Administrator@MSDN-SPECIAL>
Admin <admin@Mac-Admin.local>
Administrator <admin@local.host>
Admin <admin@Admins-Mac.local>
Administrator <administrator@ubuntu.(none)>
Admin <Admin>
Admin <Admin@Admin-PC>
unknown <Admin@.(none)>
admin <admin@admins-MacBook-Pro.local>
admin <admin@localhost.localdomain>
admin <admin@admindeMacBook-Pro.local>
Admin <admin@Admins-iMac.local>
Administrator <Administrator@EZ-20160505NBWT>
System Administrator <root@MacBook-Pro.local>
John <Admin@MacBook-Pro-de-Jonathan.local>
Administrator <Administrator@10.8.13.34>
Administrator <Administrator@04814963-7c8d-8047-b203-fa5b01f58d43>
Administrator@Win7-SSRS.firstlook.biz <Administrator@Win7-SSRS.firstlook.biz>
20191223许佳瑞 <Administrator@LAPTOP-GRQ3U5DL>
Admin <Admin@cell.afoolishmanifesto.com>
admin <admin@fd780b83-62d3-3348-9527-ae7b76d8b008>
Administrator <Administrator@JQJLJDG6B4V3H09>
Arjun <arjun@admin-pc.(none)>
Administrator <Administrator@MTFIYMKEHEVA516>
AdminCCH <AdminCCH@e7168442-be37-0410-967b-9f791d7eb4bb>
Admin <Admin@10.53.4.105>
Administrator <3179219832@qq.com>
Administrator <Administrator@SKY-20180102IPA>
Administrator <Administrator@admin>
Administrator <Administrator@DESKTOP-099M7FP>
Administrator <Administrator@PC-20171115ONGG>
CC <CC@admins-imac.gateway.2wire.net>
Administrator <Administrator@WIN-2EBN3HI2GQD.mshome.net>
AMP\Administrator <AMP\Administrator>
Administrator <Administrator@MFL-W10>
Charlie Root <admin@qnap1.gtf>
Administrateur <Administrateur@PdevGr1>
AdminSDA <56934035+AdminSDA@users.noreply.github.com>
Pete <Pete@Admin-115.Admin.HMC.Edu>
administrator account <admin@trial.(none)>
Estudiante <Estudiante@Administrador>
Admin <Admin@EDUMAAT>
Administrator <Administrator@Karen-home.lan>
nalexc <admin@Alexandru-Cosmin.local>
admin <admin@052ea56f-2c7b-4468-a1f9-4827c736a277>
Administrator <Administrator@08463949-8d1f-0410-9db9-d90bfe3171f5>
admin <admin@7386e67b-8cb6-4edc-ab8a-68e7d981af2f>
admin <admin@6746d15e-5701-0010-bc0f-d5842b923ef9>
admin <admin@28a56f14-469b-1442-acfb-e68ebda8abd8>
JavaScript <javascript@Admins-iMac-56.local>
Administrator <Administrator@WIN-0M4SNGC067J>
Chuck Wight <admin@chemvantage.org>
Administrator <Administrator@HC186>
root <root@packer-debian-8-amd64.droplet.local>
root <root@host.localdomain>
root <root@bt.foo.org>
root <root@d1stkfactory>
root <root@ubuntu.ubuntu-domain>
root <root@precise32.(none)>
System Administrator <root@MacBook-Pro.local>
root <root@01204a571a0c>
Charlie Root <admin@qnap1.gtf>
Foo-Manroot <Foo-Manroot@users.noreply.github.com>
-root- <-root-@144d983a-16fc-4224-920f-9145b95d40b9>
root <root@b1bfd937ecf1>
root <root@dhcp-10-208.nay.redhat.com>
Charlie <root@NSWall-46.cm2.northshoresoftware.com>
iceroot <zxcyhn@126.com>
hzy <root@hzy.edu>
root <root@abracadabra>
root <root@4e6ba0521b8a>
root <844082183@qq.com>
Canh Bui <1-root@users.noreply.gitlab.bctech.vn>
root <user_1771@mail.ru>
root <root@ip-172-31-47-122.ap-south-1.compute.internal>
root <root@v-db-smoke05.sz.kingdee.net>
CoreOS Admin <core@node1.c.root-talon-161808.internal>
Charlie Root <root@jailtpl.h0m3.lan>
root <root@zion.site>
Root <Root@Root-PC>
Deepa <root@ip-172-31-38-153.us-east-2.compute.internal>
Sony Arpita Das <root@cool1.blr.asicdesigners.com>
Josh <rootlake@gmail.com>
DOCKER <e3gan.root@gmail.com>
Charlie Root <root@esther.strfry.org>
604772006 <604772006@BTP076024.iuser.iroot.adidom.com>
root <root@IAS-askey133.(none)>
System Administrator <root@niceforbear.local>
Abhijeet <asingh@mind-roots.com>
root <root@yintao-centos58.autonavi.com>
root <root@ip-172-31-17-158.us-east-2.compute.internal>
(no author) <(no author)>
Keks <keksobot@users.noreply.github.com>
greenkeeper[bot] <greenkeeper[bot]@users.noreply.github.com>
renovate[bot] <renovate[bot]@users.noreply.github.com>
BuildTools <unconfigured@null.spigotmc.org>
glensc <glen@delfi.ee>
dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
dependabot-preview[bot] <dependabot-preview[bot]@users.noreply.github.com>
tpg <phenomenal@wp.pl>
plugin-master <plugin-master@b8457f37-d9ea-0310-8a92-e5e31aec5664>
Google Code Exporter <GoogleCodeExporter@users.noreply.github.com>
Gitberg Autoupdater <autoupdate@gitenberg.org>
imgbot[bot] <31301654+imgbot[bot]@users.noreply.github.com>
marcnewlin <marc.newlin@gmail.com>
GitHub Merge Button <merge-button@github.com>
Try Git <try_git@github.com>
yong xiao <xinlongsheng@hotmail.com>
renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>
cjxd-bot <cjxd-bot@cloudbees.com>
Raymond Yee (GITenberg) <raymond.yee+GITenberg@gmail.com>
Your Name <you@example.com>
Bitdeli Chef <chef@bitdeli.com>
dependabot[bot] <dependabot[bot]@users.noreply.github.com>
greenkeeper[bot] <23040076+greenkeeper[bot]@users.noreply.github.com>
WPPlugins Bot <wpp@circlus.de>
CppanBot <cppanbot@gmail.com>
openshiftio-launchpad <obsidian-leadership@redhat.com>
AUR Archive Bot <arch@carsten-teibes.de>
codeserver-test1 <58837339+codeserver-test1@users.noreply.github.com>
dependabot-preview[bot] <27856297+dependabot-preview[bot]@users.noreply.github.com>
snyk-test <snyk-test@snyk.io>
Crowdbotics <team@crowdbotics.com>
imgbot[bot] <imgbot[bot]@users.noreply.github.com>
Travis CI User <travis@example.org>
UnofficialJuliaMirrorBot <43731649+UnofficialJuliaMirrorBot@users.noreply.github.com>
Siteleaf <bot@siteleaf.com>
Keks <keksobot@users.noreply.github.com>
JHipster Bot <jhipster-bot@users.noreply.github.com>
greenkeeper[bot] <greenkeeper[bot]@users.noreply.github.com>
renovate[bot] <renovate[bot]@users.noreply.github.com>
regro-cf-autotick-bot <36490558+regro-cf-autotick-bot@users.noreply.github.com>
dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
dependabot-preview[bot] <dependabot-preview[bot]@users.noreply.github.com>
OpenML Bot <openml@data.gitlab.io>
travis4all <travis4all@hmamail.com>
imgbot[bot] <31301654+imgbot[bot]@users.noreply.github.com>
jenkins-x-bot-test <jenkins-x-test@googlegroups.com>
gatsby-cloud[bot] <47222911+gatsby-cloud[bot]@users.noreply.github.com>
renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>
cjxd-bot <cjxd-bot@cloudbees.com>
npmcdn-to-unpkg-bot <npmcdn-to-unpkg-bot@users.noreply.github.com>
Julia TagBot <50554310+JuliaTagBot@users.noreply.github.com>
regro-cf-autotick-bot <circleci@cf-graph.regro.github.com>
Snyk bot <snyk-bot@users.noreply.github.com>
gitbook-bot <ghost@gitbook.com>
cjxd-bot-test <58561319+cjxd-bot-test@users.noreply.github.com>
dependabot[bot] <dependabot[bot]@users.noreply.github.com>
greenkeeper[bot] <23040076+greenkeeper[bot]@users.noreply.github.com>
WPPlugins Bot <wpp@circlus.de>
jenkins-x-bot-test <43237426+jenkins-x-bot-test@users.noreply.github.com>
whitesource-bolt-for-github[bot] <whitesource-bolt-for-github[bot]@users.noreply.github.com>
CppanBot <cppanbot@gmail.com>
github-actions[bot] <41898282+github-actions[bot]@users.noreply.github.com>
DevExpressExampleBot <DevExpressExampleBot@users.noreply.github.com>
AUR Archive Bot <arch@carsten-teibes.de>
travis4all <travis4all@diamon.dz>
dependabot-preview[bot] <27856297+dependabot-preview[bot]@users.noreply.github.com>
OpenMage Import Bot <flyingmana+openmage_bot@googlemail.com>
allcontributors[bot] <46447321+allcontributors[bot]@users.noreply.github.com>
azure-pipelines[bot] <azure-pipelines[bot]@users.noreply.github.com>
Gun.io Whitespace Robot <contact@gun.io>
Crowdbotics <team@crowdbotics.com>
imgbot[bot] <imgbot[bot]@users.noreply.github.com>
Travis CI User <travis@example.org>
JHipster Bot <jhipster-bot@jhipster.tech>
OpenML Bot <openml@datagit.org>
datacamp-content-creator <32279578+datacamp-content-creator@users.noreply.github.com>
BuildTools <unconfigured@null.spigotmc.org>
airpairtestreviewer <rissem+3@gmail.com>
plugin-master <plugin-master@b8457f37-d9ea-0310-8a92-e5e31aec5664>
Google Code Exporter <GoogleCodeExporter@users.noreply.github.com>
testideah2 <52106437+testideah2@users.noreply.github.com>
vagrant <vagrant@precise32.(none)>
Gitberg Autoupdater <autoupdate@gitenberg.org>
GitHub Merge Button <merge-button@github.com>
Try Git <try_git@github.com>
unknown <you@example.com>
IBM Bluemix <IBM Bluemix>
Microsoft Open Source <microsoftopensource@users.noreply.github.com>
BLAST @ Jarvis <blast@jarvis.bit-academy.nl>
Mozilla-GitHub-Standards <48073334+Mozilla-GitHub-Standards@users.noreply.github.com>
Your Name <you@example.com>
Stackbit <projects@stackbit.com>
mergify-test2 <38495008+mergify-test2@users.noreply.github.com>
gruntjs-updater <updater@gruntjs.com>
Your Name <email@example.com>
Bitdeli Chef <chef@bitdeli.com>
The Great Git Migration <tggm@no-reply.drupal.org>
Student <example@example.com>
Gogs <gogs@fake.local>
AWS CodeStar <noreply-awscodestar@amazon.com>
airpairtest <rissem+2@gmail.com>
offlinesite <64900000+offlinesite@users.noreply.github.com>
vagrant <vagrant@precise64.(none)>
openshiftio-launchpad <obsidian-leadership@redhat.com>
John Doe <johndoe@example.com>
per1234 <accounts@perglass.com>
codeserver-test1 <58837339+codeserver-test1@users.noreply.github.com>
gittestCC <38969930+gittestCC@users.noreply.github.com>
waffle-iron <iron@waffle.io>
snyk-test <snyk-test@snyk.io>
Template builder <builder@example.com>
Apache <apache@ip-172-30-4-168.ec2.internal>
Looker Analytics <ae@looker.com>
root <root@qq.com>
git <git>
UID <UID@DESKTOP-DACJOCN>
KOITT <KOITT@KOITT-PC>
None <None>
000 <000@000-PC>
Apple <>
Chris <Chris>
DELL <DELL@DELL-PC>
BackupGGCode <ggcodearchive@yopmail.com>
 <git@goeswhere.com>
AccountTest <Email@login.org>
s <s>
aa <aa>
unknown <Chris@.(none)>
apnan <apnan>
BuildTools <unconfigured@null.spigotmc.org>
DEVELOPER 2 <dev2@gmail.com>
test user <50655408+trostfrox@users.noreply.github.com>
rcc <rcc>
user <>
= <>
Travis CI <>
CT Deploy <jason@waldrip.net>
AWS <noreply-aws@amazon.com>
cmsbuild <>
test <test@qq.com>
system <test@example.com>
test <test@gmail.com>
test <test@localhost.localdomain>
Test <test@test.com>
test <test>
test <test@example.com>
test <test@test.test>
testuser <testuser@example.com>
 <homework@testleaf.com>
admin <admin@example.com>
you@example.com <you@example.com>
root <root@server.example.com>
myitcv <myitcv@example.com>
My Name <myEmail@example.com>
Your Name <email@example.com>
README-bot <readme-bot@example.com>
wtistang <you@example.com>
me <me@example.com>
example <email@example.com>
Student <example@example.com>
Bob Example <oct@zoy.org>
Aluno <you@example.com>
system <test@example.com>
you <you@example.com>
test <test@example.com>
Administrator <user@example.com>
ehmatthes <eric@example.com>
0x0 <nobody@example.org>
repl.it user <replituser@example.com>
DevExpressExampleBot <devexpressexamplebot@gmail.com>
Unknown <unknown@example.com>
your name <you@example.com>
DevExpressExampleBot <DevExpressExampleBot@users.noreply.github.com>
abc <abc@example.com>
Administrator <admin@example.com>
Bob Example <gbs@canishe.com>
Sam Smith <sam@example.com>
root <admin@example.com>
ID Bot <idbot@example.com>
John Doe <johndoe@example.com>
Bob <bob@example.com>
tom1 <tom1@example.com>
badat <you@example.com>
Your <you@example.com>
root <you@example.com>
readme-bot <readme-bot@example.com>
Student User <student@workstation.lab.example.com>
blog-post-bot <blog-post-bot@example.com>
912XSJ <email@example.com>
te builder <builder@example.com>
YourName <you@example.com>
Admin <you@example.com>
tom <tom@example.com>
Anonymous@example.com <cpsievert1@gmail.com>
example <example@example.com>
viduploader <USERNAME@example.com>
github username <you@example.com>
Travis CI User <travis@example.org>
Your Name <your@example.com>
student <you@example.com>
Alex B <>
Derek P <>
hp <hp@PC>
u0 <u0@pc>
aa <aa@aa>
pi <pi@pi>
HP <HP@HP>
Kevin M <>
PC <PC@HP>
Brian K <>
pc <pc@pc>
__ <__@__>
me <me@me>
ss <ss@01>
PC <PC@PC>
je <je@JM>
tt <tt@tt>
ro <ro@ro>
Chris P <>
pc <pc@PC>
HP <HP@PC>
 <y8@ya.ru>
AJ <aj@alt>
it <it@it04>
a <test@com>
Station 5 <>
Alex <alex@>
a <7oi@q.is>
IRA <IRA@hp>
NN <NN@PC15>
HP <HP@USER>
<ds@ds.com>
Kacy Rowe <>
ab <ab@elon>
BT <bt@nemo>
Shuo <shuo@>
dd <xyz@abc>
mh <mh@n1gp>
Circle CI <>
MD <MD@Safu>
user <user@>
tm <tm@tm-6>
rt33 <rt33@>
ru <ru@.com>
JR <ubu@ubu>
tv <tv@also>
tm <tm@Main>
McL <mcl@brm>
i5 <i5@I5-PC>
2J <jj@j2.io>
Tom <xxx@xxx>
<438@nm.ru>
LG <LG@LG-PC>
hp <hp@HP-PC>
dev <dev@dev>
xxx <xxx@xxx>
aa <aa@bb.ru>
om <om@om-PC>
a <123@ya.ru>
Co <co@99.co>
JM <JM@JM-PC>
 <fuz@fuz.su>
[01
 <>
= <>
s <s>
e <l>
* <*>
x <x>
a <a>
S <s>
e <e>
# <#>
#
1 <1>
- <->
p <_>
d <d>
= <=>
jrb <>
mac <>
qin <>
aa <aa>
user <>
no <no>
root <>
Alex <>
Apple <>
admin <>
git <git>
yunser <>
123 <123>
rcc <rcc>
aaa <aaa>
asd <asd>
xxx <xxx>
xgu <xgu>
glastrm <>
1 <1@1-PC>
unknown <>
samson <s>
a <a@a-PC>
heather <>
cvs2git <>
None <None>
BiG <a@a.a>
x <x@x.com>
unknown <=>
a <a@a.com>
Vlad <Vlad>
Alex <Alex>
java <java>
none <none>
null <null>
curt <curt>
test <test>
root <root>
Vivica <Ma>
root <null>
alex <alex>
cmsbuild <>
temp <temp>
pamAdmin <>
Travis CI <>
NAME <EMAIL>
Piski <User>
user <email>
Developer <>
remote-hg <>
Anonymous <>
anonymous <>
name <email>
bpmsAdmin <>
david <david>
johna <johna>
K <k@2052.me>
Chris <Chris>
apnan <apnan>
utp <utp@utp>
kevin <kevin>
kchan <kchan>
hp <hp@hp-PC>
David <David>
Ben <@bcylin>
aluno <aluno>
admin <admin>
Clase <Clase>
 <@localhost>
Admin <Admin>
System <none>
HP <HP@HP-PC>
PC <PC@PC-PC>
mward <mward>
Aluno <Aluno>
<jcs@jcs.org>
pc <pc@pc-PC>
me <me@me.com>
<dsp@php.net>
Sourcery AI <>
Thi <t@thi.im>
alumno <alumno>
travis <travis>
trainee <trainee>
username <email>
root <root@kali>
abc <abc@abc.com>
Apache <apache@ip-172-30-4-106.ec2.internal>
Apache <apache@ip-172-30-4-33.ec2.internal>
App Academy Student <appacademy@Apps-Mac-mini-2.local>
HackMD <no-reply@hackmd.io>
Fedora Release Engineering <rel-eng@lists.fedoraproject.org>
Grunt Updater <gruntjs-updater@vf.io>
Red Hat Developers Launcher <45641108+redhat-developers-launcher@users.noreply.github.com>
codecademydev <codecademydev@users.noreply.github.com>
conda-forge-linter <github-actions@email.com>
dbc-apprentice <apprentice@devbootcamp.com>
pws-garbage <pws.garbage@gmail.com>
saasbook <saasbook@saasbook.(none)>
studio non de jus <56696825+nondejus@users.noreply.github.com>
user <user@user-PC>
www <www@735d13b6-9817-0410-8766-e36946ffe9aa>
<anonymous@github.com>
--global <mail@substack.net>
Amazon GitHub Automation <54958958+amazon-auto@users.noreply.github.com>
Libraryupgrader <5266@e9e9afe9-4712-486d-8885-f54b72dd1951>
NewsTools <github@newstools.co.za>
User <User@User-PC>
YOUR NAME <YOUR@EMAIL.com>
hmrc-web-operations <hmrc-web-operations@digital.hmrc.gov.uk>
hmrc-web-operations <hmrc-web-operations@users.noreply.github.com>
libraryupgrader <tools.libraryupgrader@tools.wmflabs.org>
libraryupgrader <tools.libraryupgrader@tools.wmflabs.org>
tachikoma.io <appservice@tachikoma.io>
--global <mail@substack.net>
AppVeyor <ci@appveyor.com>
Blockchain Help <31084431+blockchainhelp@users.noreply.github.com>
GitHub <noreply@github.com>
GitHub Security Lab <61799930+ghsecuritylab@users.noreply.github.com>
GitHub Teacher <trainingdemos+githubteacher@github.com>
GitSync <git-sync@trilby.media>
Github Security Lab <securitylab@github.com>
John Doe <john@sample.com>
Neon CI <sitter@kde.org>
OpenLocalizationService <olsrv@microsoft.com>
Repository QA checks <repo-qa-checks@gentoo.org>
Repository mirror & CI <repomirrorci@gentoo.org>
Skerlet Project <skerlet@swc.toshiba.co.jp>
Softwarica College Lab <softwarica@softwarica.com>
Spring Operator <spring-operator@users.noreply.github.com>
Squarespace, Inc <noreply@squarespace.com>
Test <testuser@test.com>
USER <USER@USER-PC>
codeserver-service-qa <51758509+codeserver-service-qa@users.noreply.github.com>
dev-tvpage <32312580+dev-tvpage@users.noreply.github.com>
abc <abc@gmail.com>
pc@pc <pc@pc>
EOT

for my $a (split(/\n/, $badAuthHere)){
  $bad{lc($a)} = 1;
}

sub isBad {
  my $nn = $_[0];
  my $lnn = lc($nn);
  return 1 if defined $bad{$lnn};
  if (length($lnn) > 100){
    $bad{$nn}++;
    return 1;
  }
  my ($n, $e) = ("","");
  $n = $lnn;
  if ($lnn =~ /</){
    ($n, $e) = split (/</, $lnn, -1);
    $e =~ s/>.*//;
    $e =~ s/^\s*//; 
    $e =~ s/\s*$//;
  }
  $n =~ s/\s+/ /g; 
  $n =~ s/^ //; 
  $n =~ s/ $//; 
  
  if ($n =~ /no.author|\bbot\b|\brobot\b|\bjenkins\b|\bgerrit\b/){
    $bad{$lnn}++;
    return 1;
  }

  my ($f, $u, $h, $la) = ("", "", "", "");
  if ($n =~ / /){
    my @l;
    ($f, @l) = split (/ /, $n);
    $la = $l[$#l];
  }
  my $fl = length($f);
  my $lal = length($la);
  if ($e =~ /@/){
    ($u, $h) = split(/@/, $e, -1);
  } 
  if ($n =~ /no.author|\bbot\b|\bjenkins\b/ || $u =~ /\bbot\b/){
    $bad{$lnn}++;
    return 1;
  }
  my $le = length($e);
  my $lu = length($u);
  my $minL = $fl > $lal ? $lal : $fl;
  if ($u =~ /nobody|root|admin|noauthor|unknown|someone|no.author/){
    #these appear potentially problematic
    if ($minL <= 3 ||  #no name info
      $n =~ /\btest\b|sync runner|anonymous|developer|system|server|build|user|your.name|work.space|somebody|unknown|admin apple|nobody|travis|root|no.author|admin|gforge|gerrit|configuration|gitlab|devops/ ||
        # Problematic name 
      $h =~ /example.(net|org|com)/  || $h =~ /invalid.invalid|no.domain|dev.null/ #want privacy
      ){
      $bad{$lnn}++;
      return 1;
    }else{
#print STDERR "$nn\n";
    }
  }else{
    if ($e =~ /localhost/ || $le < 5 || $lu < 2){
      if ($fl + $lal < 5 || $n =~ /test|user|nombre|name|travis.ci|vagrant|glitch/ || $e =~ /fake/){
        $bad{$lnn}++;
        return 1;
      }else{
        print STDERR "$nn\n";
      }
    }
  }
  return 0;
}

while(<A>){
  chop();
  my ($nn, $nnr, $bad) = split(/\;/, $_, -1);
  $nnr = $fix{$nnr} if defined $fix{$nnr};
  my $bb = isBad ($nn) || isBad ($nnr);
  print "$nn;$nnr;$bad;$bb\n";
}
