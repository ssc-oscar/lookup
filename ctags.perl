#!/usr/bin/perl

use strict;
use warnings;
use Compress::LZF;
use File::Basename;
use Getopt::Long;
use TokyoCabinet;
use Digest::SHA qw (sha1_hex sha1);

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
EOT

my $regExp = $types;
$regExp =~ s/\n/|/g;
$regExp = "^$regExp\$";
my %matches;
for my $k (split(/\n/, $types, -1)){
  $matches{$k}++;
}

my $sec = $ARGV[0];

#print STDERR "/fast/All.sha1o/sha1.blob_$sec.tch\n";
my %fhosc;
tie %fhosc, "TokyoCabinet::HDB", "/fast/All.sha1o/sha1.blob_$sec.tch", TokyoCabinet::HDB::OREADER,
  16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open /fast/All.sha1o/sha1.blob_$sec.tch\n";
open CNT, "/data/All.blobs/blob_$sec.bin" or die "$!";
open RESULTST, ">$ARGV[1].idx";
open RESULTSB, ">$ARGV[1].bin";
my $offset = 0;
my $record = 0;

my $pb = "";
my $pf = "";
my $i = 0;
my $maxBatch = 10000;
my %batch;
my %ibatch;
while (<STDIN>){
  chop();
  my ($b, $f) = split(/;/, $_, -1);
  $f =~ s|.*/||;
  $f =~ s/[()\+\-\?\!\s]//g;
  if ($b ne $pb && $pb ne ""){
    addBlob ($pb, "${i}_$pf");
  }
  $pb = $b;
  $pf = $f;
  $i++;
}
addBlob ($pb, "${i}_$pf");
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
  my ($b, $f) = @_;
  $batch{$b} = $f;
  $ibatch{$f} = $b;
  if ($i >= $maxBatch){
    dDump ();
  }
}

sub dDump {
  #printf STDERR "in dump\n";
  open FLIST, ">flist";
  for my $b (keys %batch){
    my $f = $batch{$b};
    my ($off, $len) = getBinf ($b);
    if ($len < 1000000 && ($f !~ /\.json$/ || $len < 10000)){
      my $cnt = getBlob ($off, $len, $b);
      if ($cnt ne ""){
        #printf STDERR "in dump: $f $b $ibatch{$f} $batch{$b}\n";
        open OUTPUT, ">$f";
        print OUTPUT $cnt;
        print FLIST "$f\n";
      }
    }
  }
  close OUTPUT;
  close FLIST;
  open IN, '$HOME/bin/ctags -x -L flist |';
  my %tmp = ();
  while (<IN>){
    my ($t, $n, $f) = Declarations ($_);
    #print STDERR "$t\;$n\;$f\n";
    $tmp{$ibatch{$f}}{"$t|$n"}++ if $t ne "" && $f ne "" && defined $ibatch{$f};
  }
  for my $b (keys %tmp){
    my $code = join "\n", (sort keys %{$tmp{$b}});
    my $len = length ($code);
    my $cnt = safeComp ($code);
    my $lenC = length ($cnt);
    my $bTK = sha1_hex ("tkn $len\0$code");
    print RESULTSB $cnt; 
    print RESULTST "$record;$offset;$lenC;$len;$bTK;$b;$batch{$b}\n";
    $offset += $lenC;
    $record ++;
  }
  $i = 0;
  %batch = ();
  %ibatch = ();
  open II, "flist";
  while (<II>){
    chop ($_);
    unlink $_  or warn "Could not unlink $_: $!";
  }
}

sub getBinf {
  my ($blob) = $_[0];
  my $s = hex (substr($blob, 0, 2)) % 128;
  if ($s != $sec){
    die "wrong section $s $sec for blob $blob\n";
  }
  my $bB = fromHex ($blob);
  if (! defined $fhosc{$bB}){ return (0, 0);}
  return unpack ("w w", $fhosc{$bB});
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


sub Declarations {
  my %decl = ();
  my ($file, $rest);
  die "unable to parse output ctags:$_:" unless /^(.+?)\s+([^ ]+?)\s+([0-9]+)\s+([0-9]+_[^ ]+)\s*(.*)$/;
  ($decl{name}, $decl{type}, $decl{line}, $file, $rest) = ($1, $2, $3, $4, $5);
  #if ($decl{type} =~ m|$regExp|){
  if (defined $matches{$decl{type}}){
  }else{
    print STDERR "bad type:$decl{type}:\n"; return ("", "", "");
  }
  return ($decl{type}, $decl{name}, $file);
}
