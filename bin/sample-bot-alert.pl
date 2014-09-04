#!/usr/bin/perl

#
# chatwork-bot.pl TOKEN EMAIL PASSWORD ROOM_NAME
#
use strict;
use WebService::Chatwork;
use File::Touch;

my $control_dir = '/home/patlite/bin/';
my $callstop   = '/home/patlite/bin/.callstop';
my $callenable = '/home/patlite/bin/.callenable';

my %p;
($p{access_token},$p{email},$p{password},$p{room_name}) = @ARGV;

WebService::Chatwork->new(%p)->watch($p{room_name},{
    'callstart' => sub {
	my ($chatwork,$room,$log) = @_;
	warn qq/callstart/;
	if (-d $control_dir && -e $callstop) {
	    unlink $callstop;
	}
	if (-d $control_dir && -e $callenable) {
	    unlink $callenable;
	}
	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => '[START]' }
	);
    },
    'callstop'  => sub {
	my ($chatwork,$room,$log) = @_;
	warn qq/callstop/;
	if (-d $control_dir) {
	    touch $callstop;
	}

	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => '[STOP]' }
	);
    },
    'callstatus'  => sub {
	my ($chatwork,$room,$log) = @_;
	warn qq/calltatus/;

	my $messages = 'RUNNING';

	if (-e $callstop) {
	    $messages = 'DOWN';
	}
	
	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => '[STATUS] ' . $messages  }
	);
    },
});

=head1 AUTHOR

  Naoto ISHIKAWA <toona@seesaa.co.jp>

=cut

__END__
