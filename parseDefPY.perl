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

my %genPkg;
for my $i (split (/\n/, $bad, -1)){
  $i =~ s/^\s*[0-9]+\s//;
  $genPkg{$i}++;
}
my %grepStr;
$grepStr{JS} ='\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|ls|es6|es|jsx|mjs|sjs|co|eg|json|json.ls|json5)$';
$grepStr{JS} ='package\.json$';
#$grepStr{JS} ='^(package\.json|bower\.json|lerna.json|yarn.lock|package-lock.json|packages/[^/]*/package.json|codemods/[^/]*/package.json)$';
$grepStr{JS} ='^(package\.json|bower\.json|lerna.json|yarn.lock|package-lock.json)$';
$grepStr{PY} ='\.(py|py3|pyx|pyo|pyw|pyc|whl|wsgi|pxd)$';
$grepStr{PY} ='setup\.(py|py3|pyx)$';
$grepStr{ipy} = '\.(ipynb|IPYNB)$';
$grepStr{C} = '(\.[Cch]|\.cpp|\.hh|\.cc|\.hpp|\.cxx)$'; #152902;h;ObjectiveC
$grepStr{Java} = '(\.java|\.iml|\.class)$';
$grepStr{Java} = '\.java$';
$grepStr{Cs} = '\.cs$';
$grepStr{php} = '\.(php|php[345]|phtml)$';
$grepStr{rb} = '\.(rb|erb|gem|gemspec)$';
$grepStr{Go} = '\.go$';
$grepStr{Rust} = '\.(rs|rlib|rst)$';
$grepStr{Rust} = '[Cc]argo\.(lock|toml)$';
$grepStr{R} = '(\.Rd|\.[Rr]|\.Rprofile|\.RData|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|/NAMESPACE|/DESCRIPTION)$';
$grepStr{R} = '(^NAMESPACE|^DESCRIPTION|/NAMESPACE|/DESCRIPTION)$';
$grepStr{Scala} = '\.scala$';
$grepStr{pl} = '\.(pl|PL|pm|pod|perl|pm6|pl6|p6|plx|ph)$';
$grepStr{pl} = '\.(pm|pm6)$';
$grepStr{F} = '\.(f[hi]|[fF]|[fF]77|[fF]9[0-9]|fortran|forth|FOR|for|FTN|ftn|[fF]0[378])$';
$grepStr{jl} = '\.jl$';
$grepStr{Dart} = '\.dart$';
$grepStr{Kotlin} = '\.(kt|kts|ktm)$';
$grepStr{TypeScript} = '\.(ts|tsx)$';
$grepStr{Swift} = '\.swift$'; # .swf is flash
$grepStr{Sql} = '\.(sql|sqllite|sqllite3|mysql)$';
$grepStr{Lisp} = '\.(el|lisp|elc|l|cl|cli|lsp|clisp)$';
$grepStr{Ada} = '\.ad[abs]$';
$grepStr{Erlang} = '\.(erl|hrl)$';
$grepStr{Fml} = '\.(fs|fsi|aug|ml|mli|hs|lhs|sml|v|e)$'; #https://en.wikipedia.org/wiki/Proof_assistant
$grepStr{Lua} = '\.lua$';
$grepStr{Markdown} = '\.(md|markdown)$';
$grepStr{CSS} = '\.css$';
$grepStr{Clojure} = '\.(cljs|cljc|clj)$';
$grepStr{OCaml} = '\.(aug|mli|ml|aug)$';
$grepStr{Basic} = '\.(bas|bb|bi|pb)$';
$grepStr{ObjectiveC} = '\.(m|mm)$'; #also MatLab: 92842;m;MatLab vs 180971;m;ObjectiveC
$grepStr{Asp} = '\.(X86|asa|A51|68k|x86|X68|ASM|asp|asm|[sS])$';
$grepStr{Cuda} = '\.(cuh|cu)$';
$grepStr{Cob} = '\.(COB|cob|CBL|cbl)$';
$grepStr{Groovy} = '\.(groovy|gvy|gy|gsh)$';

my %parse = (
  'Rust' => \&Rust,
  'JS' => \&JS,
	'R' => \&R,
#	'C' => \&C,
#	'Cs' => \&Cs,
#	'Dart' => \&Dart,
	'Kotlin' => \&Java,
	'Go' => \&Go,
	'PY' => \&PY,
	'Scala' => \&Java,
#	'TypeScript' => \&TypeScript,
#	'ipy' => \&ipy,
	'Java' => \&Java,
#	'jl' => \&jl,
	'pl' => \&Java,
#	'rb' => \&rb,
  'Groovy' => \&Java,
  'Erlang' => \&Erlang,
);

my $s = $ARGV[0];
my $from = defined $ARGV[1] ? $ARGV[1] : -1;
my $to = defined $ARGV[2] ? $ARGV[2] : -1;
open A, "zcat /da5_data/All.blobs/blob_$s.idxf|";
open Z, "blob_TU_$s.idx";
my @x = split (/;/, <Z>);
$from = $x[0];
while (<Z>){@x=split (/;/, $_);}
$to = $x[0];
print STDERR "from=$from to=$to\n";

