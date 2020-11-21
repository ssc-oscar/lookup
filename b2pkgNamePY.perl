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

my $offset = 0;
while (<STDIN>){
  chop ();
  my $b = $_;
  next if defined $badBlob{$b};
  my $b2 = fromHex($b);
  my $codeC = getBlob ($b2);
  my $hh = $b2;
  $hh = unpack 'H*', $b2 if length($b2) == 20;
  my $code = $codeC;
  $code = safeDecomp ($codeC, "$offset;$hh");
  $code =~ s/\r\n/\n/g;
  $code =~ s/\r//g;#in case only cr
  $code =~ s/\\\n//g;#join line continuations
  my %dat;
  my $start = 0;
  for my $l (split(/\n/, $code, -1)){
    if ($start == 1){ 
      if ($l =~ m/^\s*(name|license|author|author_email|description)=\s*['"]([^'"]*)['"]/){
        my $vv = $2; $vv =~ s/;/SEMICOLON/g;
        $dat{$1} = $2;
      }else{
        if ($l =~ m/^\s*install_requires\s*=\s*\[/){
          $start = 2;
        }
      }
    }else{
      if ($start == 2){
        if ($l =~ /\s*\]/){
          $start = 1;
        }else{
          $l =~ s/^\s*['"]//;
          $l =~ s/['"],//;
          $l =~ s/['"]$//;
          $l =~ s/;/SEMICOLON/g;
          $dat{'install_requires'}.=";$l";
        }
      }
    }
    $start = 1 if $l =~ /^\s*setup\s*\(/;
  }
  print "$b";
  for my $k ("name","author","author_email","description", "install_requires"){
    my $v = "";
    $v = $dat{$k} if defined $dat{$k};
    $v =~ s/^;//;
    print ";$v";
  }
  print "\n";
}
untie %clones;

untie %{$fhosc{$sec}};
my $f = $fhob{$sec};
close $f;


sub getBlob {
  my ($bB) = $_[0];
  if (! defined $fhosc{$sec}{$bB}){
     print STDERR "no blob ".(toHex($bB))." in $sec\n";
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
