#!/usr/bin/perl

use warnings;
use strict;
use File::Temp qw/ :POSIX /;
use woc;

my %fix;
open A, "eMap.fix";
while (<A>){
  chop ();
  my ($a, $b) = split (/\;/);
  $fix{$a} = $b;
}
open A, "zcat /data/basemaps/gz/a2AFullS.s /data/basemaps/gz/a2AFullS.s.ext|";



my %bad;
#can add some bad authors that are robots/homonyms
my $badAuthHere =  <<'EOT';
devops <devops@gmail@com>
venudevops <devops@gmail.com>
9tdevops <devops@gmail.com>
devops <devops@gmail.com>
David <David@David-PC>
Tu Nombre <you@example.com>
vagrant <vagrant@scotchbox>
Instant Contiki <user@instant-contiki.(none)>
Mary <mary.example@rypress.com>
Your Name <youremail@domain.com>
Home <Home@Home-PC>
vagrant <vagrant@ironhack>
training_C2D.02.11 <training_C2D.02.11@accenture.com>
Author Name <email@address.com>
name <you@example.com>
Live session user <ubuntu@ubuntu.(none)>
DataWorks-CI <48289519+DataWorks-CI@users.noreply.github.com>
Travis CI <contact@loicortola.com>
user <user@user>
unknown <Daniel@.(none)>
Training_H2A.03.20 <Training_h2a.03.20@accenture.com>
user <user@user.com>
user1 <user1@user1-PC>
Travis-CI <travis@travis>
I <info@remcotolsma.nl>
ubuntu <ubuntu@ubuntu.(none)>
apple <apple@appledeiMac.local>
apple <apple@apples-MacBook-Pro.local>
Logon Aluno <logonrmlocal@fiap.com.br>
VSC <vscavu@microsoft.com>
Demo User <demouser@MacBook-Air.local>
vagrant <vagrant@vagrant-centos65.vagrantup.com>
iyuto <dev@code-check.io>
devops <devops@gmail.com>  
Azure Pages <donotreply@microsoft.com>
jserv <jserv@0xlab.org>
Automated Version Bump <gh-action-bump-version@users.noreply.github.com>
user <user@ubuntu.(none)>
Mac <mac@Macs-MacBook-Pro.local>
Utilisateur <user@debian.arcahe.ovh>
macbook <macbook@macbooks-MacBook-Pro.local>
Demo User <demouser@MacBook-Pro.local>
javascript-ru <47786167+jsru@users.noreply.github.com>
Apprentice <apprentice@devbootcamp.com>
Alex <alex@Alexs-MacBook-Pro.local>
<anonymous@github.com>
OWASPFoundation <owasp.foundation@owasp.org>
unknown <drdynscript@gmail.com>
Vagrant Default User <vagrant@jessie.vagrantup.com>
Usuario <Usuario@Usuario-PC>
yourusername <your@email.com>
ASUS <ASUS@ASUS-PC>
John Doe <john@doe.org>
Plusieurs textes <email>
pkage <pkage@mit.edu>
Usuario Local <Usuario Local>
source_server <source_server@example.com>
NullDev <NL-Dev@yandex.com>
Alibaba OSS <opensource@alibaba-inc.com>
apple <apple@appledeMacBook-Pro.local>
oscreader <oscreader@OSC>
user <user@debian>
buddy <buddy@buddy.works>
pg <vagrant@packer-debian-7.4-amd64>
User <user@Users-MacBook-Pro.local>
lenovo <lenovo@lenovo-PC>
FIRST_NAME LAST_NAME <MY_NAME@example.com>
pi <pi@raspberrypi>
ubuntu <ubuntu@ubuntu>
mac <mac@macdeMacBook-Pro.local>
Xcode User <xcode@Fasts-MacBook-Pro-2.local>
apple <apple@apples-MacBook-Pro-2.local>
UCloud_Docs <49426641+UCloudDocs@users.noreply.github.com>
student <student@iMac-student.local>
user <user@mail.com>
rails-dev <rails-dev@railsdev-VirtualBox.(none)>
mac <mac@macdeMacBook-Air.local>
MacBook <macbook@MacBook-Pro-MacBook.local>
mac <mac@macs-MacBook-Air.local>
Name <user@example.com>
Server <server@server.com>
info <info@ralfw.de>
student <none@none.com>
unknown <Jason@.(none)>
A Happy User <auser@nothing.none>
codefactor-io <support@codefactor.io>
Travis CI <travis@Traviss-Mac-6.local>
Postman Integration <integration@postman.com>
user <user@DESKTOP-V882PTR>
A U Thor <author@example.com>
unknown <user@.(none)>
acer <acer@boss>
unknown <User@.(none)>
Bj <none@example.com>
- <anybody@ttuwiki.org>
sbx_user1051 <sbx_user1051@169.254.156.1>
Test test (testtest) <noreply@example.com>
bot50 <bot50@users.noreply.github.com>
gituser <git@gituser.com>
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
<>
<@localhost>
<RobotColorChooser>
<chrome-bot@proto-chrome-trusty.c.chromecompute.google.com.internal>
<flobotics@flobotic-robotics.com>
<info@flobotics-robotics.com>
0-day Robot <robot@bytheb.org>
0-day Robot <robot_email>
0day robot <lkp@intel.com>
0day test bot <fengguang.wu@intel.com>
= <geofbot@gmail.com>
= <undecidabot@gmail.com>
A TFLite Support Robot <tflite-support-github-robot@google.com>
A bad IRC bot <shittybot@baileybot.home.chrisswingler.com>
AEcerbot <aecerbot@aecerbot.ca>
Action black fromatter <my-github-actions-bot@example.org>
AdmiralBullBot <>
AkipeTech Bot <contact@akipe.tech>
AlexDaniel-Bot <alex.jakimenko+bot@gmail.com>
Alt-ZeroNet Bot <imachug+altzeronetbot@gmail.com>
AluxesTranslationsBot <AluxesTranslationsBot@users.noreply.github.com>
Anbox Buildbot <buildbot@anbox.io>
ApertiumBot <apertiumbot@projectjj.com>
AstronomBot <44036742+AstronomBot@users.noreply.github.com>
Atomic Bot <atomic-devel@projectatomic.io>
AttoBot <AttoBot@users.noreply.github.com>
AttoBot3 <AttoBot3@users.noreply.github.com>
Aur<C3><A9>lien Chabot <aurelien.chabot.ext@parrot.com>
Auto Update Bot <itay+89bf5c@grudev.com>
AutoBot <professores-github@alura.com.br>
Autonomous Git Pusher <robot@me.me>
Aven Robot <robot@aven.io>
Azure Container Service Bot <acs-bot@microsoft.com>
Azure Kubernetes Service Bot <acs-bot@microsoft.com>
BB <53237365+beacon-bot@users.noreply.github.com>
BFITech Gitbot <git@noop.bfinews.com>
Backport Bot <backport@amazon.com>
Backport Bot <gaiksaya@amazon.com>
Backportbot <backportbot-noreply@rullzer.com>
Balena CI <versionbot@balena.io>
BalterBot <balterbot@users.noreply.github.com>
Baschts Buildbot <baschtdotcom@bascht.com>
Bender <ewe-mergebot@gmail.com>
BigBrotherBot <bigbrotherbot@gmail.com>
Bitbot <bitbot@bitraf.no>
Bot <archlinux-aur-bot@sebastian-schweizer.de>
Bot <bot@gm.com>
BotBot <emery.finkelstein@gmail.com>
BotFaceAPI <Allen.Chung@msseed.idv.tw>
Breezy landing bot <breezy.the.bot@gmail.com>
Build Bot <buildbot@redpointsoftware.com.au>
BuildBot <admin@sp-institute.com>
BuildBot <albot@build.(none)>
BuildBot system user <buildbot@ip-10-144-71-73.ec2.internal>
BuildBot system user <buildbot@springrts.com>
Buildbot <alex@bennee.com>
Buildbot <holoviews@gmail.com>
Buildbot system user <buildbot@ip-10-147-162-155.ec2.internal>
Buildbot system user <buildbot@static.144-76-236-87.clients.your-server.de>
BukkitBot <lukegb@bukkit.org>
Bulk bot11 <test@test.com>
Butter Bot <butter.robotics@gmail.com>
CI Bot <ci@nikscorp.com>
CI Robot <justintwd+robot@gmail.com>
CI bot <support@alertlogic.com>
CI builder <43988651+cibuilderbot@users.noreply.github.com>
CIBot <ci-bot-blackhole@stripe.com>
CMB <tools.commons-maintenance-bot@tools-sgebastion-07.tools.eqiad.wmflabs>
CMPG <cmpg.btabot@microsemi.net>
COMMITBOT(noobob) <buildbot@Fabians-MacBook-Pro.local>
COMMITBOT(noobob) <fabeschan@gmail.com>
CQ Bot <commit-bot@chromium.org>
CQ Bot Account <commit-bot@chromium.org>
CQ bot account <commit-bot@chromium.org>
Calvin Bottoms <Calvin.Bottoms@hcahealthcare.com>
Canonial IS Mergebot <canonical-is-mergebot@canonical.com>
Canonical IS Mergebot <canonical-is-mergebot@canonical.com>
Checklist bot <checklist@inbo.be>
Cherry Pick Bot <c.adhityaa+cherrypickbot@gmail.com>
Cherry Pick Bot <email@example.com>
Cherry-pick Bot <cherrypickbot@codereview.qt-project.org>
Chery Pick Bot <cherry@pick.bot>
Chrome Release Bot (LUCI) <chrome-official-brancher@chops-service-accounts.iam.gserviceaccount.com>
Chrome-bot <chrome-bot@proto-chrome-trusty.c.chromecompute.google.com.internal>
ChromeOS bot <3su6n15k.default@developer.gserviceaccount.com>
Chromium commit bot <commit-bot@chromium.org>
CircleCI Bot <noreply@circleci.com>
CocoaPodsBot <eloy.de.enige+cocoapods.github.bot@gmail.com>
CodeLingo GitHub Bot <hello@codelingo.io>
Codebots Dev <admin@codebots.com>
Colin Walters (bot) <walters+ghbot@verbum.org>
Commit Bot service account <commit-bot@chromium.org>
Commit Queue Bot <af186030@teradata.com>
Commiter Name <subbbotin>
Concourse Deployer <core-services-bot@pivotal.io>
Context Git Mirror Bot <phg@phi-gamma.net>
Covidence Bot <dev+github@covidence.org>
Culture Map Bot <cannawen+culture-map-bot@gmail.com>
Custom GitHub Actions <bot@github.com>
D2LBot <devinfrastructure@d2l.com>
DARPA Robotics Challenge <drc@drc.mit.edu>
DASL Conductor User <daslrobotics@gmail.com>
DNF Bot <yum-devel@lists.baseurl.org>
DPE bot <bot@example.com>
DataBot <data@mysociety.org>
DataRobot Github Bot <daniil@datarobot.com>
Default User <hsr@hsr-ground-robot>
Deploy Bot <johann.thorvaldur+circleci@gmail.com>
DoES Liverpool <does@doorbot.(none)>
Docs deployment bot <noreply@robotty.de>
DottBott <58945949+DottBott@users.noreply.github.com>
EIP Automerge Bot <38047446+eip-automerger@users.noreply.github.com>
EhTagApi-Bot <EhTagApi-Bot>
Ernesto Castellotti (BOT) <mail@ernestocastellotti.it>
Expo GitHub Bot <support+ci@expo.io>
ExtPlug Bot <d@extplug.com>
FIRSTMentor <FIRSTMentor@C001497303.RobotCasserole.home>
FIRSTMentor <FIRSTMentor@FRC8NL2GV1.RobotCasserole.home>
FOLIO Translations Bot <folio+translations@indexdata.com>
FOLIO Translations Bot <peter+lokalise@indexdata.com>
FacuM <root@buildbot.buildbot>
Fafram Bot <you@example.com>
FixReadmeBot <michaelgdimmitt@protonmail.com>
Formatting Bot <actions@github.com>
Freesewing bot <bot@freesewing.org>
FriendlyBot <meeseeksmachine@gmail.com>
Front In Bot <technologies@frontinsampa.com.br>
GCB Sync Bot <235545413903@cloudbuild.gserviceaccount.com>
GStreamer Merge Bot <gitlab-merge-bot@gstreamer-foundation.org>
Genium Merge Bot <genium@here.com>
Gerrit Code Review <gerrit@saffron.studentrobotics.org>
Gerrit Code Review <qabot@criteo.com>
Gfx CR Bot <gfx-cr-bot@intel.com>
Giacomo Nanni Bot <gn.nanni@gmail.com>
Girar Builder robot <girar-builder@altlinux.org>
GitCorp <git-bot@git.corp.anjuke.com>
GitHub <bkehoe@irobot.com>
GitHub Actions <my-github-actions-bot@example.org>
GitHub Actions Bot <github-actions-bot@example.org>
GitHub Actions Bot <github-actions-bot@github.com.com>
GitHub Actions Bot <github-actions-bot@hackforla.org>
GitHub Actions Bot <my-github-actions-bot@example.org>
GitHub Enterprise <github@robot.car>
GitHub Enterprise <github_bot@newrelic.com>
GitHub Enterprise <noreply@mailhost.robotic.dlr.de>
GitLab <gitlab-bot@gitlab.com>
GitStatusBot <gitstat@fallalex.com>
GitSync JMLA Autobot <contact@shmonistrol.fr>
Gitbot <gitbot@code.bfinews.local>
Github Actions Bot <smainklh@gmail.com>
Github Bot <githubbot@swcs.be>
Glass Bot <glassbot@glassbot2.(none)>
God-Update Bot <->
Google Prow Robot <36314766+google-prow-robot@users.noreply.github.com>
HICAP ROBOT <shu.chen@freelancedreams.com>
Hack Reactor Students <timothyquachbot@gmail.com>
HackDF Commit Bot <hackdf@hackmd.io>
HampisBot <bot@hampoelz.net>
Hcsp Bot <49554844+hcsp-bot@users.noreply.github.com>
Helixbot <weblate@lxqt.org>
Helper Bot <helperbot@recidiviz.com>
Helpmebot <helpmebot@blastoise.helpmebot.org.uk>
Henri77-bot <67963523+Henri77-bot@users.noreply.github.com>
Heroku <bot@heroku.com>
Hhvm Bot <hhvm-bot@users.noreply.github.com>
Hoffbot <hoffbot@veniogames.com>
Hubot Service User <hubot@geodev.edina.ac.uk>
IGSTK Topic Stage <kwrobot@kitware.com>
IMA Developer Relations <ima-devrel-github-bot@google.com>
ITK Topic Stage <kwrobot@kitware.com>
ITKApps Topic Stage <kwrobot@kitware.com>
Intelligent Robotics Group <irg@mmcc-xserve1.private>
Intermodalics <intermodalics@pma-robot-containerbot.mech.kuleuven.be>
Istio Auto Merge Robot <30445278+istio-merge-robot@users.noreply.github.com>
Jekyll [automated] <no-reply@connectbot.org>
Jenkins <jenkinsbot@cosium.com>
Jenkins Automation Server <52299539+dataversebot@users.noreply.github.com>
Jenkins Bot <Jenkins@localhost.ru>
Jenkins Bot <jenkins@localhost>
Jenkins Buildbot <jenkins@gromacs.org>
Jenkins Buildbot on bs-gpu01 <jenkins@gromacs.org>
Jenkins CI robot <dev@lebook.com>
Jenkins User <jenkins@rock-robotics.org>
Jon Binney (as buildbot on B) <binney@savioke.com>
JuiceShop Bot <juice-shop@example.org>
Just a bot <36939546+octokit-rest-for-node-v012-bot@users.noreply.github.com>
KUDO CI Robot <53352098+kudo-ci@users.noreply.github.com>
KayonBot <kayonbot@outlook.de>
Kurgan and the Bot <kburton@relaynetwork.com>
Kyma <kyma.bot@sap.com>
LB-VersionBot <lucian.buzzo+versionbot@gmail.com>
LOC2Bot <locomotion.control@gmail.com>
LOC2Bot <locomotioncontrol@gmail.com>
LabShare Build Bot <build@labshare.org>
Linter Bot <noreply@rhythmictech.com>
Magento Cloud Bot <bot@magento.cloud>
Marge <marge-bot@invalid>
Marge <marge-bot@mediamoose.nl>
Marge Bot <eric+marge@anholt.net>
Marge Bot <margebot@rfc1149.net>
Marge Bot Catalyst Samba <samba-dev+marge-bot@catalyst.net.nz>
Marvin <dev+githubbot@wizacha.com>
Material Automation <material-ios-robots@google.com>
Mattias Ronge <renovate[bot]@users.noreply.github.com>
MeeseeksDev[bot] <meeseeksdevbot@jupyter.org>
MeeseeksDev[bot] <meeseeksmachine@gmail.com>
Merge Bot <58161250+rbxts-merge-bot@users.noreply.github.com>
Merge Bot <nobody3@cradlepoint.com>
Mergebot <PAMergebot@gerrit.aospa.co>
MesaTEE Mergebot <52190952+mesatee-mergebot@users.noreply.github.com>
MicroRobot <DarkWizardProgrammer@gmail.com>
MinCiencia GitHub Actions Bot <actions@github.com>
MinervaBots <MinervaBots@MinervaBots-PC>
Miss Islington (bot) <mariatta@pycascades.com>
Mixxx Buildbot <builds@mixxx.org>
Morgan Creekmore gamingrobot@gmail.com <gamingrobot@gmail.com>
MozMEAO Nucleus Bot <61990569+mozilla-nucleus@users.noreply.github.com>
Mr. Jenkins (CiBoT) <cibot@moodle.org>
MrHoloBot <MrHoloBot@users.noreply.github.com>
My GitHub Actions Bot <ci@wyssmann.com>
My GitHub Actions Bot <dpnminh@gmail.com>
My GitHub Actions Bot <my-github-actions-bot@example.org>
My GitHub Actions Bot <tim.and.trallnag+code@gmail.com>
My GitHub Actions Bot <tim.and.trallnag@gmail.com>
My GitHub Actions Bot <tim.schwenke+github@protonmail.ch>
My GitHub Actions Bot <tim.schwenke+trallnag@protonmail.ch>
NOD-bot <hey@nod.st>
NethBot <NethBot@users.noreply.github.com>
Nightingale Bot <geekshadow+ngbot@gmail.com>
Numigi Robot <46463621+numigi-robot@users.noreply.github.com>
OPAE robot <opae_robot@intel.com>
Octokit Bot <hello@dennisokeeffe.com>
OpenInkpot localization robot <l10n-robot@beer.openinkpot.org>
OpenSlide Buildbot <openslide@jackdaw.pub.backtick.net>
Org BOT <itsupport@parx.com>
PBRP-Bot <pitchblackrecovery@gmail.com>
PM Robotix <pmrobotix@pmrobotix.localdomain>
PVVTK Topic Stage <kwrobot@kitware.com>
ParaView Topic Stage <kwrobot@kitware.com>
PentesterWTF build bot <buildkite-agent@pentester.wtf>
Phi Code Quality Bot <AMS21Bot.github@gmail.com>
Phi Code Quality Bot <actions@github.com>
Phi Formatting Bot <actions@github.com>
Platform Bot <platform@commerceguys.com>
Platform bot <platform@commerceguys.com>
PlatformshBot <bot@platformsh>
Plus One Robotics engineering <developers@plusonerobotics.com>
Polymer Format Bot <monapochi@gmail.com>
Postfacto Robot <52755287+postfactobot@users.noreply.github.com>
Potbottom <Potbottom@172.22.88.244>
PrettyGoodBots <xerxesp2p@yahoo.com>
Prombench Bot Junior <prombench@example.com>
Publish Bot <fungos@gmail.com>
Pyokagan Bot <pyokagan+bot@gmail.com>
Qt Bot <torarnv-bot@codereview.qt-project.org>
Qt CI Bot <qt_ci_bot@qt-project.org>
Qt Cherry-pick Bot <cherrypick_bot@qt-project.org>
Qt Cherry-pick Bot <cherrypickbot@codereview.qt-project.org>
Qt Jambi Gerrit Robot <gerrit@qt-jambi.org>
Quadeare (bot) <lacrampe.florian@gmail.com>
RELEASE-BOT <no-reply@five.ai>
RabbitBot <>
RabbitBot <RabbitBot>
RabbitBot <Unknown>
RadiumBot <reddy.pranav89@gmail.com>
RaeyeiBot <>
ReWeb Docs Bot <vsts@fv-az215.ccihesggpfyenidk05vpemeorb.ux.internal.cloudapp.net>
ReWeb Docs Bot <vsts@fv-az215.krn4vwqnsrwepburvmb5tgbduf.ux.internal.cloudapp.net>
Readify Robot <cio@readify.net>
Rebase Bot <formativerebot@users.noreply.github.com>
Rebase Bot <rebase-bot@users.noreply.github.com>
Rebase Button Bot <rebase-button-bot@users.noreply.github.com>
Release Bot <jakub.g.opensource@gmail.com>
Release Bot <release-bot@lafundacion>
Release Bot @GitHub Actions <actions@github.com>
Release notes rebase bot <matma.rex+releasenotesrebasebot@gmail.com>
Renovate Bot <malcolmhire@gmail.com>
Reposync Bot <reposync@gdcproject.org>
Robot <robot@MacBook-Pro-Robot.local>
Robot <robot@eth.wiki>
Robot User <robot@fmb-pc1.fkie.fraunhofer.de>
Robot User <robot@paa-simulator1.fkie.fraunhofer.de>
Robot User <robot@paa-simulator2.fkie.fraunhofer.de>
Robotregent <robotregent@Arkon.(none)>
Robotregent <robotregent@Rechenzentrale.(none)>
Robots2013 <Robots2013@FRC-WIN7>
Rocking Robot <rockbot@forgerock.com>
RooBot <roobot@galtx-centex.org>
RooBot <roobot@gpa-centex.org>
Rui Bot<C3><A3>o <rui.botao@pt.talaris.com>
SMTK Topic Stage <kwrobot@kitware.com>
SPNATI Utilities Bot <11566-spnati.official@users.noreply.gitgud.io>
SRO Bot <sro@soton.ac.uk>
SavageLabs Wiki <wikibot@savagelabs.net>
Schedule Bot <F0><9F><A4><96> <actions@github.com>
Sculpture Bot <rafal.dittwald+sculpturebot@gmail.com>
Seba GitHub Actions Bot <gitbot@gmail.com>
Sebastian Ott sebott@linux.vnet.ibm.com <sebott@linux.vnet.ibm.com>
Sec-eng concourse bot <pcf-security-eng@pivotal.io>
SecurBot PI <genie-securbot@groupes.usherbrooke.ca>
SecurityBot <android-nexus-securitybot@system.gserviceaccount.com>
Seller Bot <ed+sellerbot@roundsphere.com>
Semantic <semantic-release-bot@martynus.net>
Server Team CI Bot <josh.powers+server-team-bot@canonical.com>
Serverlize Bot <hello@serverlize.net>
ShipItBot <master@neotracker.io>
SimpleITK Topic Stage <kwrobot@kitware.com>
Sir Bots A Lot <52049409+botsalot@users.noreply.github.com>
Skia Commit Bot <skia-commit-bot@chromium.org>
SkynetProgrammer <team2550robotics@gmail.com>
Soft Dev Student <softdevstudent@robotics-mba-01.local>
Soft Dev Student <softdevstudent@robotics-mba-02.local>
Soft Dev Student <softdevstudent@robotics-mba-04.local>
SpotBot <6962859+sh-spotbot@users.noreply.github.com>
Squash Bot <noreply@unicode.org>
Squasher Bot <bot@squasher.com>
StyleCI Bot <bot@styleci.io>
StyleCI Bot <nate@vrazo.com>
SuchABot <yuvipanda+suchabot@gmail.com>
Swarm Bot <47243661+bzzbot@users.noreply.github.com>
SymbiYosys Travis Bot <nobody@nowhere.com>
Symbiotic Gitlab CI <robot@symbiotic.coop>
TEMENOS Design Studio Build Bot - I build DS on each Pull Request <dsbot@users.noreply.github.com>
TRW-bot <github-bot@inwr.com>
TSB Roboter <46753495+tsboter@users.noreply.github.com>
TWMC Web <web-bot@twmc.club>
Tanglu GitBot <gitbot@tanglu.org>
Tanuel <semantic-release-bot@martynus.net>
Tarmac Bot <tarmac@launchpad.net>
TbnBot <ops+tbnbot@turbinelabs.io>
Team 3786 <kentridge.robotics@gmail.com>
TensorFlow SyncBot <syncbot@github-syncbot>
Test Bot <krnowak.test.bot@gmail.com>
Test Robot <robot@example.com>
The Breezy Bot <The Breezy Bot>
The Plumber <50238977+systemd-rhel-bot@users.noreply.github.com>
The git bot <announce@freeradius.org>
TheLastGitRobot <email@bender.thelastonecuz [alias]>
TimVideos Robot <robot@timvideos.us>
Timvideos Robot <robot@timvideos.us>
Tokyo Opensource Robotics Kyokai Association Developer <543o@opensource-robotics.tokyo.jp>
Tomoshi IMAMURA <imamura@oregano.robotich.ath.cx>
Tpcc Course Robot <5471827-tpcc-course-robot@users.noreply.gitlab.com>
Transifex Robot <noreply@transifex.net>
Transifex robot <admin-translate@moblin.org>
Transifex robot <admin@l10n.openinkpot.org>
Transifex robot <admin@localhost>
Transifex robot <admin@transifex.net>
Transifex robot <noreply@localhost>
Transifex robot <noreply@transifex.creativecommons.org>
Transifex robot <noreply@transifex.net>
Transifex robot <submitter@transifex.net>
Transifex robot <transifex@musicbrainz.org>
Transifex robot <webmaster@transifex.creativecommons.org>
Travis Bot <no-reply@github.com>
Travis CI <ic3bot@protonmail.com>
Treadmill Bot <treadmill-bot-bot@fb.com>
TubeTK Topic Stage <kwrobot@kitware.com>
TwitchIOManager-Bot <50668292+TwitchIOManager-Bot@users.noreply.github.com>
Tyler Ibbotson-Sindelar <tyler.ibbotson-sindelar@Tylers-MacBook.home>
U-SYMBOTIC\dlassell <dlassell@USWILDLASSELL1.symbotic.corp>
USD from glTF bot <usd_from_gltf-bot@google.com>
Ubuntu CI Bot <>
UltiBot <38208439+UltiBot@users.noreply.github.com>
UltiBot <holgerhrapp+ultibot@gmail.com>
Unify Code <unify.mirror.bot@gmail.com>
Unit8 Bot <info@unit8.co>
Unknown <gyubot@mrbak.net>
Unrealbot@epicgames.com <Unrealbot@epicgames.com>
Update Bot <yann@droneaud.fr>
VBTEST <vb@test.bot>
VES Topic Stage <kwrobot@kitware.com>
VTK Topic Stage <kwrobot@kitware.com>
VersionBot <versionbot+playground@procbots.resin.io>
VersionBot <versionbot@balena.io>
VersionBot <versionbot@procbots.resin.io>
VersionBot <versionbot@resin.io>
VersionBot <versionbot@whaleway.net>
VersionBpt <versionbot@resin.io>
WP-media GitHub Actions Bot <actions@github.com>
WWRobotics <westwoodrobotics@gmail.com>
Wastedbro <wastedbro@tribot.org>
Weblate <noreply@robotbrain.info>
Westwood Robotics <mesawestwoodrobotics@gmail.com>
Wiki <filip.maric@robotics.utias.utoronto.ca>
Wiki <info@nazcabot.io>
Wiki <noreply@wikijs.robotics.com>
Wiki <robot@email.com>
Wiki <rybothecamel@gmail.com>
Wiki <vgsmartrobot@gmail.com>
Wiki <wiki@phenixrobotik.fr>
Wiki.js <wikijs-robot@beanlog.xyz>
WoeBot Team <gezapeti@gmail.com>
WoeBot Team <hiren.ganatra@openxcell.info>
WoeBot Team <nzclaxon@gmail.com>
WoeBot Team <test@test.com>
WoeBot Team <wysockielnok@gmail.com>
YU Buildbot <creator@yuplaygod.com>
Yorkbot <yorkbot@localhost.localdomain>
ZTS testbot <testbot@xenial-slave-15.local>
ZTS testbot <testbot@xenial-slave-3.local>
ZTS testbot <testbot@xenial-slave-6.local>
Zorba Build Bot <chillery+buildbot@lambda.nu>
User:Guoguo12Bot]] <gerritpatchuploader@gmail.com>
_Marge_Bot <margebot@lavasoftware.org>
a bot <bot@jeremy.ca>
a-bot <a-bot@vps16.sdf.org>
ablbot <ablbot@ableton.com>
adeira-github-bot <mrtnzlml+adeira-github-bot@gmail.com>
admin <admin@botting.solutions>
ak <info@aandkrobotics.com>
ak <tabletop@aandkrobotics.com>
akumar-bot <61888473+akumar-bot@users.noreply.github.com>
andrewhampton-kodiak-test[bot] <62164039+andrewhampton-kodiak-test[bot]@users.noreply.github.com>
angular2-google-maps bot <a2gm-bot@sebastian-mueller.net>
apkgbot <apkgbot@users.noreply.github.com>
app <app@templatebotaide-58dd9fdb7d-nfvc4>
arborator-grew-dev[bot] <64906485+arborator-grew-dev[bot]@users.noreply.github.com>
askbot <askbot@openmooc.(none)>
attobot3 <attobot3@users.noreply.github.com>
aui-team Bot[ADM-89581] <aui-team-bot@atlassian.com>
autobot <autobot@dist-git.host.prod.eng.bos.redhat.com>
autocommit-cli <autocommit-cli[bot]@users.noreply.github.com>
autofix <bot@jeremy.ca>
automerge <bot@jeremy.ca>
automerge-dev[bot] <automerge-dev[bot]@users.noreply.github.com>
automerge[bot] <33435461+automerge[bot]@users.noreply.github.com>
automerge[bot] <automerge[bot]@users.noreply.github.com>
autorebase[bot] <autorebase[bot]@users.noreply.github.com>
autumnal-cannibalism[bot] <autumnal-cannibalism[bot]@users.noreply.github.com>
backportbot[bot] <backportbot[bot]@users.noreply.github.com>
balterbot <balterbot@users.noreply.github.com>
baseui-probot-app-workflow[bot] <baseui-probot-app-workflow[bot]@users.noreply.github.com>
belitre-ci-bot <45819035+belitre-ci-bot@users.noreply.github.com>
betanyc-bot <free.stuff@beta.nyc>
bigfootjon-bot <github-bot@jonjanzen.com>
bot <bot@barrett.deleti.net>
bot <bot@espressif.com>
bot <jsmith@pivotal.io>
bot@mtxr <bot@mteixeira.dev>
botadmin <botadmin@zb03-prod-sls.lab.just-ai.com>
botadmin <botadmin@zenbot-prod-spb.just-ai.cloud.i-free.com>
botond.pelyi <botond.pelyi@gmail.com>
bots <bots@zach-laptop.(none)>
botsie <botsie@igor.(none)>
botuser <botuser@efl.so>
boz[bot] <boz[bot]@users.noreply.github.com>
breadbot translation <noreply@github.com>
buildbot <buildbot@anybox.fr>
buildbot <buildbot@buildbot.python.org>
buildbot <buildbot@buildbox02.flumotion-srv.fluendo.lan>
buildbot <buildbot@fedora15.(none)>
buildbot <buildbot@hawk-build-02-centos6.dev.hawkdefense.com>
buildbot <buildbot@review.prelude>
buildbot <buildbot@speedyslave2>
buildbot <buildbot@win7-bb01.oblong.com>
buildbot <buildbot@www.kiwix.org>
bulldozer-iris[bot] <bulldozer-iris[bot]@users.noreply.github.com>
bulldozer[bot] <3338+bulldozer[bot]@users.noreply.github.palantir.build>
caicloud-bot <caicloud-bot@localhost>
capi-bot <cf-capi-eng@pivotal.io>
cbot[bot] <39013173+cbot[bot]@users.noreply.github.com>
cbot[bot] <cbot[bot]@users.noreply.github.com>
centeredgebot[bot] <40278422+centeredgebot[bot]@users.noreply.github.com>
centeredgebot[bot] <centeredgebot[bot]@users.noreply.github.com>
cf-toolsmiths-gocd <cf-toolsmiths+bot@pivotal.io>
cherrypickbot <cherrypickbot@codereview.qt-project.org>
chrome-release-bot@chromium.org <chrome-release-bot@chromium.org>
ci test bot <ben.copeland@linaro.org>
ci-bot <ci-bot@example>
cisco-ai-bot <ciscoaibot@gmail.com>
clarketm-bot <clarketm-bot@localhost>
cmbnuclear Topic Stage <kwrobot@kitware.com>
collabobot-2050[bot] <49749988+collabobot-2050[bot]@users.noreply.github.com>
comments bot <bot@example.com>
commitbot <commitbot@samsung.com>
conventional-merge-oss[bot] <43119821+conventional-merge-oss[bot]@users.noreply.github.com>
conventional-merge-oss[bot] <conventional-merge-oss[bot]@users.noreply.github.com>
conventional-merge[bot] <conventional-merge[bot]@users.noreply.github.com>
conventional-mergebot[bot] <conventional-mergebot[bot]@users.noreply.github.com>
corbot[bot] <39114087+corbot[bot]@users.noreply.github.com>
corbot[bot] <corbot[bot]@users.noreply.github.com>
core-bot <core-bot.noreply@manomano.com>
cpeditor-bot <cpeditor_bot@126.com>
cran-robot <csardi.gabor+cran@gmail.com>
cscbot test <cscbot-test@taurine.csclub.uwaterloo.ca>
csfixer-bot <no-reply@mighty-code.com>
cstl-robot <robot@ibm.com>
daisy-bot <31080392+daisy-bot@users.noreply.github.com>
deploy <bot@jeremy.ca>
derek-vnext[bot] <37505397+derek-vnext[bot]@users.noreply.github.com>
derek-vnext[bot] <derek-vnext[bot]@users.noreply.github.com>
designate-bot <dnsaas@rackspace.com>
devf-merge-bot <45257040+devf-merge-bot@users.noreply.github.com>
devgovnr[bot] <devgovnr[bot]@users.noreply.github.com>
dicebot <dicebot@dicebot-sociomantic.(none)>
dnf-bot <yum-devel@lists.baseurl.org>
docs.cubots Bot <docs.cubots@cubots.wh.hostnation.de>
dotnet-bot <anirudhagnihotry098@gmail.com>
dotnet-bot-corefx-mirror <anirudhagnihotry098@gmail.com>
dotnet-bot-mirror1 <dotnet-bot@microsoft.com>
dotnet-bot-mirror2 <dotnet-bot@microsoft.com>
dott-bott[bot] <51507798+dott-bott[bot]@users.noreply.github.com>
droslean-bot <42376786+droslean-bot@users.noreply.github.com>
dsmjs-bot <dsmjs-bot@users.noreply.github.com>
dune-community-bulldozer[bot] <48285683+dune-community-bulldozer[bot]@users.noreply.github.com>
dune-community-bulldozer[bot] <dune-community-bulldozer[bot]@users.noreply.github.com>
e3 <e3@bothens.(none)>
ed-bot <eduard.bagdasaryan@measurement-factory.com>
embloggenbot <walters.bradley.m+gh@gmail.com>
eng-prod-CI-bot-okta <eng_productivity_ci_bot_okta@okta.com>
enzo bot <kn0t@radbook-Pro.fios-router.home>
enzo bot <kn0t@radbook-Pro.local>
eosminerbot <moonmissionllc@protonmail.com>
eth.wiki bot <ethwikibot@eth.wiki>
fahmi-auto-merge[bot] <56689859+fahmi-auto-merge[bot]@users.noreply.github.com>
fake-join[bot] <54849188+fake-join[bot]@users.noreply.github.com>
fevzi-bot <33669958+fevzi-bot@users.noreply.github.com>
fictionalrobot-synk <55414775+fictionalrobot-synk@users.noreply.github.com>
fit2bot <robot@jumpserver.org>
flankbot <65345839+flankbot@users.noreply.github.com>
foo <foo@bar.bot>
form8ion-bot <49330085+form8ion-bot@users.noreply.github.com>
fusion-bot[bot] <fusion-bot[bot]@users.noreply.github.com>
fusionjs-bot[bot] <49695588+fusionjs-bot[bot]@users.noreply.github.com>
fusionjs-bot[bot] <fusionjs-bot[bot]@users.noreply.github.com>
fusionjs-sync-bot[bot] <54292373+fusionjs-sync-bot[bot]@users.noreply.github.com>
galileo-jamesmgreene-dev[bot] <galileo-jamesmgreene-dev[bot]@users.noreply.github.com>
galileo-jasonetco-dev[bot] <galileo-jasonetco-dev[bot]@users.noreply.github.com>
gary-kim-bot <bot@garykim.dev>
generic-probot-app-workflow[bot] <43865828+generic-probot-app-workflow[bot]@users.noreply.github.com>
generic-probot-app-workflow[bot] <generic-probot-app-workflow[bot]@users.noreply.github.com>
gerritbot <gerritbot@vm2.documentfoundation.org>
git-bot <aude@users.noreply.github.com>
git-cvs sync robot <git@happy.kiev.ua>
gitbot <gitbot@pixieengine.com>
gitbot-slack <gitbot@slack.com>
github-bot <github-bot@auto.org>
giulio_sa <giulio_sa@ROBOTO>
godin-automation[bot] <godin-automation[bot]@users.noreply.github.com>
goosebot <goosebot@kamino.friocorte.com>
grafanabot <bot@grafana.com>
grailbot <marius+grailbot@grailbio.com>
grailbot <ysaito+grailbot@grailbio.com>
greenkeeper-merge[bot] <34559404+greenkeeper-merge[bot]@users.noreply.github.com>
greenkeeper-merge[bot] <greenkeeper-merge[bot]@users.noreply.github.com>
gregory.vimont <gregory.vimont@external.softbankrobotics.com>
gremlin-probot-auto-merge[bot] <gremlin-probot-auto-merge[bot]@users.noreply.github.com>
gwatts <gwatts@TCBuildBot>
gwpybot <duncan.macleod@ldas-pcdev1.ligo.caltech.edu>
hcsp-bot <49554844+hcsp-bot@users.noreply.github.com>
heejinbot <hjhome2000+1@gmail.com>
hudson <hudson@thoughtbot.com>
i10rbot <ops@interstellar.com>
ibm-ci-bot <ibm-ci-bot@localhost>
ichefbot <ichefbot@ichef.com.tw>
init.ai <bot@init.ai>
ircbot <ircbot@cobryce.com>
ircbots <ircbots@takabe.goshikiagiri.com>
isc <isc-robotics@umich.edu>
istio-merge-robot <30445278+istio-merge-robot@users.noreply.github.com>
iuvoai-staging[bot] <iuvoai-staging[bot]@users.noreply.github.com>
jakes-learnin[bot] <jakes-learnin[bot]@users.noreply.github.com>
javarobots74 <javarobots72@gmail.com>
jenkins-x-bot <stran@redhat.com>
jenkins1mg <semantic-release-bot@martynus.net>
jetstack-bot <jetstack-bot@localhost>
keycloak-bot <keycloak-bot@redhat.com>
khsci2[bot] <khsci2[bot]@users.noreply.github.com>
kodiaktest[bot] <58980450+kodiaktest[bot]@users.noreply.github.com>
kubermatic-bot <kubermatic-bot@localhost>
kubevirt-bot <kubevirt-bot@localhost>
l10n-robot <l10n-robot@beer.openinkpot.org>
ladybugbot <release@ladybug.tools>
lambda beta bot <lambda+terzicigor@gmail.com>
letgo-bulldozer[bot] <53818503+letgo-bulldozer[bot]@users.noreply.github.com>
liefery-merge-bot <liefery-app-admin@liefery.com>
local-ffbot <local-ffbot@i-00000273.pmtpa.wmflabs>
local-pywikibot <local-pywikibot@i-00000273.pmtpa.wmflabs>
local2-github-app[bot] <local2-github-app[bot]@users.noreply.github.com>
local2-rollout-io[bot] <local2-rollout-io[bot]@@users.noreply.github.com>
local2-rollout-io[bot] <local2-rollout-io[bot]@github.com>
lolbot <lolbot@8d22ff7e-9ee6-4f15-81a5-39e9488e27cd>
maistra-bot <maistra-bot@localhost>
marketplace-monorepo-bot <marketplace-monorepo-bot-no-reply@jetbrains.com>
marksbot <bot@markspolakovs.me>
matticbot <matticbot@users.noreply.github.com>
menbotics[bot] <58158073+menbotics[bot]@users.noreply.github.com>
mergatron[bot] <mergatron[bot]@users.noreply.github.com>
merge-bot-04e79e64[bot] <58796039+merge-bot-04e79e64[bot]@users.noreply.github.com>
merge-me-test[bot] <43826360+merge-me-test[bot]@users.noreply.github.com>
merge-me-test[bot] <merge-me-test[bot]@users.noreply.github.com>
merge-me[bot] <43671963+merge-me[bot]@users.noreply.github.com>
merge-me[bot] <merge-me[bot]@users.noreply.github.com>
mergebotupgrade <30707434+mergebotupgrade@users.noreply.github.com>
mergemate[bot] <mergemate[bot]@users.noreply.github.com>
metaborgbot <gabrielkonat@gmail.com>
metaborgbot <jenkins@webdsl.st.ewi.tudelft.nl>
microsoft-github-bot[bot] <microsoft-github-bot[bot]@users.noreply.github.com>
mineweb-bulldozer-bot[bot] <56800888+mineweb-bulldozer-bot[bot]@users.noreply.github.com>
miro-merge-it-robot[bot] <miro-merge-it-robot[bot]@users.noreply.github.com>
mnottale <mnottale@aldebaran-robotics.com>
monzo-android-release-prod[bot] <58471044+monzo-android-release-prod[bot]@users.noreply.github.com>
morten-bulldozer[bot] <morten-bulldozer[bot]@users.noreply.github.com>
motiz88+bot@gmail.com <Moti Zilberman (Bot)>
mrvsbot <bot@mrvs.city>
mtest654[bot] <mtest654[bot]@users.noreply.github.com>
muffinrobot <themagicpants12@gmail.com>
n <n@nilebot.com>
neobotix <neobotix@mp-500.(none)>
neueda-robot-riga <45491565+neueda-robot-riga@users.noreply.github.com>
newbulldozer[bot] <newbulldozer[bot]@users.noreply.github.com>
nhs-digital-bot <31504352+nhs-digital-website-ps-pipeline@users.noreply.github.com>
nicolas.demaubeuge <nicolas.demaubeuge@external.softbankrobotics.com>
oS Release Bot <fvogt@suse.com>
obibok-release-bot <semantic-release-bot@martynus.net>
obibok-release-bot <travis@travis-ci.org>
oitg-bulldozer[bot] <47618865+oitg-bulldozer[bot]@users.noreply.github.com>
oitg-bulldozer[bot] <oitg-bulldozer[bot]@users.noreply.github.com>
openQA <openqa@bot.endlessm.com>
openfaas-cloud-e2e-test[bot] <openfaas-cloud-e2e-test[bot]@users.noreply.github.com>
openiobot <developers@openio.io>
openj9-bot <openj9-bot@eclipse.org>
openshift-cherrypick-robot <openshift-cherrypick-robot@localhost>
openshift-cherrypick-robot <skuznets+openshiftbot+kargakis@redhat.com>
otfbot <otfbot@tantal.xenim.de>
page update bot <none@none>
pastamaker-test[bot] <pastamaker-test[bot]@users.noreply.github.com>
pastamaker[bot] <pastamaker[bot]@users.noreply.github.com>
paulm29 <paul.robotham@gmail.com>
peril-parse-community[bot] <peril-parse-community[bot]@users.noreply.github.com>
peter <peter@robot.(none)>
pi <pi@pibot.(none)>
pi <pi@probot-pi.(none)>
piccobit-prow-bot <41137555+piccobit-prow-bot@users.noreply.github.com>
pikachu-the-chu[bot] <pikachu-the-chu[bot]@users.noreply.github.com>
pmrsbot <pmrsbot@gmail.com>
pr-doc[bot] <pr-doc[bot]@users.noreply.github.com>
pr-synchronizer[bot] <pr-synchronizer[bot]@users.noreply.github.com>
pr-valet[bot] <66557468+pr-valet[bot]@users.noreply.github.com>
prvalet[bot] <66557468+prvalet[bot]@users.noreply.github.com>
ps-merge-bot[bot] <56721713+ps-merge-bot[bot]@users.noreply.github.com>
pymor-bulldozer[bot] <48281087+pymor-bulldozer[bot]@users.noreply.github.com>
pymor-bulldozer[bot] <pymor-bulldozer[bot]@users.noreply.github.com>
rash-bot <66715041+rash-bot@users.noreply.github.com>
rebasebot <rebase-bot@users.noreply.github.com>
redshiftzero-bot <jen.helsby+bot@gmail.com>
release-bot <release@appname.com>
render_bot <bot@notahuman.co.pr>
reviewflow[bot] <reviewflow[bot]@users.noreply.github.com>
robot <Robot@acer>
robot <robot11@uos.de>
robot <robot@.com>
robot <robot@M55001161FTFA4.(none)>
robot <robot@M55001172FTFA1.(none)>
robot <robot@github.com>
robot <robot@kyoto.(none)>
robot <robot@robot11.(none)>
robot <robot@robot12.kbs>
robot <robot@robot8.kbs>
robot <robot@samsung.com>
robot@cob4-2 <robot@cob4-2>
robot@cob4-22 <robot@cob4-22>
robot@cob4-24 <robot@cob4-24>
robot@cob4-25 <robot@cob4-25>
robot@cob4-7 <robot@cob4-7>
robot@mithis.com <Tim 'mithro' Ansell's Robot>
robot@uh-rh-developer.org <robot@uh-rh-developer.org>
robot@wlrob.net <robot@wlrob.net>
robot_committer <robot_committer@vlach.com>
robotandcode <murtadhabazlitukimat@gmail.com>
roboteam <a1461013@drdrb.net>
robotics <robotics@FRCnix.(none)>
robotics account <robotics@ruby.cat.pdx.edu>
robottdog.c <18851280888@163.com>
robotx-team <evanxq23@gmail.com>
rollout-io[bot] <rollout-io@users.noreply.github.com>
roobot <website@gpa-centex.org>
root <appctl-robot@google.com>
root <jenkins-x-bot>
root <root@buildbot>
root <root@chatbot-dev-htz.lab.just-ai.com>
root <root@chatbot01.contegix.com>
root <root@master.buildbot>
root <root@runbot.therp.nl>
rpaas-admin (robot) <dev-paas-pri@mail.rakuten.com>
rplugin-monorepo-bot <rplugin-monorepo-bot-no-reply@jetbrains.com>
rusty_robot <rusty_robot@>
sculpture-bot <cannawen+sculpturebot@gmail.com>
semantic-release-bot <bot@avalon.sh>
semantic-release-bot <collab-ui-bot.gen@cisco.com>
semantic-release-bot <enmisac@gmai.com>
semantic-release-bot <hiryus.sha@gmail.com>
semantic-release-bot <juraj.oravec.josefson@gmail.com>
semantic-release-bot <tipe-cat>
semantic-release-bot <webex-components@cisco.com>
sentry-approve-merge-license-date[bot] <59181592+sentry-approve-merge-license-date[bot]@users.noreply.github.com>
sentry-review-license-date[bot] <59181592+sentry-review-license-date[bot]@users.noreply.github.com>
servarr <bot@servarr.com>
servarr-bot <bot@servarr.com>
sharelatex <copybot@overleaf.com>
skpm-bot <anoop4sethu@gmail.com>
skpm-bot <rick.charles@feed.xyz>
snowbot <snowbot@diamond.dreamhost.com>
solo-changelog-bot[bot] <52005439+solo-changelog-bot[bot]@users.noreply.github.com>
soloio-bulldozer[bot] <soloio-bulldozer[bot]@users.noreply.github.com>
sonarsource-cfamily[bot] <56782177+sonarsource-cfamily[bot]@users.noreply.github.com>
spinnakerbot <spinnakerbot@spinnaker.io>
sqbot <bot@seqsense.com>
strangerware-bot <bot@strangerware.com>
sudobot-user <sudobot-user@sudoroom.org>
syncerbot <>
talos-bot <63478881+talos-bot@users.noreply.github.com>
talos-bot <bot@talos-systems.com>
terraformbot <terraform@github.com>
tess-bot <DL-eBay-tesseract-dev@ebay.com>
tgeorge-ci-bot <60726388+tgeorge-ci-bot@users.noreply.github.com>
thoughtbot, inc <ralph@thoughtbot.com>
thoughtbot, inc. <ralph@thoughtbot.com>
thoughtbot, inc. <support@thoughtbot.com>
timvideos robot <robot@timvideos.us>
timvideos-robot <robot@timvideos.us>
tm-bot  <tm-bot@teammentor.net>
tools.commons-maintenance-bot <tools.commons-maintenance-bot@tools-sgebastion-07.tools.eqiad.wmflabs>
tools.ptbots <tools.ptbots@tools-bastion-03.tools.eqiad.wmflabs>
tools.ptbots <tools.ptbots@tools-bastion-05.tools.eqiad.wmflabs>
trailhead-content-bot <trailhead_content_publish_toolchain@salesforce.com>
translation-platform[bot] <34770790+translation-platform[bot]@users.noreply.github.com>
translation-platform[bot] <translation-platform[bot]@users.noreply.github.com>
treadmill-bot <treadmill-bot@fb.com>
trevtrichbot <60421610+trevtrichbot@users.noreply.github.com>
trilom-bot <trilom-bot@users.noreply.github.com>
trust-wallet-merge-bot <mergebot@trustwallet.com>
txtpbfmt team <txtpbfmt-copybara-robot@google.com>
uber-merge-pr[bot] <uber-merge-pr[bot]@users.noreply.github.com>
uber-workflow-bot[bot] <uber-workflow-bot[bot]@users.noreply.github.com>
ublas-format-bot <ublasbot@boost.com>
unrealbot@epicgames.com <unrealbot@epicgames.com>
vaadin-bot <mehdi@vaadin.com>
vagrant <vagrant@nubotsvmbuild.nubots.net>
validation-bot <actions@github.com>
waitor <yujin@waitorbot.(none)>
www-data <bot@pootle.tech>
xraid <xraid.iprobot@gmail.com>
ybot <ybot@Ybook.infotech.monash.edu.au>
youbot <youbot@anadolu.(none)>
youbot-2 <youbot@soundwave.(none)>
ytraduko-bot <ytraduko@gh01.de>
yunion-ci-robot <yunion-ci-robot@localhost>
yunohost-bot <translate@yunohost.org>
zaripych-bot <zaripov.rinat@gmail.com>
<D0><A0><D0><B0><D0><B7><D1><80><D0><B0><D0><B1><D0><BE><D1><82><D1><87><D0><B8><D0><BA> <razrabotcik@iMac-Admin-88.local>
<E2><80><9C>lnd-bot<E2><80><9D> <<E2><80><9C>lnd-bot@lightning.engineering<E2><80><9D>>
<E4><B9><85><E4><BF><9D><E7><94><B0><E5><8D><83><E5><B0><8B> <Chihiro@kubotachihiro-no-MacBook-Air.local>
<F0><9F><A4><96> Marge <marge-bot@mediamoose.nl>
lkml <linux-kernel@vger.kernel.org>
netdev <netdev@archiver.kernel.org>
Forestry.io <support@forestry.io>
git <git@vger.kernel.org>
linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
linux-kernel.vger.kernel.org.0 <linux-kernel@vger.kernel.org>
linux-media <linux-media@archiver.kernel.org>
Gitpan <schwern+gitpan@pobox.com>
ndroid-build-merger <android-build-merger@google.com>
linux-mm <linux-mm@archiver.kernel.org>
linux-arm-kernel <infradead-linux-arm-kernel@archiver.kernel.org>
Gitee <noreply@gitee.com>
linux-mtd <linux-mtd@archiver.kernel.org>
linux-fsdevel <linux-fsdevel@archiver.kernel.org>
caml-list <caml-list@inria.fr>
linux-wireless <linux-wireless@vger.kernel.org>
128 <linux-nfs@vger.kernel.org>
0xbzho <0xbzho@gmail.com>
Weblate <hosted@weblate.org>
netfilter-devel <netfilter-devel@archiver.kernel.org>
MIFL <mifl.pc@gmail.com>
linux-mips <linux-mips@archiver.kernel.org>
linux-btrfs <linux-btrfs@vger.kernel.org>
stable <stable@archiver.kernel.org>
. <netdev@vger.kernel.org>
linux-ext4 <linux-ext4@archiver.kernel.org>
Android (Google) Code Review <android-gerrit@google.com>
MonetDB Release Builder <release@dev.monetdb.org>
linux-parisc <linux-parisc@archiver.kernel.org>
doc <doc.divxm@gmail.com>
kernelnewbies <kernelnewbies@archiver.kernel.org>
linux-crypto <linux-crypto@archiver.kernel.org>
linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
linux-arm-kernel.lists.infradead.org.0 <linux-arm-kernel@lists.infradead.org>
linux-pci <linux-pci@archiver.kernel.org>
selinux <selinux@archiver.kernel.org>
Patchew Importer <importer@patchew.org>
gitster <gitster@pobox.com>
stable <stable@vger.kernel.org>
GitHub Enterprise <noreply@github.ibm.com>
linux-usb.vger.kernel.org.0 <linux-usb@vger.kernel.org>
VRToxinCorp <blackdragon.vrtoxin@gmail.com>
linux-fsdevel.vger.kernel.org.0 <linux-fsdevel@vger.kernel.org>
driverdev-devel.linuxdriverproject.org.0 <driverdev-devel@linuxdriverproject.org>
linux-media.vger.kernel.org.0 <linux-media@vger.kernel.org>
linux-cifs <linux-cifs@archiver.kernel.org>
linux-fsdevel <linux-fsdevel@vger.kernel.org>
linux-mm <linux-mm@kvack.org>
linux-wireless.vger.kernel.org.0 <linux-wireless@vger.kernel.org>
linux-clk <linux-clk@vger.kernel.org>
linux-iio <linux-iio@archiver.kernel.org>
linux-media <linux-media@vger.kernel.org>
linuxppc-dev.lists.ozlabs.org.0 <linuxppc-dev@lists.ozlabs.org>
linux-block <linux-block@archiver.kernel.org>
linux-input.vger.kernel.org.0 <linux-input@vger.kernel.org>
linux-block <linux-block@vger.kernel.org>
linux-watchdog <linux-watchdog@archiver.kernel.org>
linux-rdma.vger.kernel.org.0 <linux-rdma@vger.kernel.org>
linux-pci <linux-pci@vger.kernel.org>
linux-arch.vger.kernel.org.0 <linux-arch@vger.kernel.org>
linux-acpi.vger.kernel.org.0 <linux-acpi@vger.kernel.org>
util-linux <util-linux@archiver.kernel.org>
linux <linux@roeck-us.net>
lkml <linux-kernel@archiver.kernel.org>
ralf <ralf@linux-mips.org>
linux-tip-commits.vger.kernel.org.0 <linux-tip-commits@vger.kernel.org>
linux-mtd.lists.infradead.org.0 <linux-mtd@lists.infradead.org>
linux-s390.vger.kernel.org.0 <linux-s390@vger.kernel.org>
linux-mediatek.lists.infradead.org.0 <linux-mediatek@lists.infradead.org>
clang-built-linux.googlegroups.com.0 <clang-built-linux@googlegroups.com>
linux-crypto <linux-crypto@vger.kernel.org>
linux-nfs.vger.kernel.org.0 <linux-nfs@vger.kernel.org>
linux-mmc.vger.kernel.org.0 <linux-mmc@vger.kernel.org>
linux-rtc <linux-rtc@archiver.kernel.org>
linux-mtd <linux-mtd@lists.infradead.org>
linux-xfs.vger.kernel.org.0 <linux-xfs@vger.kernel.org>
linux-spi.vger.kernel.org.0 <linux-spi@vger.kernel.org>
linux-omap.vger.kernel.org.0 <linux-omap@vger.kernel.org>
linux-kbuild.vger.kernel.org.0 <linux-kbuild@vger.kernel.org>
linux-renesas-soc <linux-renesas-soc@archiver.kernel.org>
linux-mips <linux-mips@vger.kernel.org>
linux-security-module <linux-security-module@archiver.kernel.org>
Viro <viro@ZenIV.linux.org.uk>
linux-security-module <linux-security-module@vger.kernel.org>
Nikunj A Dadhania <nikunj@linux.vnet.ibm.com>
linux-integrity <linux-integrity@vger.kernel.org>
linux-hwmon.vger.kernel.org.0 <linux-hwmon@vger.kernel.org>
linux-samsung-soc.vger.kernel.org.0 <linux-samsung-soc@vger.kernel.org>
. <linux-ext4@vger.kernel.org>
linux-mm.kvack.org <int-list-linux-mm@kvack.org>
linux-iio <linux-iio@vger.kernel.org>
linux-renesas-soc.vger.kernel.org.0 <linux-renesas-soc@vger.kernel.org>
vda.linux <vda.linux@googlemail.com>
linux-rockchip.lists.infradead.org.0 <linux-rockchip@lists.infradead.org>
linux-edac.vger.kernel.org.0 <linux-edac@vger.kernel.org>
linux-fsdevel.vger.kernel.org <linux-fsdevel@vger.kernel.org>
linux-watchdog.vger.kernel.org.0 <linux-watchdog@vger.kernel.org>
linux-riscv <linux-riscv@lists.infradead.org>
linux-hwmon <linux-hwmon@archiver.kernel.org>
linux-usb.vger.kernel.org <linux-usb@vger.kernel.org>
linux-riscv.lists.infradead.org.0 <linux-riscv@lists.infradead.org>
linux-alpha.vger.kernel.org.0 <linux-alpha@vger.kernel.org>
driverdev-devel.linuxdriverproject.org <driverdev-devel@linuxdriverproject.org>
linux-renesas-soc <linux-renesas-soc@vger.kernel.org>
linux-cifs.vger.kernel.org.0 <linux-cifs@vger.kernel.org>
LinuxbrewTestBot <testbot@linuxbrew.sh>
linux-amlogic <linux-amlogic@archiver.kernel.org>
linux-nvme.lists.infradead.org.0 <linux-nvme@lists.infradead.org>
linux-rtc <linux-rtc@vger.kernel.org>
hpa <hpa@linux.intel.com>
virtualization.lists.linux-foundation.org.0 <virtualization@lists.linux-foundation.org>
linux-amlogic <linux-amlogic@lists.infradead.org>
linux-amlogic.lists.infradead.org.0 <linux-amlogic@lists.infradead.org>
linuxppc-dev.lists.ozlabs.org <linuxppc-dev@lists.ozlabs.org>
linux-leds.vger.kernel.org.0 <linux-leds@vger.kernel.org>
ltp.lists.linux.it.0 <ltp@lists.linux.it>
linux-pm.vger.kernel.org <linux-pm@vger.kernel.org>
linux-parisc <linux-parisc@vger.kernel.org>
linux-hwmon <linux-hwmon@vger.kernel.org>
linux-doc.vger.kernel.org <linux-doc@vger.kernel.org>
linux-f2fs-devel.lists.sourceforge.net.0 <linux-f2fs-devel@lists.sourceforge.net>
util-linux.vger.kernel.org.0 <util-linux@vger.kernel.org>
linux-watchdog <linux-watchdog@vger.kernel.org>
linux-scsi.vger.kernel.org <linux-scsi@vger.kernel.org>
linux-wireless.vger.kernel.org <linux-wireless@vger.kernel.org>
selinux <selinux@vger.kernel.org>
linux-input.vger.kernel.org <linux-input@vger.kernel.org>
linux-bcache.vger.kernel.org.0 <linux-bcache@vger.kernel.org>
linux-raid.vger.kernel.org.0 <linux-raid@vger.kernel.org>
linux-mediatek.lists.infradead.org <linux-mediatek@lists.infradead.org>
linux-gpio.vger.kernel.org <linux-gpio@vger.kernel.org>
trblinux <trblinux@gmail.com>
linux-hams.vger.kernel.org.0 <linux-hams@vger.kernel.org>
linux-mtd.lists.infradead.org <linux-mtd@lists.infradead.org>
linux-riscv <infradead-linux-riscv@archiver.kernel.org>
linux-cifs <linux-cifs@vger.kernel.org>
linux-rdma.vger.kernel.org <linux-rdma@vger.kernel.org>
iommu.lists.linux-foundation.org <iommu@lists.linux-foundation.org>
linux-rockchip.lists.infradead.org <linux-rockchip@lists.infradead.org>
linux-um.lists.infradead.org.0 <linux-um@lists.infradead.org>
linux-snps-arc.lists.infradead.org.0 <linux-snps-arc@lists.infradead.org>
linux <linux@dominikbrodowski.net>
linux-nvdimm.lists.01.org <linux-nvdimm@lists.01.org>
selinux-refpolicy <selinux-refpolicy@archiver.kernel.org>
linux-arm-msm.vger.kernel.org <linux-arm-msm@vger.kernel.org>
linux-wpan.vger.kernel.org.0 <linux-wpan@vger.kernel.org>
svntogit <svntogit@nymeria.archlinux.org>
linux-acpi.vger.kernel.org <linux-acpi@vger.kernel.org>
linux-ppp.vger.kernel.org.0 <linux-ppp@vger.kernel.org>
rmk+kernel <rmk+kernel@armlinux.org.uk>
linux-modules <linux-modules@archiver.kernel.org>
linux-hexagon.vger.kernel.org.0 <linux-hexagon@vger.kernel.org>
linux-serial.vger.kernel.org <linux-serial@vger.kernel.org>
linux-afs.lists.infradead.org.0 <linux-afs@lists.infradead.org>
util-linux <util-linux@vger.kernel.org>
linux-fscrypt.vger.kernel.org.0 <linux-fscrypt@vger.kernel.org>
linux-crypto.vger.kernel.org <linux-crypto@vger.kernel.org>
linux-sparse.vger.kernel.org.0 <linux-sparse@vger.kernel.org>
linux-audit.redhat.com.0 <linux-audit@redhat.com>
linux-tegra.vger.kernel.org <linux-tegra@vger.kernel.org>
linux-omap.vger.kernel.org <linux-omap@vger.kernel.org>
linux-fpga.vger.kernel.org.0 <linux-fpga@vger.kernel.org>
linux-nilfs.vger.kernel.org.0 <linux-nilfs@vger.kernel.org>
linux-nvme.lists.infradead.org <linux-nvme@lists.infradead.org>
linux-mmc.vger.kernel.org <linux-mmc@vger.kernel.org>
bridge.lists.linux-foundation.org.0 <bridge@lists.linux-foundation.org>
linux-kselftest.vger.kernel.org <linux-kselftest@vger.kernel.org>
linux-erofs.lists.ozlabs.org.0 <linux-erofs@lists.ozlabs.org>
linux-spi.vger.kernel.org <linux-spi@vger.kernel.org>
linux-s390.vger.kernel.org <linux-s390@vger.kernel.org>
linux-ntb.googlegroups.com.0 <linux-ntb@googlegroups.com>
linux-ext4.vger.kernel.org <linux-ext4@vger.kernel.org>
linux-xfs.vger.kernel.org <linux-xfs@vger.kernel.org>
ksummit-discuss.lists.linuxfoundation.org.0 <ksummit-discuss@lists.linuxfoundation.org>
linux-arch.vger.kernel.org <linux-arch@vger.kernel.org>
linux-trace-devel <linux-trace-devel@vger.kernel.org>
linux-i2c.vger.kernel.org <linux-i2c@vger.kernel.org>
linux-kbuild.vger.kernel.org <linux-kbuild@vger.kernel.org>
linux-embedded.vger.kernel.org.0 <linux-embedded@vger.kernel.org>
linux-rtc.vger.kernel.org <linux-rtc@vger.kernel.org>
linux-csky.vger.kernel.org.0 <linux-csky@vger.kernel.org>
linux1394-devel.lists.sourceforge.net.0 <linux1394-devel@lists.sourceforge.net>
linux-man.vger.kernel.org <linux-man@vger.kernel.org>
linux-rpi-kernel.lists.infradead.org.0 <linux-rpi-kernel@lists.infradead.org>
linux-efi.vger.kernel.org <linux-efi@vger.kernel.org>
linux-can.vger.kernel.org <linux-can@vger.kernel.org>
android-build-merger <android-build-merger@google.com>
linux-bluetooth <linux-bluetooth@vger.kernel.org>
<Test@test.com>
<UserName@gmail.com>
AnotherGitProfile <username@gmail.com>
Name <username@gmail.com>
User Name <username@gmail.com>
Your Name <username@gmail.com>
unknown <username@gmail.com>
userName <userName@gmail.com>
userName <username@gmail.com>
username <username@gmail.com>
yourname <username@gmail.com>
EOT

