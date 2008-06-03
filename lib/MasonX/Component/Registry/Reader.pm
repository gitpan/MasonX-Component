package MasonX::Component::Registry::Reader;

use strict;
use warnings;
use base qw/Config::INI::Reader/;

=head1 METHODS

=head2 set_value

=over 4

=item Arguments: $name, $value

=item Return Value: $value | \@value

=back

=cut

sub set_value {
    my ($self, $name, $value) = @_;

    if ($name ne 'components') {
        return $self->SUPER::set_value($name, $value);
    }

    return $self->SUPER::set_value($name, [split /,\s+/, $value]);
}

1;
