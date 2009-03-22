package Geo::Google::StaticMaps::Navigation;
use Any::Moose;
use URI;
use Storable;
use Geo::Coordinates::Converter;
our $VERSION = '0.01';
use constant baseurl => 'http://maps.google.com/staticmap';

has key => ( isa => 'Str', is => 'ro', required => 1);
has center => ( isa => 'Geo::Coordinates::Converter', is => 'rw' );
has width => ( isa => 'Int', is => 'ro', required => 1);
has height => ( isa => 'Int', is => 'ro', required => 1);
has span => ( isa => 'Num', is => 'rw');
has zoom_ratio => ( isa => 'Num', is => 'ro', required => 1, default => 1.5 );
has markers => ( isa => 'ArrayRef', is => 'rw', auto_deref => 1, );

sub url {
    my ($self) = @_;
    my $uri = URI->new(baseurl);
    $uri->query_form(
        center => join(',', $self->center->lat, $self->center->lng),
        size => join('x', $self->width, $self->height),
        key => $self->key,
        span => join(',', $self->span, $self->span),
        markers => join('|', map {join(',', $_->lat, $_->lng)} $self->markers ),
    );
    return $uri;
}

sub params {
    my ($self) = @_;
    return {
        span => $self->span,
        lat => $self->center->lat,
        lng => $self->center->lng,
    };
}

sub clone {
    Storable::dclone(shift);
}

sub north {$_[0]->nearby({lat => 1})};
sub south {$_[0]->nearby({lat => -1})};
sub east {$_[0]->nearby({lng => 1})};
sub west {$_[0]->nearby({lng => -1})};

sub nearby {
    my ($self, $args) = @_;
    my $clone = $self->clone;
    my $center = Geo::Coordinates::Converter->new(
        latitude => $clone->center->lat + ($clone->span * ($args->{lat} || 0)),
        longitude => $clone->center->lng + ($clone->span * ($args->{lng} || 0)),
    );
    $clone->center($center);
    return $clone;
}

sub zoom_in {$_[0]->scale($_[0]->zoom_ratio)}
sub zoom_out {$_[0]->scale(1 / $_[0]->zoom_ratio)}

sub scale {
    my ($self, $arg) = @_;
    my $clone = $self->clone;
    $clone->span(sprintf("%3.3f", $clone->span * $arg));
    return $clone;
}

1;
__END__

=head1 NAME

Geo::Google::StaticMaps::Navigation -

=head1 SYNOPSIS

  use Geo::Google::StaticMaps::Navigation;

=head1 DESCRIPTION

Geo::Google::StaticMaps::Navigation is

=head1 METHODS

=head2 new

constructor.

=head2 url

returns url for google static maps.

=head2 params

returns params for next map page (not for map image).

=head2 clone

returns cloned object.

=head2 nearby

returns nearby map.

=head2 north, south, west, east

returns nearby map for each direction.

=head2 scale

returns scaled map with specified ratio.

=head2 zoom_in, zoom_out

returns scaled map with default ratio.

=head1 AUTHOR

Nobuo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
