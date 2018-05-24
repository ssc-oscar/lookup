package cmt;
use strict;
use warnings;
use Compress::LZF;


require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw(signature_error contains_angle_brackets extract_trimmed git_signature_parse extrCmt cleanCmt safeDecomp safeComp toHex fromHex);
use vars qw(@ISA);

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
   my ($buffer, $cmt) = @_;
   my $email_start = index ($buffer, '<');
   my $email_end = index ($buffer, '>');
   if ($email_start < 0 || !$email_end || $email_end <= $email_start){
      if ($email_end < $email_start){
        print STDERR  "in $cmt malformed e-mail ($email_start, $email_end): $buffer\n";
        $buffer =~ s/\>// if $email_end >= 0;
        $buffer =~ s/$/\>/ if $email_end < 0;
        return git_signature_parse ($buffer, $cmt);
      }else{
        return signature_error("in $cmt malformed e-mail ($email_start, $email_end): $buffer", $buffer);
      }
   }
   $email_start += 1;
   my $name = extract_trimmed ($buffer, $email_start - 1);
   my $email = substr($buffer, $email_start, $email_end - $email_start);
   $email = extract_trimmed($email, $email_end - $email_start);

   return ($name, $email);
}

sub extrCmt {
  my ($codeC, $str) = @_;
  my $code = safeDecomp ($codeC, $str);
  my ($tree, $parent, $auth, $cmtr, $ta, $tc) = ("","","","","","");
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  for my $l (split(/\n/, $pre, -1)){
     #print "$l\n";
     $tree = $1 if ($l =~ m/^tree (.*)$/);
     $parent .= ":$1" if ($l =~ m/^parent (.*)$/);
     #($auth, $ta) = ($1, $2) if ($l =~ m/^author (.*)\s([0-9]+\s[\+\-]*\d+)$/);
     #($cmtr, $tc) = ($1, $2) if ($l =~ m/^committer (.*)\s([0-9]+\s[\+\-]*\d+)$/);
     ($auth) = ($1) if ($l =~ m/^author (.*)$/);
     ($cmtr) = ($1) if ($l =~ m/^committer (.*)$/);
  }
  ($auth, $ta) = ($1, $2) if ($auth =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($cmtr, $tc) = ($1, $2) if ($cmtr =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  $parent =~ s/^:// if defined $parent;
  return ($tree, $parent, $auth, $cmtr, $ta, $tc, @rest);
}

sub cleanCmt {
  my ($cont, $cmt, $debug) = @_;
  my ($tree, $parents, $auth, $cmtr, $ta, $tc, @rest) = extrCmt ($cont, $cmt);
  my $msg = join '\n\n', @rest;
  if ($debug){
    if ($debug == 3){
      my $c = safeDecomp($cont, $cmt);
      $c =~ s/\r/ /g;
      print "$c\n";
    }else{
      $msg =~ s/[\r\n;]/ /g;
      $msg =~ s/^\s*//;
      $msg =~ s/\s*$//;
      $auth =~ s/;/ /g;
      if ($debug == 2){
        print "$cmt;$auth;$ta;$msg\n";
      }else{
        my ($a, $e) = git_signature_parse ($auth, $msg);
        print "$msg;$cmt;$a;$e;$ta;$auth\n";
      }
    }
  }else{
    $msg =~ s/[\r\n]*$//;
    $msg =~ s/\r/__CR__/g;
    $msg =~ s/\n/__NEWLINE__/g; 
    $msg =~ s/;/SEMICOLON/g; 
    $auth =~ s/;/SEMICOLON/g; 
    $cmtr =~ s/;/SEMICOLON/g;
    print "$cmt;$tree;$parents;$auth;$cmtr;$ta;$tc\n";
  }
}

1;
