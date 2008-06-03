package MasonX::Component;

use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;

1;

__END__
=head1 NAME

MasonX::Component - manage mason components

=head1 SYNOPSIS

    use MasonX::Component::Interp;

    my $interp = MasonX::Component::Interp->new;
    $interp->exec('/component');

=head1 DESCRIPTION

This distribution contains infrastructure to manage systemwide installed mason
components. It's intended to be used to install mason components from CPAN and
use them in your applications.

This works by registering components at installation time with
L<MasonX::Component::Registry|MasonX::Component::Registry> and using
L<MasonX::Component::Interp|MasonX::Component::Interp> instead of
L<HTML::Mason::Interp|HTML::Mason::Interp> which will automatically pick up all
components registered in the registry.

=head1 WRITING COMPONENTS

Writing MasonX::Component components is easy. They are just normal CPAN
distributions with the following differences:

=over 4

=item They contain a directory with mason components which needs to be installed next to the things in lib/.

=item They need to register their components with L<MasonX::Registry> at installation time.

=back

If you happen to like L<Module::Install|Module::Install>, do the following:

=over 4

=item create a C<component> directory

Put all your components in there.

=item create a C<component.ini> file

This contains meta information of your components:

    [MasonX::Component::YourDistribution]
    priority = 5
    components = foo, bar

=item depend on L<MasonX::Component>

Makefile.PL:

    requires 'MasonX::Component' => 0;

=item install and register your components

Makefile.PL:

    mason_component;

This will automatically install files in C<component> and register them with
the information in L<component.ini> when you run C<make install>.

=back

=head1 BUGS AND LIMITATIONS

Currently L<MasonX::Component::Interp|MasonX::Component::Interp> puts all
registered components into the comp_root. A mechanism to only use requested
components or exclude certain things is planned but not implemented yet.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-masonx-component@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 SEE ALSO

=over 4

=item L<HTML::Mason>

=item L<HTML::Mason::Interp>

=item L<MasonX::Component::Registry>

=item L<MasonX::Component::Interp>

=back

=head1 AUTHOR

Florian Ragwitz  C<< <rafl@debian.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Florian Ragwitz C<< <rafl@debian.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
