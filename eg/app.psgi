#!perl
use strict;
use warnings;
use utf8;
use lib 'lib';
use Encode;
use Plack::Request;
use Geo::Google::StaticMaps::Navigation;
use Text::MicroTemplate qw(:all);

my $template = do {local $/; <DATA>};

sub {
    my $req = Plack::Request->new(shift);
    my $lat = $req->param('lat') || 35.662191;
    my $lng = $req->param('lng') || 139.681317;
    my $span = $req->param('span') || 0.64;

    my $map = Geo::Google::StaticMaps::Navigation->new(
        key => $ENV{GOOGLE_MAPS_API_KEY},
        height => 500,
        width => 500,
        center => [$lat, $lng],
        markers => [[$lat, $lng]],
        span => $span,
    );
    my $body = render_mt($template, $map, $req->uri)->as_string;
    my $res = $req->new_response(200);
    $res->content_type('text/html');
    $res->body($body);
    return $res->finalize;
}
__DATA__
<html>
<body>
<center>
<img src="<?= $_[0]->url ?>" /><br>
? for my $d (qw(north west south east zoom_in zoom_out)) {
?   my $link = URI->new_abs('/', $_[1]);
?   $link->query_form( $_[0]->$d->params );
<a href="<?= $link ?>"><?= $d ?></a>
? }
</center>
</body>
</html>
