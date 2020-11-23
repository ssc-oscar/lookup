#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);
use cmt;

use Digest::MD5 qw(md5 md5_hex md5_base64);
use TokyoCabinet;
use Compress::LZF;

#my $fname="$ARGV[0]";
my (%clones);
my $hdb = TokyoCabinet::HDB->new();

my $sec = $ARGV[0];
my (%fhob, %fhosc);
open $fhob{$sec}, "/data/All.blobs/blob_$sec.bin";
tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "/fast/All.sha1o/sha1.blob_$sec.tch", TokyoCabinet::HDB::OREADER,  
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/All.sha1o/sha1.blob_$sec.tch\n";
my $parsed=0;
my $notParsed=0;
my $offset = 0;

my $bad = <<"EOT";
   5900 NAME
   3899 name
   1280 PACKAGE_NAME
   1082 package_name
    764 DISTNAME
    690 about[
    390 project
    390 PACKAGE
    382 PROJECT
    314 {{
    312 PACKAGENAME
    301 project_name
    289 src
    279 %s_%s
    253 pkg_name
    226 Python
    195 MODULE_NAME
    173 __title__
    173 PROJECT_NAME
    170 __name__
    137 _name
    130 package
    129 PKG_NAME
    127 u
    271 project_var_name
    243 pip_package_name
    204 __project__
    196 APP_NAME
    194 app_name
    170 find_meta(
    163 metadata[
    149 YourAppName
    146 module_name
    145 pre_commit_dummy_package
    143 __package_name__
    142 app
    142 PROJECT_PACKAGE_NAME
    140 Name
    129 PackageName
    117 __plugin_name__
    117 __appname__
    114 release_package
EOT
#ignore generic package names
my %genPkg;
for my $i (split (/\n/, $bad, -1)){
  $i =~ s/^\s*[0-9]+\s//;
  $genPkg{$i}++;
}
while (<STDIN>){
  chop ();
  my $b = $_;
  next if defined $badBlob{$b};
  my $b2 = fromHex($b);
  my $codeC = getBlob ($b2);
  if ($codeC eq ""){
    $notParsed++;
    next;
  }
  $parsed ++;
  my $hh = $b2;
  $hh = unpack 'H*', $b2 if length($b2) == 20;
  my $code = $codeC;
  $code = safeDecomp ($codeC, "$offset;$hh");
  $code =~ s/\r\n/\n/g;
  $code =~ s/\r//g;#in case only cr
  $code =~ s/\\\n//g;#join line continuations
  $code =~ s/setup\s*\(/setup(\n/;
  my %dat;
  my $start = 0;
  for my $l (split(/\n/, $code, -1)){
#print STDERR "$start;$l\n";
    if ($start == 1){ 
      if ($l =~ m/^\s*(name|author|author_email|summary|version)\s*=\s*['"]?([^'"]*)/){
        if (defined $1 && defined $2){
          my $k = $1;
          my $vv = $2; $vv =~ s/;/SEMICOLON/g;

          $dat{$k} = $vv;
        }else{
          print STDERR "$b\;$l\n";
        }
      }
    }
    $start = 1 if $l =~ /^\[metadata\]$/;
    if ($l =~ /^\[([^\]]*)\]$/){
      $start = 1 if $1 ne "metadata";
    }
  }
  if (defined $dat{'name'} && $dat{'name'} ne "" && !defined $genPkg{$dat{'name'}}){ #otherwise look for setup.cfg
    print "$b";
    for my $k ("name","author","author_email","summary", "version"){
      my $v = "";
      $v = $dat{$k} if defined $dat{$k};
      $v =~ s/^;//;
      print ";$v";
    }
    print "\n";
  }else{
    $notParsed++;
    $parsed--;
  }
}
print STDERR "parsede/not: $parsed $notParsed\n";
untie %clones;

untie %{$fhosc{$sec}};
my $f = $fhob{$sec};
close $f;


sub getBlob {
  my ($bB) = $_[0];
  if (! defined $fhosc{$sec}{$bB}){
     #print STDERR "no blob ".(toHex($bB))." in $sec\n";
     return "";
  }
  my ($off, $len) = unpack ("w w", $fhosc{$sec}{$bB});
  my $f = $fhob{$sec};
  seek ($f, $off, 0);
  my $codeC = "";
  my $rl = read ($f, $codeC, $len);
  return ($codeC);
}




my $example = <<"EOT";
setup(
        name='bargate',
        version='1.5.dev1',
        packages=find_packages(),
        include_package_data=True,
        license='GNU General Public License v3',
        description='Open source modern web interface for SMB file servers',
        long_description=README,
        url='https://www.bargate.io',
        author='David Bell',
        author_email='dave\@evad.io',
        classifiers=[
                'Environment :: Web Environment',
                'Framework :: Flask',
                'Intended Audience :: Developers',
                'Intended Audience :: Education',
                'Intended Audience :: End Users/Desktop',
                'Intended Audience :: Information Technology',
                'License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)',
                'Operating System :: POSIX :: Linux',
                'Programming Language :: Python',
                'Programming Language :: Python :: 2',
                'Programming Language :: Python :: 2.7',
                'Topic :: Internet :: WWW/HTTP',
                'Topic :: Internet :: WWW/HTTP :: Dynamic Content',
                'Topic :: Communications :: File Sharing',
                'Development Status :: 5 - Production/Stable',
                'Natural Language :: English',
        ],
        install_requires=[
                'Flask>=0.10',
                'pysmbc>=1.0.15.5',
                'pycrypto>=2.6.1',
                'Pillow>=3.0',
        ]
)
EOT

