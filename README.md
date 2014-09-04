chatwork-bot
============

chatwork bot sample
===================

  chatwork-bot.pl TOKEN EMAIL PASSWORD ROOM_NAME

NAME
===================
      WebService::Chatwork - chatwork api

DESCRIPTION
===================
  ```
  my $chatwork = WebService::Chatwork->new( api_access_token => 'XXX', email => 'your@email', password => 'passwor$
  my $messages = $chatwork->get_messages('12345');
  $chatwork->api('post','/room/12345/messages',{ foo => 'bar' });
  ```
      
Methods
===================
new
-------------------

  ```
      WebService::Chatwork->new(api_access_token => 'XXX', email => 'your@email', password => 'password');
  ```

- PARAMS

      ```
      api_access_token: chatwork office makes it if you request
      email,password: chatowrk login email and password. it depends on web scraping to get rooms messages.because we can't get it via chatwork APIs.
      ```

get_messages
-------------------

- get list of message from web scraping

      ```
       $chat_list = $chatwork->get_messages($room_id);
      ```

- returns arrayref

      ```
      chat_list' => [
      {
          'utm' => 0,
          'id' => 198581466,
          'msg' => '[info][dtext:chatroom_mychat_created][/info]',
          'aid' => 829582,
          'tm' => 1386225855
      },
      {
          'aid' => 829582,
          'utm' => 0,
          'msg' => "\x{3075}\x{3041}\x{ff53}\x{ff44}\x{ff46}\x{3060}\x{ff53}",
          'id' => 394380493,
          'tm' => 1409764415
      }
      ```

api
-----------------

- call chatwork api

      ```
        <http://developer.chatwork.com/ja/>

        $chatwork->api(
            'post','/rooms/' . $room->{room_id} . '/messages',
            { body => '[STOP]' }
        );
      ```

- PARAMS

      ```
        method: get,post,put,delete
        path: api path
        param: api param

      ```

watch
----------------

- makebot. checking room per 10 sec

      ```
        $chatwork->watch($room_name,{
          'callbackname' => sub {
              my ($chatwork,$room,$log) = @_;
              $chatwork->api(
                  'post','/rooms/' . $room->{room_id} . '/messages',
                  { body => '[TEST]' }
              );
        });
      ```


- PARAMS

      ```
       room_name: target room name
       callback:
         callback_name: name of callback. callback is called if chat message equals callback name.
         callback: subroutine. it takes 3 args. chatwork instance, room data and message data.

      ```

- if you set 'all' as callback_name. it's always executed on loop.

      ```
        $chatwork->watch({
          'all' => sub {
              my ($chatwork,$room,$log) = @_;
              # xxx
        });
      ```

AUTHOR
================

      Naoto ISHIKAWA <toona@seesaa.co.jp>
