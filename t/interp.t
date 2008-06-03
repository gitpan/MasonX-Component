#!perl

use strict;
use warnings;
use File::Spec::Functions qw/catdir/;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN {
    eval 'use Directory::Scratch';
    plan skip_all => 'Directory::Scratch required' if $@;

    eval 'use Test::Exception';
    plan skip_all => 'Test::Exception required' if $@;

    plan tests => 5;

    {
        no warnings 'once';
        $::scratch_space = Directory::Scratch->new;
    }
}

use Test::MasonX::Component::Interp;

{
    my $comp_root = catdir($FindBin::Bin, 'root', 'test_comp');
    $::scratch_space->mkdir('registry.d');
    $::scratch_space->write('registry.d/MasonX::Component::Test', <<"EOC");
[MasonX::Component::Test]
priority = 5
comp_root = $comp_root
EOC
}

lives_ok(sub {
        Test::MasonX::Component::Interp->new;
}, 'falls back to default comp_root if not set');

throws_ok(sub {
        Test::MasonX::Component::Interp->new(comp_root => '');
}, qr/comp_root path/, "doesn't touch comp_path if it's set already");

{
    my $interp;
    lives_ok(sub {
            $interp = Test::MasonX::Component::Interp->new(
                    comp_root => catdir($FindBin::Bin, 'root', 'main'),
                    out_method => sub { },
            );
    }, 'new');

    isa_ok($interp, 'Test::MasonX::Component::Interp');

    lives_ok(sub {
            $interp->exec('/test', foo => 'bar');
    }, 'exec');
}
