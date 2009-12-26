#!perl
use strict;
use warnings;
use utf8;
use lib 'lib';
use Encode;
use Plack::Request;
use Geo::Google::StaticMaps::Navigation;
use Text::MicroTemplate qw(:all);

$ENV{BASEURL} ||= 'http://maps.google.com/staticmap';
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
        pageurl => $req->uri,
        baseurl => $ENV{BASEURL},
    );
    my $body = render_mt($template, $map)->as_string;
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
<a href="<?= $_[0]->$d->pageurl ?>"><?= $d ?></a>
? }
</center>
</body>
</html>
