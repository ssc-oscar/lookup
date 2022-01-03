#!/usr/bin/perl

use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use Compress::LZF;
use strict;
use warnings;


sub safeDecomp {
  my ($codeC, $msg) = @_;
  my $code = "";
  eval { 
    $code = decompress ($codeC);
    return $code;
  } or do {
    my $ex = $@;
    print STDERR "Error: $ex, msg=$msg, code=$code\n";
    eval {
      $code = decompress (substr($codeC, 0, 70));
      return "$code";
    } or do {
      my $ex = $@;;
      print STDERR "Error: $ex, $msg, $code\n";
      return "";
    }
  }
}

my $s = $ARGV[0];
my $from = $ARGV[1];
my $to = $ARGV[2];
my $ver = $ARGV[3];
my %b2t;

my %parse = (
	'Rust' => \&Rust,
	'R' => \&R,
	'C' => \&C,
	'Cs' => \&Cs,
	'Dart' => \&Dart,
	'Kotlin' => \&Kotlin,
	'F' => \&F,
	'Go' => \&Go,
	'PY' => \&PY,
	'Scala' => \&Scala,
	'TypeScript' => \&TypeScript,
	'ipy' => \&ipy,
	'java' => \&java,
	'jl' => \&jl,
	'pl' => \&pl,
	'rb' => \&rb,
        'Groovy' => \&java,
);

while (<STDIN>){    
  chop();
  my ($b, $type, $t, $f) = split (/\;/, $_, -1);
  $b2t{$b} = $type;
}

my ($n, $off, $len, $cb, @x);
open A, "blob_${ver}_$s.idx";
($n, $off, @x) = split (/;/, <A>, -1);
my $offsetStart = $off;
my $nstart = $n;

open A, "blob_${ver}_$s.idx";
open B, "blob_${ver}_$s.bin";
my $nn = -1;
while (<A>){
  chop();
  ($n, $off, $len, $cb, @x) = split(/\;/, $_, -1);
  next if $n < $from+$nstart;
  last if $n >= $to+$nstart;
  if (defined $b2t{$cb} && $b2t{$cb} ne ""){ 
    my $codeC = getBlob ($cb);
    my $code = safeDecomp ($codeC, "$off;$cb");
    $code =~ s/\r//g;
    my $type = $b2t{$cb};
    my $base = "$cb;$type";
    #print "$type\n";
    $parse{$type} -> ($code, $base);
  }
}

