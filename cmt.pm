package cmt;
use strict;
use warnings;
use Compress::LZF;


require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw(%badCmt %badBlob signature_error contains_angle_brackets extract_trimmed git_signature_parse extrCmt getTime cleanCmt safeDecomp safeComp toHex fromHex);
use vars qw(@ISA);

our %badCmt = (
  "c89423063a78259e6a7d13d9b00278a0c5e637b0" => 10000000005,
  "45546f17e5801791d4bc5968b91253a2f4b0db72" => 10000000000,
  "ce1407a59c910ac5dead8cb1b8b4841cabfce000" => 6649016,
  "f905f1dfa705708c4a85b04cc81b5823f1112d1c" => 6356922,
  "83c453d73f1eac85263c89d5a50ba8f9ddfccaf2" => 3336152,
  "1651ff7cb254006d82d2148c281ec3945f266b38" => 2918400,
  "3d156dd720d679df5cb2468c7eb4fe58dc642494" => 2219847
);
our %badBlob  = (
  "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391" => 7826798, #\n
  "8b137891791fe96927ad78e64b0aad7bded08bdc" => 957235, #\n\n
  "de6be7945c6a59798eb0ace177df38b05e98c2f0" => 650111   #"module ApplicationHelpe\nend\n"
);
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

sub getTime {
  my ($codeC, $str) = @_;
  my $code = safeDecomp ($codeC, $str);
  my ($pre, @rest) = split(/\n\n/, $code, -1);
  my ($auth, $cmtr, $ta, $tc) = ("","","","");
  for my $l (split(/\n/, $pre, -1)){
    ($auth) = ($1) if ($l =~ m/^author (.*)$/);
    ($cmtr) = ($1) if ($l =~ m/^committer (.*)$/);
  }
  ($auth, $ta) = ($1, $2) if ($auth =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($cmtr, $tc) = ($1, $2) if ($cmtr =~ m/^(.*)\s(-?[0-9]+\s+[\+\-]*\d+)$/);
  ($ta, $tc);
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
        if ($debug == 4){
          print "$cmt;$auth\n";
        }else{
          my ($a, $e) = git_signature_parse ($auth, $msg);
          print "$msg;$cmt;$a;$e;$ta;$auth\n";
        }
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