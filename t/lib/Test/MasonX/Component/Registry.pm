package Test::MasonX::Component::Registry;

use strict;
use warnings;
use base qw/MasonX::Component::Registry/;

sub conf_prefix {
    return $::scratch_space->base->stringify;
}

1;
