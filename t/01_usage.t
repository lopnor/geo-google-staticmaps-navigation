use strict;
use warnings;
use Test::More;
use Geo::Coordinates::Converter;
use Geo::Google::StaticMaps::Navigation;
use LWP::Simple;

BEGIN { 
    if (! $ENV{GOOGLE_MAPS_API_KEY}) {
        plan skip_all => 'Set GOOGLE_MAPS_API_KEY to run this test.';
    } else {
        plan tests => 10;
    }
}

my $map = Geo::Google::StaticMaps::Navigation->new(
    key => $ENV{GOOGLE_MAPS_API_KEY},
    height => 200,
    width => 200,
    center => Geo::Coordinates::Converter->new(latitude => 35.662191, longitude => 139.681317),
    span => 0.002,
    markers => [ Geo::Coordinates::Converter->new(latitude => 35.662191, longitude => 139.681317) ],
);
isa_ok $map, 'Geo::Google::StaticMaps::Navigation';
ok $map->url;
ok get $map->url;
ok my $clone = $map->clone;
isa_ok $clone, 'Geo::Google::StaticMaps::Navigation';
ok get $map->nearby({lat => 1})->url;
my $zoom = $map->zoom_in;
is $zoom->params->{span}, 0.003;
is $zoom->zoom_out->params->{span}, 0.002;
is $map->north->south->params->{lat}, $map->center->lat;
is $map->west->south->east->north->params->{lng}, $map->center->lng;
