package Geo::Google::StaticMaps::Navigation;
use Any::Moose;
use 5.008_001;
use Any::Moose 'Util::TypeConstraints';
use URI;
use List::Util qw(max min);
use Storable;
use Geo::Coordinates::Converter;
our $VERSION = '0.01';

subtype 'Geo::Google::StaticMaps::Navigation::Types::URI'
    => as 'URI';

coerce 'Geo::Google::StaticMaps::Navigation::Types::URI'
    => from 'Str'
    => via { URI->new($_) };

subtype 'Geo::Google::StaticMaps::Navigation::Types::Point'
    => as 'Geo::Coordinates::Converter';

coerce 'Geo::Google::StaticMaps::Navigation::Types::Point'
    => from 'ArrayRef'
    => via { 
        Geo::Coordinates::Converter->new(
            latitude => $_->[0],
            longitude => $_->[1],
        );
    };

subtype 'Geo::Google::StaticMaps::Navigation::Types::PointList'
    => as 'ArrayRef[Geo::Coordinates::Converter]';

coerce 'Geo::Google::StaticMaps::Navigation::Types::PointList'
    => from 'ArrayRef[ArrayRef]'
    => via { 
        [ map {
        Geo::Coordinates::Converter->new(
            latitude => $_->[0],
            longitude => $_->[1],
        ) } @$_ ];
    };

subtype 'Geo::Google::StaticMaps::Navigation::Types::Span'
    => as 'Num'
    => where { ($_ >= 0.0025) && ($_ <= 40.96) };


has baseurl => (
    isa => 'Geo::Google::StaticMaps::Navigation::Types::URI',
    is => 'ro', 
    required => 1, 
    coerce => 1,
    default => sub {URI->new('http://maps.google.com/staticmap')},
);
has key => (
    is => 'ro', 
    isa => 'Str', 
    required => 1 
);
has center => ( 
    isa => 'Geo::Google::StaticMaps::Navigation::Types::Point', 
    is => 'rw', 
    coerce => 1,
);
has width => ( isa => 'Int', is => 'ro', required => 1 );
has height => ( isa => 'Int', is => 'ro', required => 1 );
has span => ( 
    is => 'rw',
    isa => 'Geo::Google::StaticMaps::Navigation::Types::Span', 
);
has markers => ( 
    isa => 'Geo::Google::StaticMaps::Navigation::Types::PointList', 
    is => 'rw', 
    coerce => 1,
    auto_deref => 1, 
);
has nearby_ratio => (isa => 'Num', is => 'ro', required => 1, default => 1.5);
has pageurl => (
    is => 'rw',
    isa => 'Geo::Google::StaticMaps::Navigation::Types::URI',
    coerce => 1,
);

sub url {
    my ($self) = @_;
    my $uri = $self->baseurl->clone;
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
        latitude => $clone->center->lat 
            + ($clone->span * $self->nearby_ratio * ($args->{lat} || 0)),
        longitude => $clone->center->lng 
            + ($clone->span * $self->nearby_ratio * ($args->{lng} || 0)),
    );
    $clone->center($center);
    $clone->_setup_pageurl($self);
    return $clone;
}

sub zoom_in {$_[0]->scale('in')}
sub zoom_out {$_[0]->scale('out')}

sub scale {
    my ($self, $arg) = @_;
    my ($min, $max) = (0.0025, 40.96);
    my $span = $min;
    while ($span <= $max) {
        if ($span >= $self->span) {
            $span = $arg eq 'in' ? max($min, $span/2) : min($max, $span*2);
            last;
        }
        $span *= 2;
    }
    my $clone = $self->clone;
    $clone->span($span);
    $clone->_setup_pageurl($self);
    return $clone;
}

sub _setup_pageurl {
    my ($self, $from) = @_;
    my $url = $from->pageurl->clone;
    $url->query_form(
        {
            $url->query_form,
            %{$self->params},
        }
    );
    $self->pageurl($url);
}

1;
__END__

=head1 NAME

Geo::Google::StaticMaps::Navigation -

=head1 SYNOPSIS

  use Geo::Google::StaticMaps::Navigation;

  my $map = Geo::Google::StaticMaps::Navigation->new(
    key => 'my_google_maps_api_key',
    center => [$lat, $lng],
    span => 0.01,
  );

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
