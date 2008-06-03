#!perl

use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN {
    eval 'use Directory::Scratch';
    plan skip_all => 'Directory::Scratch required' if $@;

    eval 'use Test::Exception';
    plan skip_all => 'Test::Exception required' if $@;

    plan tests => 23;

    $::scratch_space = Directory::Scratch->new;
}

use Test::MasonX::Component::Registry;

END {
    undef $::scratch_space; # cleanup
}

my $component = 'MasonX::Component::Test';
my $attrs = {
    priority   => 5,
    components => [qw/foo bar moo/],
    comp_root  => q{/some/path/},
};

throws_ok(sub {
        Test::MasonX::Component::Registry->component_info($component);
}, qr/not registered/, 'component info on unregistered component throws exception');

throws_ok(sub {
        Test::MasonX::Component::Registry->register_component(
                $component => {
                        %{ $attrs },
                        invalid => [qw/foo bar/],
                },
        );
}, qr/only field `components' is allowed to be a reference/, 'only components may be an array reference');

throws_ok(sub {
        Test::MasonX::Component::Registry->register_component(
                $component => {
                    %{ $attrs },
                    components => { foo => 'bar' },
                },
        );
}, qr/field `components' needs to be an array reference/, 'components must be an array reference');

lives_ok(sub {
        Test::MasonX::Component::Registry->register_component(
                $component => $attrs,
        );
}, 'registering component');

throws_ok(sub {
        Test::MasonX::Component::Registry->register_component(
                $component => $attrs,
        );
}, qr/already registered/, 'registering twice throws exception');

{
    ok(my $path = $::scratch_space->exists('registry.d'), 'registry.d created');
    ok(-d $path, 'registry.d is a directory');
}

{
    my $file = "registry.d/$component";

    ok(my $path = $::scratch_space->exists($file), 'component path created');
    ok(-f $path, 'component path is a file');

    like(scalar $::scratch_space->read($file), qr/foo, bar, moo/, 'components got stringified');
}

{
    my $attrs_got;
    lives_ok(sub {
            $attrs_got = Test::MasonX::Component::Registry->component_info($component);
    }, 'component_info');

    is_deeply($attrs_got, $attrs, 'deserializing component info');
}

{
    my %overrides = (
        priority => 10,
    );

    lives_ok(sub {
            Test::MasonX::Component::Registry->set_component_attributes(
                    $component => \%overrides,
            );
    }, 'set_component_attributes');

    ok(-f Test::MasonX::Component::Registry->conf_file, 'conf file was created');

    my $attrs_got;
    lives_ok(sub {
            $attrs_got = Test::MasonX::Component::Registry->component_info($component);
    }, 'component_info with overrides');

    is_deeply($attrs_got, { %{ $attrs }, %overrides }, 'overrides got applied');

    lives_ok(sub {
            Test::MasonX::Component::Registry->set_component_attributes(
                    $component => { comp_root => '/foo/bar', },
            );
    }, 'set_component_attributes');

    lives_ok(sub {
            $attrs_got = Test::MasonX::Component::Registry->component_info($component);
    }, 'component_info with overrides');

    is_deeply($attrs_got, { %{ $attrs }, %overrides, comp_root => '/foo/bar', }, 'overrides got applied');

    lives_ok(sub {
            Test::MasonX::Component::Registry->unset_component_attributes(
                $component => [keys %overrides],
            );
    }, 'unset_component_attributes');

    lives_ok(sub {
            $attrs_got = Test::MasonX::Component::Registry->component_info($component);
    }, 'component_info with overrides');

    is_deeply($attrs_got, { %{ $attrs }, comp_root => '/foo/bar', }, 'overrides got applied');

    is_deeply([Test::MasonX::Component::Registry->comp_roots], [
            [ test => '/foo/bar' ],
    ], 'comp_roots');
}
