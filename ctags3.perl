#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;
use Compress::LZF;
use File::Basename;
use Getopt::Long;
use Digest::SHA qw (sha1_hex sha1);

my %ctagsHangs = ("8209fa2425c1c1d0bf20a3870d6f0546540c0958" => "operatorservice.proto",
    "9a47ff27af14024249378f749e2097b3da7185ea" => "broker.proto",
    "17383b248e9c1221916771f96a6ecf73f4b0ec50" => "wishlist.proto",
    "7f7d775242dd83df60df9ae2c20cd1b60d396c5b" => "mastersvc.proto", 
    "7e832be15a29257298da48ef3445606e9ec6d7aa" => "gTogether.proto",
    "7a5e1def59408c0a82f7762959b7ce07c0cb1327" => "todo-service.proto",
    "7aead53de23be4193ac29711899c0bf230156c75" => "todo-service.proto",
    "fac3b539ae1a7433e4d7fbd2f33dbf2e43c8636d" => "todo-service.proto",
    "7af256a5e30a0c260f055e2a122d7b52e60e3831" => "todo-service.proto",
    "7afe7b6b64d78faa740a19a451d7334360c8f7d2" => "todo-service.proto",
    "7764d1e496837d9566463610236e8801dea6f0ed" => "ChatService.proto");

my %ctagsHangsF;

for my $f (values %ctagsHangs){
  $ctagsHangsF{$f}++;
}


my $types =  <<"EOT";
Math
alias
anchor
array
artifactId
boolean
nsprefix
number
object
previous
string
function
class
macro
member
method
field
constant
package
label
namespace
define
type
enumerator
subroutine
struct
typedef
enum
union
var
module
RecordField
variable
heading1
heading2
heading3
heading4
heading5
key
property
section
source
citation
id
packageName
inproceedings
signal
subprogspec
category
play
generator
library
subst
accessor
methodSpec
subprogram
Constructor
group
const
describe
entity
getter
book
target
implementation
singletonMethod
tag
unknown
paragraph
enumConstant
procedure
interface
subsubsection
globalVar
data
arg
chapter
null
func
article
functionVar
subsection
selector
entry
fd
frametitle
l5subsection
ltlibrary
misc
phdthesis
placeholder
protected
record
register
script
signature
structure
directory
node
packspec
template
annotation
division
program
project
root
title
trait
Exception
component
event
heredoc
message
common
optwith
def
incollection
setter
value
anonMember
mixin
port
repositoryId
modifiedFile
context
constructor
index
optenable
command
inbook
table
condition
definition
parameter
groupId
hunk
l4subsection
counter
custom
derivedMode
exception
face
namelist
role
submethod
attribute
keyword
mastersthesis
test
version
view
block
proceedings
protocol
service
task
global
testcase
feature
rpc
map
net
mxtag
cursor
newFile
resource
augroup
derivedMode
mastersthesis
protocol
resource
attribute
feature
map
subtype
face
manual
minorMode
unpublished
test
part
techreport
mxtag
custom
blockData
oneof
set
wrapper
accelerators
assert
format
qualname
loggerSection
delegate
langstr
varalias
option
bibitem
subparagraph
man
literal
menu
icon
bitmap
framesubtitle
symbol
dialog
val
option
qualname
sectionGroup
accelerators
callback
loggerSection
matchedTemplate
subparagraph
trigger
talias
bibitem
langstr
man
booklet
deletedFile
bitmap
menu
local
dialog
literal
symbol
icon
parameterEntity
conference
domain
element
formal
functor
grammar
guard
operator
protectspec
region
repoid
rule
separate
taskspec
theme
token
toplevelVariable
element
functor
inline
modport
modulepar
namedPattern
namedTemplate
repoid
synonym
theme
timer
submodule
error
probe
covergroup
error
altstep
identifier
infoitem
MSI
Series
edesc
filename
fragment
iparam
kind
langdef
notation
oparam
phandler
pkg
publication
qmp
reopen
slot
font
mlconn
mlprop
mltable
EOT

my $regExp = $types;
$regExp =~ s/\n/|/g;
$regExp = "^$regExp\$";
my %matches;
for my $k (split(/\n/, $types, -1)){
  $matches{$k}++;
}

my $sec = $ARGV[0];

open CNT, "blob_$sec.bin" or die "$!";

open RESULTST, ">$ARGV[1].idx";
open RESULTSB, ">$ARGV[1].bin";
my ($from, $to) = (0, -1);
$from = $ARGV[2] if defined $ARGV[2];
$to = $ARGV[3] if defined $ARGV[3];

my $offset = 0;
my $record = 0;

my $flist = "${sec}_${from}_flist";
print STDERR "$flist\n";

my $i = -1;
my $maxBatch = 300;
my %batch;
my %ibatch;

my $nn = -1;
open IDX, "zcat blob_${sec}.idxf2|";
#00000000;0;461;00b31262da21c4f57d5b207372b6ded0bb332911;library/socket/fixtures/classes.rb
while (<IDX>){
  chop();
  my ($j, $off, $len, $b, $f) = split(/;/, $_, -1);
  $j =~ s/^0*//;
  $j = 0 if $j eq "";
  $i++;
  $nn ++;
  die "missed record at :$nn: :$j: $b\n" if ($nn+0 != $j+0);
  next if $j < $from || ($to >= 0 && $j >=$to);
  if ($f ne ""){
    $f =~ s|^.*/||;
    $f =~ s|[\s\[\]\{\}\(\)\!\?]|_|g;
  }
  addBlob ($b, $off, $len, $f);
}
dDump();

