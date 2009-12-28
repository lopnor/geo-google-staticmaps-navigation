use strict;
use warnings;
use Test::More;
use Geo::Google::StaticMaps::Navigation;
#use LWP::Simple;

my $map = Geo::Google::StaticMaps::Navigation->new(
    key => 'mymapsapikey',
    size => [365,365],
    center => [0, 0],
    zoom => 9,
);
isa_ok $map, 'Geo::Google::StaticMaps';
ok $map->url, $map->url;
ok my $clone = $map->clone;
isa_ok $clone, 'Geo::Google::StaticMaps::Navigation';
my $zoom = $map->zoom_out;
is $zoom->{zoom}, 8;
is $map->_degree(365,9), 1;
my $north = $map->north;
is_deeply $north->{center}, [0.99999999998658, 0];
my $east = $map->east;
is_deeply $east->{center}, [0, 1];
is_deeply $map->zoom_out->east->{center}, [0, 2];

done_testing;
