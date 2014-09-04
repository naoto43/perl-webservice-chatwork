#!/usr/bin/perl

#
# chatwork-bot.pl TOKEN EMAIL PASSWORD ROOM_NAME
#

use strict;
use WebService::Chatwork;
use File::Touch;
use utf8;
use Encode;

my %p;
($p{access_token},$p{email},$p{password},$p{room_name}) = @ARGV;

WebService::Chatwork->new(%p)->watch($p{room_name},{
    'omikuji' => sub {
	my ($chatwork,$room,$log) = @_;
	my @omikuji = ("大吉!!!", "中吉!!", "小吉!", "末吉", "凶orz","また菅井君か..");
	my $body = sprintf "[rp aid=%s to=%s-%s] \n%s",
	    $log->{aid},$room->{room_id},$log->{id},
		Encode::encode('utf8',$omikuji[ int rand(6) ]);
	warn $body;
	
	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => $body }
	);
    },
});

=head1 AUTHOR

  Naoto ISHIKAWA <toona@seesaa.co.jp>

=cut

__END__