sub Rust {
  my ($code, $base) = @_;
  # two types of match
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^use\s+(\w+)/) {
      $matches{$1}++ if defined $1;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub R {
  my ($code, $base) = @_;
  my %matches = ();
  #my $flag = 0;
  #install\.packages\(.*"data.table".*\);
  #library\(.*[\"']*?data\.table[\"']*?.*\);
  #require\(.*[\"']*?data\.table[\"']*?.*\);
  # only consider the case where one package is installed at a time
  # one case c(a,b,d) ... 
  # another case, multiple packages in one statement
  while ($code =~ /install\.packages\(.*?"([^\"',\)]+)".*?\)/g) {
        $matches{$1} = 1;
        #print $1."\n";
        #$flag = 1;
  }
  while ($code =~ /library\([\"']*?([^\"',\)]+)[\"']*?.*?\)/g) {
        #print $1;
        $matches{$1} = 1;
  }
  while ($code =~ /require\([\"']*?([^\"',\)]+)[\"']*?.*?\)/g) {
        $matches{$1} = 1;
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub java {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^import\s*(.*);/) {
      my $m = $1;
      $m =~ s|.*/||;
      $matches{$m}++ if defined $m;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }

}
sub C {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    $l =~ s|//.*|| if ($l =~ m/^\#include/); 
    $l =~ s|/\*.*|| if ($l =~ m/^\#include/); 
    $l =~ s|(.)#include.*|$1| if ($l =~ m/^\#include/); 
    if ($l =~ m/^\#include\s*\<(.*)\>/) {
      my $m = $1;
      $m =~ s|.*/||;
      $m =~ s|\s+$||;
      $m =~ s|^\s+||;
      $matches{$m}++ if defined $m;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}
sub Cs {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/\busing\s+(\S*);/) {
      $matches{$1}++ if defined $1;
      #print "$1\n";
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub Dart {
  my ($code, $base) = @_;
  my %matches = ();
  $code =~ s|//[^\n]*\n|\n|g;
  $code =~ s|;\n|;|g;
  $code =~ s|\n| |g;
  for my $l (split(/;/, $code, -1)){
#$l =~ s/\s*$//;
#   $l =~ s/^\s*//;
#    for my $l (split(/;/, $lm, -1)){
      if ($l =~ m/^import\s+(.*)$/) {
        my $m = $1;
        if (defined $m){
          if ($m =~ s/\s+as\s+(.*)//){
            my $mm = $1;
            $mm =~ s/['"]//g; 
            $m =~ s/['"]//g; 
            if ($mm =~ s/\s+show\s+(.*)//){
              $mm = $1;
              $mm =~ s/\s+hide\s+.*//;
              for my $s (split(/,/, $1, -1)){
                $s =~ s/^\s*//; $s =~ s/\s*$//;
                $matches{"$m.$s"}++;
              }
            }else{
              $m =~ s/\s+hide\s+.*//;
              $m =~ s/['"]//g;
              $m =~ s/\s+(show|deferred)$//;
              $m =~ s/^\s*//; $m =~ s/\s*$//;
              $matches{"$m"}++;
            }
          }else{
            $m =~ s/['"]//g;
            if ($m =~ s/\s+show\s+(.*)//){
              for my $s (split(/,/, $1, -1)){
                $s =~ s/^\s*//; $s =~ s/\s*$//;
                $matches{"$m.$s"}++;
              }
            }else{
              $m =~ s/\s+hide\s+.*//;
              $m =~ s/\s+(show|deferred)$//;
              $m =~ s/^\s*//; $m =~ s/\s*$//;
              $matches{"$m"}++;
            }
          }  
      }
    }
  }  
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub Kotlin {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^import\s*(.*)/) {
      my $m = $1;
      $m =~ s|.*/||;
      $m =~ s| as .*$||;
      $matches{$m}++ if defined $m;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}
sub F {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^\#include\s*"([^"]*)"/) {
      my $m = $1;
      $m =~ s|.*/||;
      $matches{$m}++ if defined $m;
    }
    if ($l =~ m/^\s*include\s*['"]([^"']*)["']/) {
      my $m = $1;
      $m =~ s|.*/||;
      $matches{$m}++ if defined $m;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }

}
sub Go {
  my ($code, $base) = @_;

  my %matches = ();
  my $start = 0;
  for my $l (split(/\n/, $code, -1)){
    $l =~ s|//.*||;
    if ($l =~ m/^import\s*"([^"]*)"/) {
      #print STDERR "$1\n";
      my $m = $1;
      $m =~ s|.*/||;
      $matches{$m}++ if defined $m;
    }
    if ($start){
       if ($l =~ m/\)/){
         $start = 0;
       }
       if ($l =~ m|\s*"([^"]*)"|){
         my $m = $1;
         $m =~ s/\{\{ \.\w* \}\}//;
         $matches{$m}++ if defined $m;
       }
    }
    if ($l =~ m/^import\s*\(/) {
      $start = 1 if $l !~ m/^import\s*\(\)/;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub Scala {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^import\s*(.*)/) {
      my $m = $1;
      $m =~ s|.*/||;
      $matches{$m}++ if defined $m;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }

}

sub TypeScript {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^\s*import\s+(.*)$/) {
      my $ll = $1;
      $ll =~ s|/\*.*\*/||;
      $ll =~ s|/\*.*\*/||;
      $ll =~ s|[{}]||g;
      if ($ll =~ m/^\s*(.*)\s+from\s+['"]([^"']*)['"]/) {
        my $pkg = $2;
        my @mds = split (/,/, $1, -1);
        for my $m (@mds) { 
          $m =~ s/^\s*//; #space from front
          $m =~ s/\s*$//; #trailing space
          $m =~ s/ as .*//; # as name 
          $matches{"$pkg/$m"}++ if defined $m;
        }
      }else{
        print STDERR "$ll\n";
      }
    }
  }
  if (%matches){
    print $base;
    for my $elem (sort keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub ipy {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    $l =~ s/^\s*"//;
    $l =~ s/".*$//;
    #print "$l\n" if $l =~ /import/;
    if ($l =~ m/^\s*import\s+(.*)/) {
      my $rest = $1;
      $rest =~ s/\s+as\s+.*//;
      while ($rest =~ m/\s*(\w[^\s,]*)[\,\s]*/g){
        #my @mds = $rest =~ m/(\w[\w.]*[\,\s]*)*/;
        #old my @mds = $1 =~ m/(\w+[\,\s]*)*/;
        #print "@mds\n";
        my $m = $1;
        if (defined $m) { 
          $m=~s/\s+$//; $m=~s/^\s+//; $m=~s/\\n$//; 
          $matches{$m}++ if defined $m
        } 
      }
    }
    if ($l =~ m/^\s*from\s+(\w[\w.]*)\s+import\s+(\w*)/) {
     #old if ($l =~ m/^\s*from\s+(\w+)/) {
      my ($a, $b) = ($1, $2);
      $a =~ s/^\s+//; $a =~s/\s+$//;
      $b =~ s/^\s+//; $b =~s/\s+$//;
      if ($b ne ""){
         $matches{"$a.$b"} = 1;
      }else{
         $matches{$a} = 1;
      }
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub jl {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^using\s+(\w+)/) {
      $matches{$1}++ if defined $1;
    }
    if ($l =~ m/^include\(([^\)]*)\)/) {
      my $m = $1;
      $m=~s/"//g;
      $matches{$m} = 1;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}
sub pl {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^use\s+(\w+)/) {
      $matches{$1}++ if defined $1;
    }
    if ($l =~ m/^require\s+(\w+)/) {
      my $m = $1;
      $m =~ s/^\'//;      
      $m =~ s/\'$//;      
      $matches{$m} = 1;
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub PY {
  my ($code, $base) = @_;

  $code =~ s/\\\n//g;#join line continuations
  # two types of match
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^import\s+(.*)/) {
      my $rest = $1;
      $rest =~ s/\s+as\s+.*//;
      while ($rest =~ m/\s*(\w[^\s,]*)[\,\s]*/g){
        #old my @mds = $1 =~ m/(\w+[\,\s]*)*/;
        my $m = $1;
        $m =~ s/\s*$//; 
        $matches{$m}++ if defined $m;
      }
    }
    if ($l =~ m/^from\s+(\w[\w.]*)\s+import\s+(\w*|\*)/) {
       if ($2 ne ""){
         $matches{"$1.$2"} = 1;
#old if ($l =~ m/^\s*from\s+(\w+)/) {
       }else{
         my $m = $1;
         $m =~ s/\s*$//;
         $matches{$m} = 1;
       }
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub rb {
  my ($code, $base) = @_;
  my %matches = ();
  for my $l (split(/\n/, $code, -1)){
    $l =~ s|\#.*||;
    if ($l =~ m/^use\s+(\w+)/) {
      $matches{$1}++ if defined $1;
    }
    if ($l =~ m/^require\s+(.+)$/) {
      my $m = $1;
      $m =~ s/\s+if\s+.*//;
      $m =~ s/^[\'"]//;      
      $m =~ s/[\'"]$//;
      $m =~ s/.*\+\s*//;
      $m =~ s/File\.[^"']*['"]//;
      $m =~ s/\).*//;
      $m =~ s/['"]//g;
      for my $mm (split (/,/, $m, -1)){
#$m =~ s/['"][^'"]*//;
        $mm =~ s/^\s+//; $mm =~ s/\s+$//;
        $matches{$mm} = 1 if $mm ne "" && $mm ne "__FILE__" && $mm !~ m|^[\./]|;
      }
    }
    if ($l =~ m/^require_dependency\s+(.+)$/) {
      my $m = $1;
      $m =~ s/^[\'"]//;
      $m =~ s/[\'"]$//;
      $m =~ s/^\s+//; $m =~ s/\s+$//;
      $matches{$m} = 1;
      
    }
  }
  if (%matches){
    print $base;
    for my $elem (keys %matches) {
      print ';'.$elem;
    }
    print "\n";
  }
}

sub getBlob {
  my ($b) = $_[0];
  seek (B, $off-$offsetStart, 0);
  my $codeC = "";
  my $rl = read (B, $codeC, $len);
  return ($codeC);
}
