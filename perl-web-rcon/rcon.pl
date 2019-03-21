#!/usr/bin/perl
#
# This is a really shitty "Web RCON" CLI client for Rust.
#
# It swallows everything it gets on STDIN and turns
# the line into a Web RCON command, then prints the
# server's response as raw JSON data.
#
# Server configurations may be stored in ~/.rcon
# as <name> <host>:<port>/password
# Example:
#   myserver 127.0.0.1:28016/mypassword
#
# The program may also be invoked with the
# host/port/password specified on the command line
# Example:
#   ./rcon.pl 127.0.0.1:28016/mypassword
#
# Note that specifying the host information on the
# command line may expose it to other users on your
# system. The use of a ~/.rcon file is recommended.
#
# Copyright 2019 - Michael Graziano (mikeg@bsd-box.net)
#
use IO::Async::Loop;
use IO::Async::Stream;
use Net::Async::WebSocket::Client;

use File::HomeDir;
use File::stat;

use JSON;
use URL::Encode qw/url_encode/;

my $CFGFile = File::HomeDir->my_home .'/.rcon';
# Security Check: if ~/.rcon exists only the owner
# should be able to read it.
if ( defined stat($CFGFile) && 
     (stat($CFGFile)->mode & 0077) ){
     print STDERR "$CFGFile exists with insecure permissions.\n";
     print STDERR "You need to \"chmod 700 $CFGFile\"\n\n";
     exit 2;
 }

my $CFG = shift;
my ($HOST, $PORT, $PASS);

# Assume the CFG argument on the command
# line is a Host:Port/Password string
if ($CFG =~ /^([^:]+):([0-9]+)\/(.*)$/) {
	$HOST = $1;
	$PORT = $2;
	$PASS = url_encode($3);
} else {
	# If the thing on the command line is NOT
	# a Host:Port/Password string then it's
	# a config name from ~/.rcon
	
	my $fh;
	my $line;
	open($fh, '<', $CFGFile) or die $!;
	$PORT = -1; # We're using this as a REALLY ghetto flag...
	while (chomp($line = <$fh>)) {
		if ($line =~ /^${CFG}\s+(.*)$/) {
			$line = $1;
			if ($line =~ /^([^:]+):([0-9]+)\/(.*)$/) {
				$HOST = $1;
				$PORT = $2;
				$PASS = url_encode($3);
				break; # First Match Wins.
			} else {
				print STDERR "Malformed config line for $CFG ignored\n";
				print STDERR "$line\n";
			}
		}
	}
	close $fh;
}
if (! (defined $HOST && defined $PORT && defined $PASS) ) {
	if ($PORT == -1 && length($CFG)) {
		print STDERR "No configuration for $CFG found in ~/.rcon\n";
		exit 2;
	}
	print STDERR "Usage:\n";
	print STDERR "\t$0 <HOST>:<PORT>/<PASSWORD>\n";
	print STDERR "\t$0 <cfgname>\n";
	print STDERR "\n";
	print STDERR "<cfgname> is a name found in ~/.rcon which\n";
	print STDERR "contains lines of the form <name> <HOST>:<PORT>/<PASSWORD>\n";
	print STDERR "\n";
	exit 1;
}

my $i = 1;

my ($client, $stdio);

$client = Net::Async::WebSocket::Client->new(
	on_text_frame => sub {
		my ($self, $frame) = @_;
		print "${frame}\n";
	},
);

$stdin = IO::Async::Stream->new_for_stdio(
	on_read => sub {
		my ($self, $buffref) = @_;
		chomp($$buffref);
		return 0 if (length($$buffref) == 0);
		my %msg = (
			'Identifier'=>$i,
			'Message' => $$buffref,
			'Name' => 'WebRcon',
		);
		my $json = encode_json \%msg ;
		$client->send_text_frame( $json );
		$$buffref = "";
		$i++;
	},
	on_read_eof => sub {
		# EOF means we're done.
		exit 0;
	},
);
#$stdout = IO::Async::Stream->new_for_stdout();

my $loop = IO::Async::Loop->new;
$loop->add( $client );
$loop->add( $stdin );

$client->connect(
	host => $HOST,
	port => $PORT,
	url => "ws://${HOST}:${PORT}/${PASS}",
)->get;

$loop->run;

exit 0;
