#!perl

use strict;
use warnings;
use inc::Module::Install;

name 'MasonX-Component';
all_from 'lib/MasonX/Component.pm';

requires 'Carp'                  => 0;
requires 'Class::Inspector'      => 0;
requires 'Clone'                 => 0;
requires 'Config::INI::Reader'   => 0;
requires 'Config::INI::Writer'   => 0;
requires 'File::Path'            => 0;
requires 'File::ShareDir'        => 0;
requires 'File::Spec::Functions' => 0;
requires 'Hash::Merge'           => 0;
requires 'HTML::Mason'           => 0;
requires 'IO::Dir'               => 0;
requires 'IO::File'              => 0;
requires 'Scalar::Util'          => 0;
requires 'Test::More'            => 0;

auto_provides;
extra_tests;

WriteAll;

package MY;

sub postamble {
    return <<"EOM";
testcover: pm_to_blib
\t-HARNESS_PERL_SWITCHES=-MDevel::Cover PERL_DL_NONLAZY=1 \$(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness(\$(TEST_VERBOSE), 'inc', '\$(INST_LIB)', '\$(INST_ARCHLIB)')" \$(TEST_FILES)
\tcover

Changes: .git/refs/heads/master
\tgit-changelog Changes
EOM
}
