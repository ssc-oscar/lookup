#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub signature_error {
        my ($msg, $data) = @_;
        print STDERR  "failed to parse signature - $msg\n";
        return ($data, "");
}

sub contains_angle_brackets{ 
   my $input = $_[0];
        return index ($input, '<') >= 0 || index ($input, '>') >= 0;
}

sub is_crud {
   my $c = $_[0];
   return  ord($c) <= 32  ||
                $c eq '.' ||
                $c eq ',' ||
                $c eq ':' ||
                $c eq ';' ||
                $c eq '<' ||
                $c eq '>' ||
                $c eq '"' ||
                $c eq '\\' ||
                $c eq '\'';
}

sub extract_trimmed {
   my ($ptr, $len) = @_;
   $ptr = substr($ptr, 0, $len);
   my $off = 0;
   while (is_crud (substr($ptr, $off, 1)) && $len > 0) {
                $off++; $len--;
   }
   $ptr = substr ($ptr, $off, $len);
   $off = 0;
   while ($len && is_crud (substr($ptr, $len-1, 1))) {
        $len--;
   }
   return substr ($ptr, 0, $len);
}

sub git_signature_parse {
   my $buffer = $_[0];
   my $email_start = index ($buffer, '<');
   my $email_end = index ($buffer, '>');
   if ($email_start < 0 || !$email_end || $email_end <= $email_start){
      if ($email_end < $email_start){
        print STDERR  "malformed e-mail ($email_start, $email_end): $buffer\n";
        $buffer =~ s/\>//;
        return git_signature_parse ($buffer);
      }else{
        return signature_error("malformed e-mail ($email_start, $email_end): $buffer", $buffer);
      }
   }
   $email_start += 1;
   my $name = extract_trimmed ($buffer, $email_start - 1);
   my $email = substr($buffer, $email_start, $email_end - $email_start);
   $email = extract_trimmed($email, $email_end - $email_start);

   return ($name, $email);
}

sub toHex { 
	return unpack "H*", $_[0]; 
} 
sub fromHex { 
	return pack "H*", $_[0]; 
} 

my $debug = 0;
$debug = $ARGV[0]+0 if defined $ARGV[0];
my $sections = 128;
my $nsec = $sections;
my $parts = 2;

my $fbasec="All.sha1c/commit_";

my (%fhob, %fhost, %fhosc);
for my $sec (0 .. ($sections-1)){
  my $pre = "/fast1/";
  $pre = "/fast1" if $sec % $parts;
  tie %{$fhosc{$sec}}, "TokyoCabinet::HDB", "$pre/${fbasec}$sec.tch", TokyoCabinet::HDB::OREADER,  
	16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $pre/$fbasec$sec.tch\n";
}

sub safeDecomp {
        my $codeC = $_[0];
        try {
                my $code = decompress ($codeC);
                return $code;
        } catch Error with {
                my $ex = shift;
                print STDERR "Error: $ex\n";
                return "";
        }
}

while (<STDIN>){
  chop();
  my $cmt = $_;
  my $c = fromHex ($cmt);
  my $sec = (unpack "C", substr ($c, 0, 1))%$sections;
  my $v = $fhosc{$sec}{$c};
  my ($tree, $parents, $auth, $cmtr, $ta, $tc, @rest) = extrCmt ($v);
  my $msg = join '\n\n', @rest;
  $msg =~ s/[\r\n]*$//;
  $msg =~ s/\r/__CR__/g;
  $msg =~ s/\n/__NEWLINE__/g;
  $msg =~ s/;/SEMICOLON/g;
  $auth =~ s/;/SEMICOLON/g;
  $cmtr =~ s/;/SEMICOLON/g;
  my ($a, $e) = git_signature_parse ($auth);
  print "$cmt;$tree;$parents;$a;$e;$auth;$cmtr;$ta;$tc;$msg\n";
}

sub extrCmt {
  my $codeC = $_[0];
  my $code = safeDecomp ($codeC);
  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     #print "$l\n";
     $tree = $1 if ($l =~ m/^tree (.*)$/);
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     ($auth) = ($1) if ($l =~ m/^author (.*)$/);
     ($cmtr) = ($1) if ($l =~ m/^committer (.*)$/);
  }
  ($auth, $ta) = ($1, $2) if ($auth =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($cmtr, $tc) = ($1, $2) if ($cmtr =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  $parent =~ s/^:// if defined $parent;
  return ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest);
}



for my $sec (0 .. ($sections-1)){
  untie %{$fhosc{$sec}};
}
