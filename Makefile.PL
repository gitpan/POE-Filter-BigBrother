require 5.004_04;
use Config;
use ExtUtils::MakeMaker;

$| = 1;

WriteMakefile(
               NAME          => 'POE::Filter::BigBrother',
               AUTHOR        => 'Yves Blusseau',
               VERSION_FROM  => 'lib/POE/Filter/BigBrother.pm',
               ABSTRACT_FROM => 'lib/POE/Filter/BigBrother.pm',
               PL_FILES      => {},
               PREREQ_PM     => {
                              'POE'                       => 0.38,
                            },
               dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
               clean => { FILES => 'POE-Filter-BigBrother-*' }
             );
