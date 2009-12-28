use strict;
use warnings;
use Test::Base;
use Geo::Google::StaticMaps::Navigation;

plan tests => 2 * blocks;

run {
    my $block = shift;
    my $map = Geo::Google::StaticMaps::Navigation->new(
        key => 'mymapsapikey',
        size => [$block->width, $block->height],
        center => [$block->lat, $block->lng],
        zoom => $block->zoom,
    );
    is( $map->east->{center}->[1], $block->east);
    is( $map->south->{center}->[0], $block->south);
}

__END__
===
--- lat: -12.085309
--- lng: -76.968366
--- width: 500
--- heigth: 500
--- zoom: 8
--- east: -76.641113
--- south: -12.405309
===
--- lat: 35.662191
--- lng: 139.681317
--- width: 500
--- heigth: 500
--- zoom: 8
--- east: 140.075178
--- south: 35.342191
=== 
--- lat: 1.422191
--- lng: 103.841317
--- width: 500
--- heigth: 500
--- zoom: 8
--- east: 104.161416
--- south: 1.102191
===
--- lat: 71.022191
--- lng: 28.001317
--- width: 500
--- heigth: 500
--- zoom: 8
--- east: 28.985273
--- south: 70.702191