sub toHex {
  return unpack "H*", $_[0];
}
sub fromHex {
 return pack "H*", $_[0];
}
sub safeDecomp {
  my ($codeC, $msg) = @_;
  try {   
    my $code = decompress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex, $msg\n";
    return "";
  }
}
sub safeComp {
  my ($codeC, $msg) = @_;
  try {   
    my $code = compress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex, $msg\n";
    return "";
  }
}
sub addBlob {
  my ($b, $off, $len, $f) = @_;
  my $cnt = getBlob ($off, $len, $b);
  if ($cnt ne ""){
    my $fn = "${sec}_${from}_${i}_$f";
    open OUTPUT, "> $fn";
    print OUTPUT $cnt;
    $batch{$b} = "$fn";
    close OUTPUT;#ensure it is flushed to disk
  }
  if ($i >= $maxBatch){
    dDump ();
  }
}


sub dDump {
  #printf STDER"in dump\n";
  open FLIST, "> $flist";
  for my $b (keys %batch){
    my $f = $batch{$b};
    if ($f =~ m/^${sec}_${from}_[0-9]+_$/){
      open EXT, "file -bi $f|";
      my $ext = <EXT>;
      chop ($ext);
      $ext =~ s|^[^/]*/x-||;
      $ext =~ s|^text/||;
      $ext =~ s|^application/||;
      $ext =~ s|;.*||;
      $ext =~ s|^plain$|txt|;
      $ext =~ s|/|_|g;
      #print STDERR "$f.$ext\n";
      system "mv $f $f.$ext";
      $batch{$b} = $f.$ext;
      $ibatch{"$f.$ext"} = $b;
      <EXT>;
      print FLIST "$f.$ext\n";
    }else{
      print FLIST "$f\n";
      $ibatch{$f} = $b;
    }
  }
  close FLIST; #ensure it is flushed to disk
  open IN, '$HOME/bin/myTimeout 600s $HOME/bin/ctags --fields=kKlz  -L '.$flist.' -uf - |';
  my %tmp = ();
  my %ll = ();
  while (<IN>){
    chop();
    if ($_ =~ /TIMEOUT_TIMEOUT_TIMEOUT/){
      for my $b (keys %batch){
        printf STDERR "BAD_BATCH:$b\;$batch{$b}\n";
      }
      last;
    }
    my ($t, $n, $f, $lan) = Declarations ($_);
    #print STDERR "$t\;$n\;$f;$ibatch{$f}\n";
    #$tmp{$ibatch{$f}}{"$t|$n"}++ if $t ne "" && $f ne "" && defined $ibatch{$f};
    if (defined $t && $t ne "" && $f ne "" && defined $ibatch{$f}){
      my $val = "$t|$n";
      $tmp{$ibatch{$f}} .= "\n$val";
      $ll{$ibatch{$f}} = $lan;
    }
    #push @tmp{$ibatch{$f}}{"$t|$n"}++ if $t ne "" && $f ne "" && defined $ibatch{$f};
  }
  for my $b (keys %tmp){
    #my $code = join "\n", (sort keys %{$tmp{$b}});
    my $code = $tmp{$b};
    $code =~ s/^\n//;
    my $len = length ($code);
    my $cnt = safeComp ($code);
    my $lenC = length ($cnt);
    my $bTK = sha1_hex ("tkn $len\0$code");
    print RESULTSB $cnt; 
    print RESULTST "$record;$offset;$lenC;$len;$bTK;$b;$batch{$b};$ll{$b}\n";
    $offset += $lenC;
    $record ++;
  }
  $i = 0;
  %batch = ();
  %ibatch = ();
  open II, "$flist";
  while (<II>){
    chop ($_);
    unlink $_  or warn "Could not unlink $_: $!";
  }
}

sub getBlob {
  my ($off, $len, $blob) = @_;
  seek (CNT, $off, 0);
  #my $curpos = tell(CNT);
  my $codeC = "";
  my $rl = read (CNT, $codeC, $len);
  my $code = safeDecomp ($codeC, "$sec;$blob");
  return $code;
  # print "blob;$sec;$rl;$curpos;$off;$len\;$blob\n";
  # print "$code\n";
  #
}
#xlink 544_ring-1.svg /^  width="373.34px" height="372.92px" viewBox="0 0 373.34 372.92" enable-background="new 0 0 373./;"      kind:nsprefix   language:XML    uri:http://www.w3.org/1999/xlink
sub Declarations {
  my ($name, $file, $rest, $type, $lang) = ("", "", "", "", "");
  m|^(.+?)\s+([0-9][^ ]+?)\s+(.*)\s+kind:([^ :]+)\s+language:([^ :]+)$|;
  if (!defined $1){
    m|^(.+?)\s+([0-9][^ ]+?)\s+(.*)\s+kind:([^ :]+)\s+language:([^ :]+)\s+([^ ]*:[^ :]*)$|;
    if (!defined $1){
      print STDERR "badLine:$_\n";
    }else{	    
      ($name, $file, $rest, $type, $lang) = ($1, $2, $3, $4, $5);
    }
  }else{
    ($name, $file, $rest, $type, $lang) = ($1, $2, $3, $4, $5);
  }
  if (defined $type){
   if (defined $matches{$type}){
   }else{
     print STDERR "new type:$type:\n";
   }
  }else{
    print STDERR "$type, $name, $file, $lang\n$_";
  }
  return ($type, $name, $file, $lang);
}