my $badEmailHere =  <<'EOT';
username@users.noreply.github.com
{username}@users.noreply.github.com
gb96@users.noreply.github.com
users.noreply.github.com
@users.noreply.github.com
webcommauto@users.noreply.github.com
spmiller@users.noreply.github.com
fcrobot@users.noreply.github.com
github-actions[bot]@users.noreply.github.com
aokromes@users.noreply.github.com
cethric@users.noreply.github.com
bt3gl@users.noreply.github.com
actions@users.noreply.github.com
user_info@users.noreply.github.com
ircle_username@users.noreply.github.com
xunnamius@users.noreply.github.com
{id?}-{username}@users.noreply.github.com
jonathanneve@users.noreply.github.com
circleci@users.noreply.github.com
hansroelants1979@users.noreply.github.com
maxmoulds@users.noreply.github.com
initbar@users.noreply.github.com
autumnswind@users.noreply.github.com
user@users.noreply.github.com
unknown@users.noreply.github.com
dependabot[bot]@users.noreply.github.com
noreply@users.noreply.github.com
github@users.noreply.github.com
dev7060@users.noreply.github.com
github-actions@users.noreply.github.com
EOT


for my $a (split(/\n/, $badAuthHere)){
  $a =~ s|^["\s\{\}\(\)\r#!%\$'/\&\*\+]*||; 
  $a =~ s|["\s\{\}\(\)\r#!%\$'/\&\*\+]*$||; 
  $bad{lc($a)} = 1;
}

my %badE;
my %RealBadE;
for my $e (split(/\n/, $badEmailHere)){
  $e =~ s/^\s*//;
  $e =~ s/\s*$//;
  $badE{lc($e)} = 1;
  $RealBadE{lc($e)} = 1;
}

open BE, "bad.e";
while (<BE>){
  chop();
  my ($e, $n) = split(/;/, $_);
  $badE{lc($e)} = 1 if $n > 15;
}
$badE{""}++;
my %badFN;
open BE, "bad.fn";
while (<BE>){
  chop();
  my ($fn, $ln, $c) = split(/;/, $_);
  my $n = "";
  if ($fn ne ""){
    if ($ln ne ""){
      $n = "$fn $ln";
    }else{
      $n = $fn;
    }
  }else{
    $n = $ln if ($ln ne "");
  }
  $badFN{lc($n)} = 1 if $c > 15;
}
$badFN{""}++;
my %badGH;
open BE, "bad.gh";
while (<BE>){
  chop();
  my ($gh, $n) = split(/;/, $_);
  $badGH{lc($gh)} = 1 if $n > 15;
}
$badGH{""}++;

sub isBad {
  my $nn = $_[0];
  my $lnn = lc($nn);
  $lnn =~ s|^["\s\{\}\(\)\r#!%\$'/\&\*\+]*||; 
  $lnn =~ s|["\s\{\}\(\)\r#!%\$'/\&\*\+]*$||; 
  return 1 if defined $bad{$lnn};
  
  # Very long ids
  if (length($lnn) > 100){
    $bad{$lnn}++;
    return 1;
  }
  my ($fn, $ln, $u, $h, $e, $gh) = parseAuthorId ($nn);
  my $n = "";
  if ($fn ne ""){
    if ($ln ne ""){
      $n = "$fn $ln";
    }else{
      $n = $fn;
    }
  }else{
    $n = $ln if ($ln ne "");
  }
  if (defined $badFN{lc($n)} && defined $badGH{lc($gh)} && defined $badE{lc($e)}){
    $bad{$lnn}++;
    return 1;
  }

  # Known productive homonyms detected by observing names associated with that email
  if ($e eq 'thomas.petazzoni@free-electrons.com' || $e eq 'alth7512@gmail.com' || $e eq 'heather@live.ru'  || $e eq 'student@epicodus.com'
      || $e eq 'dwayner@microsoft.com' || $e eq 'gdc676463@gmail.com' || $e eq 'saikumar.k@autorabit.com' || $e eq 'mmol@grockit.com' 
      || $e eq 'yy.liu@foxmail.com' || $e eq '10izzygeorge@gmail.com' || $e eq 'emberplugin@mail.ru' || $e eq 'erosen@wikimedia.org'
      || defined $RealBadE{lc($e)}){
    $bad{$lnn}++;
    return 1;
  }
  
  if ($n =~ /no.author|no author|\bbot\b|\brobot\b|\bjenkins\b|\bgerrit\b/){
    $bad{$lnn}++;
    return 1;
  }

  my $fnl = length ($fn);
  my $lnl = length ($ln);
  if ($lnn =~ /facebook-github-bot|tip-bot for|no.author|\bbot\b|\bjenkins\b/ || 
      $u =~ /\bbot\b/){
    $bad{$lnn}++;
    return 1;
  }
  my $le = length($e);
  my $lu = length($u);
  my $minL = $fnl > $lnl ? $lnl : $fnl;
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
      if ($fnl + $lnl < 5 || $n =~ /test|user|nombre|name|travis.ci|vagrant|glitch/ || $e =~ /fake/){
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
