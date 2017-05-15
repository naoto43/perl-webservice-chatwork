package WebService::Chatwork;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";


=encoding utf-8

=head1 NAME

WebService::Chatwork - chatwork api for perl

=head1 SYNOPSIS

    use WebService::Chatwork;
    my $chatwork = WebService::Chatwork->new( api_access_token => 'XXX', email => 'your@email', password => 'password', );
    my $messages = $chatwork->get_messages('12345');
    $chatwork->api('post','/room/12345/messages',{ foo => 'bar' });

=head1 DESCRIPTION

WebService::Chatwork is ..

=head1 Methods

=head2 new

  WebService::Chatwork->new(api_access_token => 'XXX', email => 'your@email', password => 'password')

  # PARAMS
  #   api_access_token: chatwork office makes it if you request
  #   email,password: chatowrk login email and password. it depends on web scraping to get rooms messages.
  #                   because we can't get it via chatwork APIs.

=head2 get_messages

  # get list of message from web scraping
  $chat_list = $chatwork->get_messages($room_id);

  # returns arrayref
  #     'chat_list' => [
  #	 {
  #	     'utm' => 0,
  #	     'id' => 198581466,
  #	     'msg' => '[info][dtext:chatroom_mychat_created][/info]',
  #	     'aid' => 829582,
  #	     'tm' => 1386225855
  #	 },
  #	 {
  #	     'aid' => 829582,
  #	     'utm' => 0,
  #	     'msg' => "\x{3075}\x{3041}\x{ff53}\x{ff44}\x{ff46}\x{3060}\x{ff53}",
  #	     'id' => 394380493,
  #	     'tm' => 1409764415
  #	 }
  

=head2 api

  # call chatwork api 
  # <http://developer.chatwork.com/ja/>

  $chatwork->api(
      'post','/rooms/' . $room->{room_id} . '/messages',
      { body => '[STOP]' }
  );

  # PARAMS
  #   method: get,post,put,delete
  #   path: api path
  #   param: api param