open B, "/data/All.blobs/blob_$s.bin";
my $nn = -1;
while (<A>){
  chop(); 
  my ($n, $off, $len, $cb, $f) = split(/\;/, $_, -1);
  $nn++;
  next if $from >= 0 && $n < $from;
  last if $to >= 0 && $n > $to;
  my $found = "";
  my $mt = "PY";
  if ($f =~ /$grepStr{$mt}/){
    $found = $mt;
  }

  if ($found ne "" && defined $parse{$found}){ 
    next if $len > 500000; #ignore incredibly large files
    my $codeC = getBlob ($cb, $off, $len);
    my $code = safeDecomp ($codeC, "$off;$cb");
    $code =~ s/\r//g;
    my $type = $found;
    my $res = $parse{$type} -> ($code);
    print "$cb;$type;$res;$f\n";
  }
}

sub getBlob {
  my ($b, $off, $len) = @_;
  seek (B, $off, 0);
  my $codeC = "";
  my $rl = read (B, $codeC, $len);
  return ($codeC);
}

sub Rust {
  my $code = $_[0];
  my $res = "";
#  name = "rusticata-macros"
  for my $l (split(/\n/, $code, -1)){
    return $1 if $l =~ m/^name\s*=\s*"([^"]*)"/;
  }
  return $res;
}

sub JS {
  my $code = $_[0];
  my $res = "";
#  "name": "pubnub",
  for my $l (split(/\n/, $code, -1)){
    if ($l =~ m/^\s*"name"\s*:\s*"([^"]*)"/){
      return $1;
    }
  }
  return $res;
}

use JSON qw(decode_json);
sub JSDep {
  my $code = $_[0];
  my $res = "";
  my $data;
  eval { 
    $data = decode_json($code);
  };
  return "" if !defined $data || $data eq "";
  my %dependencies = ();
  my $a = "$data";
  if ($a =~ /^HASH/ && defined $data->{'dependencies'}){
    $a = "$data->{'dependencies'}";
    if ($a =~ /^HASH/){
      %dependencies = %{$data->{'dependencies'}};
      for my $elem (keys %dependencies) {
        $res .= ";$elem";
      }
    }else{
      if ($a =~ /^ARRAY/){
        #print STDERR "@{$data->{dependencies}}\n";
        for my $elem (@{$data->{'dependencies'}}) {
          $res .= ";$elem";
        }
      }else{
        print STDERR "BadDep:$a\n";
      }
    }
    $res =~ s/^;//;
  }
  return $res;
}

sub Java {
  my $code = $_[0];
  my $res = "";
  for my $l (split(/\n/, $code, -1)){
    $res .= ";$1" if $l =~ m/^\s*package\s+([^s]*)\s*;/;
  }
  $res =~ s/^;//;
  $res;
}

sub Go {
  my $code = $_[0];
  my $res = "";
  for my $l (split(/\n/, $code, -1)){
    $res .= ";$1" if $l =~ /^\s*package\s+([^\s]*)/;
  }
  $res =~ s/^;//;
  $res =~ s/['"]//g;
  $res;
}

sub PY {
  my ($code) = $_[0];
  $code =~ s/\r\n/\n/g;
  $code =~ s/\r//g;#in case only cr
  $code =~ s/\\\n//g;#join line continuations
  $code =~ s/\bsetup\s*\(/\nsetup(\n/;
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
          print STDERR "$l\n";
        }
      }
    }
    $start = 1 if $l =~ /^setup\(/;
    $start = 1 if $l =~ /^\[metadata\]$/;
    if ($l =~ /^\[([^\]]*)\]$/){
      $start = 1 if $1 ne "metadata";
    }
  }
  if (defined $dat{'name'} && $dat{'name'} ne "" && !defined $genPkg{$dat{'name'}}){ #otherwise look for setup.cfg
    my $res = "";
#for my $k ("name","author","author_email","summary", "version"){
    for my $k ("name"){
      my $v = "";
      $v = $dat{$k} if defined $dat{$k};
      $v =~ s/^;//;
      $res .= ";$v";
    }
    $res =~ s/^;//;
    $res =~ s/['"]//g;
    return $res;
  }
}

sub R {
  my $code = $_[0];
  my $res = "";
  for my $l (split(/\n/, $code, -1)){
    $res .= ";$1" if $l =~ /^Package:\s*(.*)$/;
  }
  $res =~ s/^;//;
  $res;
}

sub Erlang {
  my $code = $_[0];
  my $codeline = "";
  my %package = ();
  for my $l (split(/\n/, $code, -1)){
    $codeline .= $l;
    if ($codeline =~ m/.*,\s*$/) {
      # print $codeline;
      next;
    }
    if ($codeline =~ m/^package\s+(.*)/) {
      my $rest = $1;
      $rest =~ s/:.*//;
      while ($rest =~ m/\s*(\w[^\s,]*)[\,\s]*/g){
        my $m = $1;
        $m =~ s/\s*$//;
        $m =~ s/\..*//;
        $package{$m}++ if defined $m;
      }
    }
    $codeline = "";
  }
  if (%package){
    return join ';', (keys %package);
  }
  return "";
}
