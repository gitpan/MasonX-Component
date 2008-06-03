use Test::More tests => 4;

BEGIN {
    use_ok('MasonX::Component');
    use_ok('MasonX::Component::Interp');
    use_ok('MasonX::Component::Registry');
    use_ok('Module::Install::MasonXComponent');
}

diag( "Testing MasonX::Component $MasonX::Component::VERSION" );