=head2 watch

  #  makebot. checking room per 10 sec

  $chatwork->watch($room_name,{
    'callbackname' => sub {
	my ($chatwork,$room,$log) = @_;
	$chatwork->api(
	    'post','/rooms/' . $room->{room_id} . '/messages',
	    { body => '[TEST]' }
	);
  });

  # PARAMS
  #  room_name: target room name
  #  callback:
  #    callback_name: name of callback. callback is called if chat message equals callback name. 
  #    callback: subroutine. it takes 3 args. chatwork instance, room data and message data.

  # if you set 'all' as callback_name. it's always executed on loop.

  $chatwork->watch({
    'all' => sub {
	my ($chatwork,$room,$log) = @_;
        # xxx
  });


=cut


use WWW::Mechanize;
use JSON;
use Data::Dumper;
use Furl;
use Carp;

our $CHATWORK_LOGIN_URL       = 'https://www.chatwork.com/login.php?lang=ja';
our $CHATWORK_LOGIN_FORM_NAME = 'login';
our $CHATWORK_LOAD_CHAT_URL   = "https://www.chatwork.com/gateway.php?cmd=load_chat&myid=%s&_v=%s&_t=%s&ln=%s&room_id=%s&last_chat_id=0&first_chat_id=0&jump_to_chat_id=0&unread_num=0&desc=0&_=%s";

our $CHATWORK_API_URL         = 'https://api.chatwork.com/v2';

our $DEBUG = 0;

sub new {
    my $class = shift;
    my %params = @_;
    
    for (qw(email password access_token)) {
        Carp::croak('no: ' . $_) unless defined $params{$_} ;
    }
    
    my $furl = Furl->new(timeout => 10);
    my $mech = WWW::Mechanize->new();
    
    $mech->get($CHATWORK_LOGIN_URL);
    
    $mech->submit_form(
        form_name => $CHATWORK_LOGIN_FORM_NAME,
        fields    => {
            email    => $params{email},
            password => $params{password}
        }
    );
    
    my $content = $mech->content;
    my %web_params;
    ($web_params{ACCESS_TOKEN}) = $content =~ m/var +?ACCESS_TOKEN +?\= +?\'([0-9a-f]+)\'\;/;
    ($web_params{LANGUAGE})     = $content =~ m/var +?LANGUAGE +?\= +?\'([a-z]+)\'\;/;
    ($web_params{myid})         = $content =~ m/var +?MYID +?\= +?\'([0-9]+)\'\;/;
    ($web_params{client_ver})   = $content =~ m/var +?CLIENT_VER +?\= +?\'([0-9a-z.]+)\'\;/;
    
    Carp::croak q/login failed/  unless $web_params{ACCESS_TOKEN};
    
    my $self =  bless { 
        _params     => \%params,
        _web_params => \%web_params,
        _furl       => $furl,
        _mech       => $mech,
    }, $class;
    my $res = $self->api('get','/me');
    Carp::croak q/fail calling api/ unless $res;

    return $self;
}

sub mech { shift->{_mech} }

sub furl { shift->{_furl} }

sub params     { shift->{_params} }

sub web_params { shift->{_web_params} }

sub get_messages {
    my $self = shift;
    my $room_id = shift or Carp::croak q/no room id/;
    my $load_chat_url = sprintf $CHATWORK_LOAD_CHAT_URL,
        (map { $self->web_params->{$_} } qw(myid client_ver ACCESS_TOKEN LANGUAGE)),$room_id,time();
    $self->mech->get($load_chat_url);
    my $json = $self->mech->content;
    # $VAR1 = {
    # 	'status' => {
    # 	    'success' => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' )
    #      },
    # 	 'result' => {
    # 	     'public_description' => '',
    # 	     'chat_list' => [
    # 		 {
    # 		     'utm' => 0,
    # 		     'id' => 198581466,
    # 		     'msg' => '[info][dtext:chatroom_mychat_created][/info]',
    # 		     'aid' => 829582,
    # 		     'tm' => 1386225855
    # 		 },
    # 		 {
    # 		     'aid' => 829582,
    # 		     'utm' => 0,
    # 		     'msg' => "\x{3075}\x{3041}\x{ff53}\x{ff44}\x{ff46}\x{3060}\x{ff53}",
    # 		     'id' => 394380493,
    # 		     'tm' => 1409764415
    # 		 }
    # 		 ],
    # 	     'description' => '[dtext:mychat_default_desc]'
    #      }
    # };
    my $res  = decode_json($json);
    if (ref $res eq 'HASH' && $res->{status}->{success} && ref $res->{result}->{chat_list}) {
        return $res->{result}->{chat_list};
    }
    return [];
}

sub api {
    my $self = shift;
    my $method = shift or Carp::croak q/no method/;
    my $path   = shift or Carp::croak q/no path/;

    my $param = shift;          #  hashref

    if (!$method =~ /^(get|post|delete|put)$/) {
        Carp::croak q/bad method/;
    }

    if ($method ne 'get') {
        Carp::croak q/no param/ unless $param;
    }

    my $url = $CHATWORK_API_URL . $path;

    my $res;
    
    if ($method =~ /^(get|delete)$/) {
        $res = $self->furl->$method($url, [ 'X-ChatWorkToken' => $self->params->{access_token} ]);
    } else {
        $res = $self->furl->$method($url, [ 'X-ChatWorkToken' => $self->params->{access_token} ], [ %$param ]);
    }

    if ($res->is_success) {
        return decode_json($res->content)
    }
    return;
}

sub watch {
    my $self  = shift;

    my $room_name = shift or Carp::croak q/no room_name/;
    my $callbacks = shift;

    if (! utf8::is_utf8($room_name)) {
        utf8::decode($room_name);
    }

    my $rooms = $self->api('get','/rooms');
    my ($room)  = grep { $_->{name} eq $room_name } @$rooms;

    unless ($room) {
        utf8::encode($room_name);
        Carp::croak q/no room: / . $room_name;
    }

    my $cache;

    while (1) {
        my $messages = $self->get_messages($room->{room_id});
        my $time = time - 60;
        for my $log (@$messages) {

            if (my $sub = $callbacks->{all}) {
                $sub->($self,$room,$log);
            }

            warn $time . " : " . $log->{tm} . ' : ' . $log->{msg} if $DEBUG;

            if ($time > $log->{tm} || $cache->{$log->{id}}) {
                next;
            }

            $cache->{$log->{id}} = 1;
	    
            if (my $sub = $callbacks->{$log->{msg}}) {
                $sub->($self,$room,$log);
            }
        }
        sleep 10;
    }
}


=head1 LICENSE

Copyright (C) Naoto ISHIKAWA.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Naoto ISHIKAWA E<lt>toona@seesaa.co.jpE<gt>

=cut


1;
__END__
