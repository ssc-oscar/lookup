#!/usr/bin/perl

use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;

#missing on Jul 6, 24
##phpt - php
#twig,
#tcl,
#vb,
#cmd,bat,
#pas,
#graphql,
#expect,
#stan,
#graphml,
#vala
#
#  38929 zsh
#  32206 hash
#  25044 bash
#  18028 fish
#  15957 mesh
#   7497 csh
#   6745 fsh
#                   5285 ksh
#                      4336 msh
#                         4201 bsh
#                            3961 nsh
#                               3640 rsh
#                                  3479 refresh
#                                     1822 vsh
#                                        1585 psh
#                                           1534 jspm-hash
#                                               800 flash
#                                                   641 zish
#                                                       477 xsh
#                                                           438 ush
#                                                               405 crash
#                                                                   383 ash
my %grepStr;
$grepStr{JS} ='\.(graphql|graphml|js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|ls|es6|es|jsx|mjs|sjs|co|eg|json|json.ls|json5)$';
$grepStr{PY} ='\.(py|py3|pyx|pyo|pyw|pyc|whl|wsgi|pxd)$';
$grepStr{ipy} = '\.(ipynb|IPYNB)$';
$grepStr{C} = '\.([Cch]|cpp|hh|cc|hpp|cxx|tcc|tpp|hxx|h\+\+|c\+\+)$'; #152902;h;ObjectiveC
$grepStr{java} = '\.(java|iml|class)$';
$grepStr{Shell} = '\.(cmd|bat|sh|[zcfmnkrvpxau]sh|bash|zish)$';
$grepStr{Pascal} = '\.pas$';
$grepStr{Twig} = '\.twig$';
$grepStr{Stan} = '\.stan$';
$grepStr{Tcl} = '\.tcl$';
$grepStr{Cs} = '\.(cs|cake|csx|linq)$';
$grepStr{php} = '\.(phpt|php|php[345]|phtml)$';
$grepStr{rb} = '\.(rb|erb|gem|gemspec)$';
$grepStr{Go} = '\.(go)$';
$grepStr{Rust} = '\.(rs|rlib|rst)$';
$grepStr{R} = '\.(Rd|[Rr]|Rprofile|RData|Rhistory|Rproj)$';
#^NAMESPACE|^DESCRIPTION|/NAMESPACE|/DESCRIPTION)$';
$grepStr{Scala} = '\.(scala)$';
$grepStr{Vala} = '\.(vala)$';
$grepStr{pl} = '\.(pl|PL|pm|pod|perl|pm6|pl6|p6|plx|ph)$';
$grepStr{F} = '\.(f[hi]|[fF]|[fF]77|[fF]9[0-9]|fortran|forth|FOR|for|FTN|ftn|[fF]0[378])$';
$grepStr{jl} = '\.(jl)$'; 
$grepStr{Dart} = '\.(dart)$'; 
$grepStr{Kotlin} = '\.(kt|kts|ktm)$';
$grepStr{TypeScript} = '\.(ts|tsx)$';
$grepStr{Swift} = '\.(swift)$'; # .swf is flash
$grepStr{Sql} = '\.(sql|sqllite|sqllite3|mysql)$';
$grepStr{Lisp} = '\.(el|lisp|elc|l|cl|cli|lsp|clisp)$';
$grepStr{Ada} = '\.(ad[abs])$';
$grepStr{Erlang} = '\.(erl|hrl)$';
$grepStr{Fml} = '\.(fs|fsi|aug|ml|mli|hs|lhs|sml|v|e|chs)$'; #https://en.wikipedia.org/wiki/Proof_assistant
$grepStr{Lua} = '\.(lua|wlua|rockspec)$';
#$grepStr{Markdown} = '\.(md|markdown)$';
#$grepStr{CSS} = '\.css$';
$grepStr{Clojure} = '\.(cljs|cljc|clj|cl2|cljx)$';
$grepStr{OCaml} = '\.(aug|mli|ml|aug)$';
$grepStr{Basic} = '\.(bas|bb|bi|pb|vb)$';
$grepStr{ObjectiveC} = '\.(m|mm)$'; #also MatLab: 92842;m;MatLab vs 180971;m;ObjectiveC
$grepStr{Asp} = '\.(X86|asa|[aA]51|68k|x86|X68|ASM|asp|asm|[sS])$';
$grepStr{Cuda} = '\.(cuh|cu)$';
$grepStr{Cob} = '\.(COB|cob|CBL|cbl)$';
$grepStr{Groovy} = '\.(groovy|gvy|gy|gsh)$';
$grepStr{APL} = '\.(apl|dyalog)$';


my %seen;
my $big = "";
for my $i (keys %grepStr){
  my $v = $grepStr{$i};
  $v =~ s|^\\\.\(||; 
  $v =~ s|\)\$||;
  $big .= "|$v";
}

$big =~ s/^\|*//;
$big = '\.('.$big.')$'; 
$big .= '|(^NAMESPACE|^DESCRIPTION|/NAMESPACE|/DESCRIPTION)$';
#print "$big\n";


#assume sorted by $b
my $pb = "";
while (<STDIN>){
  chop();
  #0;0;217;305;0d5602e74c8f3b477cb9357dc7eeea0622baea0d;807e8e2b26a3aeba077cbc914dd4dfbc2301fd93;0_0_10_identifier.rb;Ruby
  my ($b, $f) = split (/\;/, $_, -1);
  next if $f =~ m|^node_modules/| || $pb eq $b;
  my $found = "";
  if ($f =~ /$big/){
    #$seen{$b} = 1;
    print "$b\n";
    $pb = $b;
  }
}

