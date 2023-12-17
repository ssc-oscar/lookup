#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;

use utf8;
no utf8;
use JSON;

my $ver = $ARGV[1];

my %mapLang = (
    PY => 'Python',
    JS => 'JavaScript',
    C => 'C/C++',
    swift => 'Swift',
    rb => 'Ruby',
    pl => 'Perl',
    PHP => 'PHP',
    Dart => 'Dart',
    jl => 'Julia',
    java => 'Java',
    Scala => 'Scala',
    Go => 'Go',
    R => 'R',
    Rust => 'Rust',
    TypeScript => 'TypeScript',
    Groovy => 'Groovy',
    F => 'Fortran',
    Cs => 'C#'
);
#20300 ipy


my $counter = 0;
my @docs;

my $s = $ARGV[0];
my $str = "zcat Pkg2stat$ver$s.gz|";
my $c = JSON->new;
open A, $str;
while (<A>){
  chop(); 
  my ($a, $fr, $to, $nc, $na, $np) = split (/;/);
  my ($l, $pkg) = split (/:/, $a, -1);
  my ($lang, $call) = split (/:/,$a);
  my $lan = defined $mapLang{$lang} ? $mapLang{$lang} : $lang;
  my $doc = {
    API => $a,
    NumCommits => $nc+0,
    NumAuthors => $na+0, 
    NumProjects => $np+0,
    EarliestCommitDate => $fr+0, 
    LatestCommitDate => $to+0, 
    FileInfo => { $lan => $nc+0 } 
  };
  print "".($c->encode( $doc ))."\n";
}
