package MasonX::Component::Registry::Writer;

use strict;
use warnings;
use Carp;
use base qw/Config::INI::Writer/;

=head1 METHODS

=head2 validate_input

=over 4

=item Arguments: $data

=item Return Value: none

=back

=cut

sub validate_input {
    my ($self, $data) = @_;

    $self->SUPER::validate_input($data);

    for (my $i = 0; $i < $#$data; $i += 2) {
        my ($name, $props) = @$data[ $i, $i + 1 ];

        for (my $j = 0; $j < $#$props; $j += 2) {
            if ($props->[ $j ] eq 'components') {
                croak "field `components' needs to be an array reference"
                    if ref $props->[ $j + 1 ] ne 'ARRAY';
            }
            else {
                croak "only field `components' is allowed to be a reference"
                    if ref $props->[ $j + 1 ];
            }
        }
    }
}

=head2 stringify_value_assignment

=over 4

=item Arguments: $name, $value

=item Return Value: $string

=back

=cut

sub stringify_value_assignment {
    my ($self, $name, $value) = @_;

    if ($name ne 'components') {
        return $self->SUPER::stringify_value_assignment($name, $value);
    }

    return $self->SUPER::stringify_value_assignment($name, join q{, }, @{$value});
}

1;
