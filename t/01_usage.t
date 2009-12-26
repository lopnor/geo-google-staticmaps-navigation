use strict;
use warnings;
use Test::More;
use Geo::Coordinates::Converter;
use Geo::Google::StaticMaps::Navigation;
#use LWP::Simple;

my $map = Geo::Google::StaticMaps::Navigation->new(
    key => 'mymapsapikey',
    height => 200,
    width => 200,
    center => [35.662191, 139.681317],
    span => 0.0025,
    markers => [ [35.662191, 139.681317] ],
    pageurl => 'http://localhost:5000/?foo=bar',
);
isa_ok $map, 'Geo::Google::StaticMaps::Navigation';
ok $map->url, $map->url;
#ok get $map->url;
ok my $clone = $map->clone;
isa_ok $clone, 'Geo::Google::StaticMaps::Navigation';
#ok get $map->nearby({lat => 1})->url;
my $zoom = $map->zoom_out;
ok $zoom->pageurl, $zoom->pageurl;
is $zoom->params->{span}, 0.005;
is $zoom->zoom_in->params->{span}, 0.0025;
is $map->north->south->params->{lat}, $map->center->lat;
is $map->west->south->east->north->params->{lng}, $map->center->lng;

ok my $map2 = $map->clone;
ok $map2->span(0.004);
is $map2->zoom_out->span, 0.01;
is $map2->zoom_in->span, 0.0025;
is $map2->zoom_in->zoom_in->span, 0.0025;
my $map3 = $map->clone;
for (1 .. 20) {
    $map3 = $map3->zoom_out;
}
is $map3->span, 40.96;
ok $map3->pageurl, $map3->pageurl;

done_testing;
