use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WebService::Chatwork',
    AUTHOR              => q{Naoto ISHIKAWA <toona at seesaa.co.jp>},
    VERSION_FROM        => 'lib/WebService/Chatwork.pm',
    ABSTRACT_FROM       => 'lib/WebService/Chatwork.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
	"Carp" => 0,
	"WWW::Mechanize" => 0,
	"JSON" => 0,
	"Furl" => 0,
        "Test::More" => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WebService-Chatwork-*' },
);
