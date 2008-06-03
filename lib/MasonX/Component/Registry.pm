package MasonX::Component::Registry;

use strict;
use warnings;
use Carp;
use Clone ();
use IO::Dir;
use IO::File;
use Hash::Merge;
use File::Path ();
use File::ShareDir ();
use Class::Inspector;
use File::Spec::Functions qw/catdir catfile/;

=head1 METHODS

=head2 register_component

=over 4

=item Arguments: $component_name, \%attributes

=item Return Value:

=back

=cut

sub register_component {
    my ($self, $component, $attrs) = @_;

    my $component_path = $self->build_config_path($component);

    if (-f $component_path) {
        croak "Component $component already registered";
    }

    my $fh = IO::File->new($component_path, 'w')
        or croak "Failed to open component config `$component_path' for writing: $!";

    eval {
        $self->writer->write_handle({
                $component => $attrs,
        }, $fh);
    };

    if (my $error = $@) {
        $fh->close;
        unlink $component_path;

        croak $error;
    }

    $fh->close;

    return;
}

=head2 install_component

=over 4

=item Arguments: $component_name, \%attrs

=item Return Value: none

=back

=cut

sub install_component {
    my ($self, $component, $attrs) = @_;

    eval {
        $self->unregister_component($component);
    };

    die if $@;

    $self->register_component($component, $attrs);

    return;
}

=head2 set_component_attributes

=over 4

=item Arguments: $component_name, \%attributes

=item Return Value: none

=back

=cut

sub set_component_attributes {
    my ($self, $component, $attrs) = @_;

    my $overrides     = $self->get_overrides;
    my $new_overrides = Hash::Merge::merge({ $component => $attrs }, $overrides);

    eval {
        $self->set_overrides($new_overrides);
    };

    if (my $error = $@) {
        eval {
            $self->set_overrides($overrides);
        };

        croak $@ if $@;
    }

    return;
}

=head2 unset_component_attributes

=over 4

=item Arguments: $component_name, \@attribute_names

=item Return Value: none

=back

=cut

sub unset_component_attributes {
    my ($self, $component, $keys) = @_;

    my $overrides = $self->get_overrides;

    if (exists $overrides->{$component}) {
        my $new_overrides = Clone::clone($overrides);

        delete $new_overrides->{$component}->{$_}
            for @{ $keys };

        eval {
            $self->set_overrides($new_overrides);
        };

        if (my $error = $@) {
            eval {
                $self->set_overrides($overrides);
            };

            croak $@ if $@;
        }
    }

    return;
}

=head2 get_overrides

=over 4

=item Arguments: none

=item Return Value: \%attributes

=back

=cut

sub get_overrides {
    my ($self) = @_;

    return +{}
        if !-f $self->conf_file;

    my $fh = IO::File->new($self->conf_file, 'r')
        or croak "Failed to open config file for reading: $!";

    my $overrides = $self->reader->read_handle($fh);

    $fh->close;
    return $overrides;
}

=head2 set_overrides

=over 4

=item Arguments: \%attributes

=item Return Value: none

=back

=cut

sub set_overrides {
    my ($self, $overrides) = @_;

    my $fh = IO::File->new($self->conf_file, 'w')
        or croak "Failed to open config file for writing: $!";

    eval {
        $self->writer->write_handle($overrides, $fh);
    };

    my $error = $@;
    $fh->close;

    croak $error if $error;

    return;
}

=head2 comp_roots

=over 4

=item Arguments: none

=item Return Value: @comp_roots

=back

=cut

sub comp_roots {
    my ($self) = @_;

    my $dir = IO::Dir->new($self->conf_dir)
        or croak "Failed to open config directory: $!";

    my @comp_roots;

    while (defined (my $file = $dir->read)) {
        next if $file =~ /^\.{1,2}$/;

        my $attrs;
        eval {
            $attrs = $self->component_info($file);
        };

        if (my $error = $@) {
            warn $error;
            next;
        }

        next unless defined $attrs;
        next unless defined $attrs->{comp_root};

        my $moniker = $attrs->{moniker};

        if (!$moniker) {
            ($moniker = lc $file) =~ s/.*:://;
        }

        #TODO: sort by priority field
        push @comp_roots, [ $moniker => $attrs->{comp_root} ],
    }

    $dir->close;

    return @comp_roots;
}

