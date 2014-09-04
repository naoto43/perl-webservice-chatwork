#!/usr/bin/perl

#
# chatwork-bot.pl TOKEN EMAIL PASSWORD ROOM_NAME
#

my %p;
($p{access_token},$p{email},$p{password},$p{room_name}) = @ARGV;

WebService::Chatwork->new(%p)->watch($p{room_name},{
    'callstart' => sub {
	my ($chatwork,$room,$log) = @_;
	warn qq/callstart/;
	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => '[START]' }
	);
    },
    'callstop'  => sub {
	my ($chatwork,$room,$log) = @_;
	warn qq/callstop/;
	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => '[STOP]' }
	);
    },
    'callstatus'  => sub {
	my ($chatwork,$room,$log) = @_;
	warn qq/calltatus/;
	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => '[STATUS]' }
	);
    },
});

=head1 AUTHOR

  Naoto ISHIKAWA <toona@seesaa.co.jp>

=cut

__END__
