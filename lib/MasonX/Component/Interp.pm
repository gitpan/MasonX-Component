package MasonX::Component::Interp;

use strict;
use warnings;
use Carp;
use Class::Inspector;
use Scalar::Util qw/reftype/;
use base qw/HTML::Mason::Interp/;

=head1 METHODS

=head2 new

=over 4

=item Arguments: %params

=item Return Value: $interp

=back

=cut

sub new {
    my ($self, %attrs) = @_;

    my $comp_root = exists $attrs{comp_root}
        ? $attrs{comp_root}
        : $self->validation_spec->{comp_root}->{default};

    if (!ref $comp_root) {
        $comp_root = [ [ MAIN => $comp_root ] ];
    }

    if (reftype $comp_root eq 'ARRAY') {
        my @additional_comp_roots = $self->registry->comp_roots;
        push @{ $comp_root }, @additional_comp_roots;
    }

    $attrs{comp_root} = $comp_root;

    return $self->SUPER::new(%attrs);
}

=head2 registry_class

=over 4

=item Arguments: none

=item Return Value: $class

=back

=cut

sub registry_class {
    return 'MasonX::Component::Registry';
}

=head2 registry

=over 4

=item Arguments: none

=item Return Value: $class

=back

=cut

sub registry {
    my ($self) = @_;

    my $class = $self->registry_class;
    $self->ensure_class_loaded($class);

    return $class;
}

=head2 ensure_class_loaded

=over 4

=item Arguments: none

=item Return Value: none

=back

=cut

sub ensure_class_loaded {
    my ($self, $class) = @_;

    croak "Invalid class name $class"
        if $class =~ /(?:\b:\b|\:{3,})/;

    return if Class::Inspector->loaded($class);

    eval "require $class";
    if (my $error = $@) {
        croak $error;
    }

    return;
}

1;