=head2 unregister_component

=over 4

=item Arguments: $component_name

=item Return Value:

=back

=cut

sub unregister_component {
    my ($self, $component) = @_;

    my $component_path = $self->build_config_path($component);
    if (!unlink $component_path) {
        croak "Failed to remove component config: $!";
    }

    return;
}

=head2 component_info

=over 4

=item Arguments: $component_name

=item Return Value: \%component_attributes

=back

=cut

sub component_info {
    my ($self, $component) = @_;

    my $component_path = $self->build_config_path($component);

    if (!-f $component_path) {
        croak "Component $component not registered";
    }

    my $attrs = $self->read_file($component_path);
    $attrs = $self->apply_overrides($attrs);

    if (!exists $attrs->{$component}) {
        croak "Component config didn't contain any information on requested component $component";
    }

    return $attrs->{$component};
}

=head2 apply_overrides

=over 4

=item Arguments: \%attributes

=item Return Value: \%modified_attributes

=back

=cut

sub apply_overrides {
    my ($self, $attrs) = @_;

    my $overrides = $self->get_overrides;

    return Hash::Merge::merge($overrides, $attrs);
}

=head2 read_file

=over 4

=item Arguments: $path

=item Return Value: \%attributes

=back

=cut

sub read_file {
    my ($self, $path) = @_;

    my $fh = IO::File->new($path, 'r')
        or croak "Failed to open component config `$path' for reading: $!";

    my $attrs = $self->reader->read_handle($fh);

    $fh->close;

    return $attrs;
}

=head2 conf_prefix

=over 4

=item Arguments: none

=item Return Value: $path

=back

=cut

sub conf_prefix {
    my ($self) = @_;

    my $dir;

    eval {
        $dir = File::ShareDir::module_dir($self);
    };

    if (my $error = $@) { #FIME: fragile
        ($dir) = $error =~ /Directory '(.*)', does not exist/;
    }

    if (!-d $dir) {
        File::Path::mkpath($dir);
    }

    return $dir;
}

=head2 conf_file

=over 4

=item Arguments: none

=item Return Value: $path

=back

=cut

sub conf_file {
    my ($self) = @_;

    return catfile($self->conf_prefix, 'registry.ini');
}

=head2 conf_dir

=over 4

=item Arguments: none

=item Return Value: $path

=back

=cut

sub conf_dir {
    my ($self) = @_;

    my $dir = catdir($self->conf_prefix, 'registry.d');

    if (!-d $dir) {
        File::Path::mkpath($dir);
    }

    return $dir;
}

=head2 build_config_path

=over 4

=item Arguments: $component_name

=item Return Value: $path

=back

=cut

sub build_config_path {
    my ($self, $component) = @_;

    return catfile($self->conf_dir, $component);
}

=head2 reader_class

=over 4

=item Arguments: none

=item Return Value: $class

=back

=cut

sub reader_class {
    return 'MasonX::Component::Registry::Reader';
}

=head2 writer_class

=over 4

=item Arguments: none

=item Return Value: $class

=back

=cut

sub writer_class {
    return 'MasonX::Component::Registry::Writer';
}

=head2 reader

=over 4

=item Arguments: none

=item Return Value: $class

=back

=head2 writer

=over 4

=item Arguments: none

=item Return Value: $class

=back

=cut

{
    for my $meth (qw/reader writer/) {
        no strict 'refs'; ## no critic (ProhibitNoStrict)

        *{ $meth } = sub {
            my ($self) = @_;

            my $get_class = "${meth}_class";
            my $class     = $self->$get_class;

            $self->ensure_class_loaded($class);

            return $class;
        };
    }
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
