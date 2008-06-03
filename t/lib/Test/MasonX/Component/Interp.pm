package Test::MasonX::Component::Interp;

use strict;
use warnings;
use base qw/MasonX::Component::Interp/;

sub registry_class {
    return 'Test::MasonX::Component::Registry';
}

1;
