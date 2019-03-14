#!/usr/bin/perl  -I /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl

use TokyoCabinet;
use IO::Socket;
use Compress::LZF;
use strict;
use warnings;
use cmt;



my @arr = ();
my $i = 0;
while (<STDIN>){
  chop($_);
  $arr[$i] = $_;
  $i++;
}

for my $v (@arr){
  #print "$v\n";
  my $socket = new IO::Socket::INET (
    PeerAddr  => 'da4.eecs.utk.edu',
    PeerPort  =>  9997,
    Proto => 'tcp')
  or die "Couldn't connect to Server\n";
  $socket->autoflush(1);

  print $socket "$v";
  shutdown($socket, 1);
  my $response = "";
  while (<$socket>){
    $response .= $_;
  }
  #shutdown($socket, 0);
  #$socket ->recv ($response, 1024);
  print  "$response";
  $socket->close();
}


