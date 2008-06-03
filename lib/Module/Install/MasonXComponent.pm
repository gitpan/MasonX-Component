## no critic
package Module::Install::MasonXComponent;

use strict;
use Module::Install::Base;

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
    $VERSION = '0.01';
    $ISCORE  = 0;
    @ISA     = qw{Module::Install::Base};
}

=head1 METHODS

=head2 mason_component

=over 4

=item Arguments: $directory?

=item Return Value: none

=back

=cut

sub mason_component {
    my ($self, $dir) = @_;

    $dir ||= 'component';

    my %dests = (
            site   => 'DESTINSTALLSITELIB',
            vendor => 'DESTINSTALLVENDORLIB',
            perl   => 'DESTINSTALLPRIVLIB',
    );

my $register_proto = <<"EOR";
register_%s_component ::
\t\$(FULLPERL) -MMasonX::Component::Registry \\
\t\t-e"MasonX::Component::Registry->install_component(q(\$(NAME)), {\\
\t\t%\{ MasonX::Component::Registry->reader->read_file(q(component.ini))->{\$(NAME)} }, \\
\t\tcomp_root => q(\$(%s)\$(DFSEP)auto\$(DFSEP)\$(FULLEXT))})"

EOR

    my $register = join ('', map {
            sprintf $register_proto, $_, $dests{$_}
    } keys %dests);

    $self->postamble(<<"END_MAKEFILE");
config ::
\t\$(NOECHO) \$(MOD_INSTALL) \\
\t\t"$dir" \$(INST_AUTODIR)\$(DFSEP)_component

install :: register_component

register_component :: register_\$(INSTALLDIRS)_component

register__component :: register_site_component
\t\$(NOECHO) \$(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

$register
END_MAKEFILE

    # The above appears to behave incorrectly when used with old versions
    # of ExtUtils::Install (known-bad on RHEL 3, with 5.8.0)
    # So when we need to install a share directory, make sure we add a
    # dependency on a moderately new version of ExtUtils::MakeMaker.
    $self->build_requires( 'ExtUtils::MakeMaker' => '6.11' );

    return;
}

1;
