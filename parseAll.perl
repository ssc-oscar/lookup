use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

package woc;
use strict;
use warnings;
use Compress::LZF;

my %ctypes;
for my $c (split(/\n/, $ctagT)){
  $cTypes{$c} = 1000000;
}

my %grepStr;
$grepStr{JS} ='\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|ls|es6|es|jsx|mjs|sjs|co|eg|json|json.ls|json5)$';
$grepStr{PY} ='\.(py|py3|pyx|pyo|pyw|pyc|whl|wsgi|pxd)$';
$grepStr{ipy} = '\.(ipynb|IPYNB)$';
$grepStr{C} = '(\.[Cch]|\.cpp|\.hh|\.cc|\.hpp|\.cxx)$'; #152902;h;ObjectiveC
$grepStr{java} = '(\.java|\.iml|\.class)$';
$grepStr{Cs} = '\.cs$';
$grepStr{php} = '\.(php|php[345]|phtml)$';
$grepStr{rb} = '\.(rb|erb|gem|gemspec)$';
$grepStr{Go} = '\.go$';
$grepStr{Rust} = '\.(rs|rlib|rst)$';
$grepStr{R} = '(\.Rd|\.[Rr]|\.Rprofile|\.RData|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|/NAMESPACE|/DESCRIPTION)$';
$grepStr{Scala} = '\.scala$';
$grepStr{pl} = '\.(pl|PL|pm|pod|perl|pm6|pl6|p6|plx|ph)$';
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


while (<STDIN>){
  chop();
  #0;0;217;305;0d5602e74c8f3b477cb9357dc7eeea0622baea0d;807e8e2b26a3aeba077cbc914dd4dfbc2301fd93;0_0_10_identifier.rb;Ruby
  my ($n, $o, $s, $S, $tk, $b, $f, $t) = split (/\;/, $_, -1);
  $f =~ s|^[0-9]+_[0-9]+_[0-9]+_||;
  my $found = "";
  for my $mt (keys %grepStr){
    if ($f =~ /$grepStr{$mt}/){
      $found = $mt;
      last;
    }
  }
  if ($found ne ""){
    print "$found;$t;$f\n";
  }else{
    print ";$t;$f\n";
  }
}
    
   

my $ctagT =  <<"EEEEET";
HTML
JSON
Java
JavaScript
C++
Markdown
Python
PHP
XML
C#
C
CSS
TypeScript
Ruby
ObjectiveC
Go
Maven2
SCSS
JavaProperties
Rust
R
MatLab
Tex
Iniconf
Sh
RSpec
Lua
ReStructuredText
Perl
SQL
Make
SVG
PlistXML
Diff
Asm
Fortran
Flex
Clojure
Elixir
Ant
CMake
OCaml
AnsiblePlaybook
EmacsLisp
Man
RpmSpec
Pascal
PowerShell
Verilog
Erlang
Asciidoc
Vim
Lisp
PuppetManifest
Yaml
Scheme
VHDL
D
Autoconf
DosBatch
Moose
Elm
BibTeX
CUDA
Ada
XSLT
Protobuf
DTD
Tcl
Eiffel
SystemVerilog
DTS
WindRes
YACC
TeXBeamer
Basic
SML
Asp
Pod
Robot
LdScript
Perl6
Automake
AutoIt
NSIS
Cobol
M4
CPreProcessor
RelaxNG
QtMoc
Awk
DBusIntrospect
TTCN
Zephir
SLang
Gdbinit
SystemTap
REXX
Myrddin
QemuHX
Ctags
TclOO
Falcon
ITcl
Inko
PythonLoggingConfig
Vera
Varlink
BETA
ObjectiveC
JSO
EEEEET



