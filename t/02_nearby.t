use strict;
use warnings;
use Test::Base;
use Geo::Google::StaticMaps::Navigation;

plan tests => 2 * blocks;

run {
    my $block = shift;
    my $map = Geo::Google::StaticMaps::Navigation->new(
        key => 'mymapsapikey',
        height => 500,
        width => 500,
        center => [$block->lat, $block->lng],
        span => $block->span,
    );
    is( $map->east->params->{lng}, $block->east);
    is( $map->south->params->{lat}, $block->south);
}

__END__
===
--- lat: -12.085309
--- lng: -76.968366
--- span: 0.32
--- east: -76.641113
--- south: -12.405309
===
--- lat: 35.662191
--- lng: 139.681317
--- span: 0.32
--- east: 140.075178
--- south: 35.342191
=== 
--- lat: 1.422191
--- lng: 103.841317
--- span: 0.32
--- east: 104.161416
--- south: 1.102191
===
--- lat: 71.022191
--- lng: 28.001317
--- span: 0.32
--- east: 28.985273
--- south: 70.702191
