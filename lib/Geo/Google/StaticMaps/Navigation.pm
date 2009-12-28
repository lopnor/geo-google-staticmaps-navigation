package Geo::Google::StaticMaps::Navigation;
use strict;
use warnings;
use base 'Geo::Google::StaticMaps';
use Geo::Mercator;

our $degree_per_pixel_on_zoom_3 = 60/342;

sub clone {
    my ($self) = @_;
    __PACKAGE__->new(%$self);
}

sub north {$_[0]->nearby({lat => 1})};
sub south {$_[0]->nearby({lat => -1})};
sub east {$_[0]->nearby({lng => 1})};
sub west {$_[0]->nearby({lng => -1})};
sub zoom_in {$_[0]->scale(1)}
sub zoom_out {$_[0]->scale(-1)}

sub pageurl {
    my ($self, $uri) = @_;
    my %orig = $uri->query_form;
    $uri->query_form(
        {
            %orig,
            lat => $self->{center}->[0],
            lng => $self->{center}->[1],
            zoom => $self->{zoom},
        }
    );
    return $uri;
}

sub nearby {
    my ($self, $args) = @_;
    my $clone = $self->clone;
    $clone->{center} = _next_latlng(
        $clone->{center}->[0],
        $clone->{center}->[1],
        _degree($clone->{size}->[1], $clone->{zoom}) * ($args->{lat} || 0),
        _degree($clone->{size}->[0], $clone->{zoom}) * ($args->{lng} || 0),
    );
    return $clone;
}

sub scale {
    my ($self, $arg) = @_;
    my $clone = $self->clone;
    $clone->{zoom} += $arg;
    return $clone;
}

sub _degree {
    my ($size, $zoom) = @_;
    return $size * $degree_per_pixel_on_zoom_3 * ( 2 ** (3 - $zoom));
}

sub _next_latlng {
    my ($lat, $lng, $move_lat, $move_lng) = @_;
    my $move_y = [ mercate($move_lat, 0) ]->[1] - [ mercate(0,0) ]->[1];
    my ($x, $y) = mercate($lat, $lng);
    my ($new_lat) = demercate($x, $y+$move_y);
    return [ 
        $new_lat,
        $lng + $move_lng,
    ];
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

=head2 nearby

returns nearby map.

=head2 north, south, west, east

returns nearby map for each direction.

=head2 zoom_in, zoom_out

returns zoomed map.

=head1 AUTHOR

Nobuo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
