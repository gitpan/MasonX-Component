#!perl

use strict;
use warnings;
use MasonX::Component::Interp;

use FindBin;

my $i = MasonX::Component::Interp->new(comp_root => "$FindBin::Bin/test");
print $i->exec('/foo');
