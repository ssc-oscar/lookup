#!/usr/bin/perl  -I /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
use TokyoCabinet;
use IO::Socket;
use Compress::LZF;
use strict;
use warnings;
use cmt;

my $type = "str2str";
$type = $ARGV[3] if defined $ARGV[3];
my $sections = $ARGV[1];
my (%fhos);
for my $sec (0 .. ($sections-1)){
  my $fbase = "$ARGV[0]";
  tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "${fbase}.$sec.tch", TokyoCabinet::HDB::OREADER, 
       16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fbase.$sec.tch\n";
}


my $server = new IO::Socket::INET(Listen    => 5,
           LocalAddr => 'da4.eecs.utk.edu',
           LocalPort => $ARGV[2],
           Proto   => "tcp",
           Reuse => 1)
        or die "can't setup server";

print "SERVER Waiting for client connection on port $ARGV[2]\n";

while (my $client = $server->accept()) {
  my $pid=fork();
  if ($pid==0){
    my $peer_address = $client->peerhost();
    my $peer_port = $client->peerport();
    print "Accepted New Client Connection From : $peer_address, $peer_port\n";
    $client->autoflush(1);
    while (<$client>) {
      my $input = $_;
      # $input =~ s/\r//g;
      # print ":$input:\n";
      if ($type eq "str2str"){
        my $sec = sHash ($input, $sections);
        if (defined $fhos{$sec}{$input}){
          my $val = safeDecomp ($fhos{$sec}{$input});
          print $client "E;$sec;$input;$val\n";
        }else{
          print $client "N;$sec;$input\n";
        }
      }
      if ($type eq "s2h"){
        my $sec = sHash ($input, $sections);
        if (defined $fhos{$sec}{$input}){
          my $vv = $fhos{$sec}{$input};
          my $res = "";
          for my $i (0..(length($vv)/20-1)){
            $res .= ";". toHex (substr($vv, $i*20, 20));
          }      
          print $client "E;$sec;$input$res\n";                               
        }else{
          print $client "N;$sec;$input\n";
        }
      }
      if ($type eq "h2s"){
        if (length($input) != 40){
          print $client "N;;$input\n";
        }else{
          my $sha = fromHex ($input);
          my $sec = hex (substr($input, 0, 2)) % $sections;
          if (defined $fhos{$sec}{$sha}){
            my $vv = safeDecomp ($fhos{$sec}{$sha});
            print $client "E;$sec;$input;$vv\n";
          }else{
            print $client "N;$sec;$input\n";
          }
        }
      }
      if ($type eq "h2h"){
        if (length($input) != 40){
          print $client "N;;$input\n";
        }else{
          my $sha = fromHex ($input);
          my $sec = hex (substr($input, 0, 2)) % $sections;
          if (defined $fhos{$sec}{$sha}){
            # this is for offset in All.sha1
            #my $nn = unpack "w", $fhos{$sec}{$sha};      
            my $vv = $fhos{$sec}{$sha};
            my $res = "";
            for my $i (0..(length($vv)/20)){
              $res .= ";". toHex (substr($vv, $i*20, 20));
            }      
            #print $client "Y:$nn:$sec:$input:\n";                               
            print $client "E;$sec;$input$res\n";                               
          }else{
            #print "N:$sec:$input:\n";
            print $client "N;$sec;$input\n";
          }
        }
      }
    }
    exit 0;
  }
}

close $server;

for my $sec (0 .. ($sections-1)){
  untie %{$fhos{$sec}};
}

