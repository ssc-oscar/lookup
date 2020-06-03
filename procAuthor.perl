#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
use Error qw(:try);

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

while (<STDIN>){
  chop();
  my (@rest) = split(/\;/, $_, -1);
  my $nc = pop @rest;
  $a = join ';', @rest;
  my $aO = $a;
  $a =~ s/SEMICOLON/;/g;
  my ($n, $e) = git_signature_parse ($a);
  $n =~ s/;/SEMICOLON/g if $n ne "";
  $e =~ s/;/SEMICOLON/g if $e ne "";
  $a =~ s/;/:/g;
  print "$n;$e;$a;$nc\n";
}

