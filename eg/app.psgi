#!perl
use strict;
use warnings;
use utf8;
use lib 'lib';
use Encode;
use Plack::Request;
use Geo::Google::StaticMaps::Navigation;
use Text::MicroTemplate qw(:all);

my $baseurl = $ENV{BASEURL} || 'http://maps.google.com/staticmap';
my $template = do {local $/; <DATA>};

sub {
    my $req = Plack::Request->new(shift);
    my $lat = $req->param('lat') || 35.683061;
    my $lng = $req->param('lng') || 139.766092;
    my $span = $req->param('span') || 0.64;
    my $type = $req->param('type') || 'roadmap';

    my $map = Geo::Google::StaticMaps::Navigation->new(
        key => $ENV{GOOGLE_MAPS_API_KEY},
        height => 500,
        width => 500,
        center => [$lat, $lng],
        markers => [[$lat, $lng]],
        span => $span,
        pageurl => $req->uri,
        baseurl => $baseurl,
        maptype => $type,
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
<br />
<a href="./?lat=64.148054&lng=-21.895065&span=0.64">Reykjavik</a>
<a href="./?lat=51.517663&lng=-0.088835&span=0.64">London</a>
<a href="./?lat=35.683061&lng=139.766092&span=0.64">Tokyo</a>
<a href="./?lat=1.303312&lng=103.849983&span=0.64">Singapore</a>
<a href="./?lat=-41.281225&lng=174.776258&span=0.64">Wellington</a>
<a href="./?lat=-34.584606&lng=-58.373108&span=0.64">Buenos Aires</a><br />
<a href="./?lat=60.0&lng=30.0&span=0.64">near Sankt-Peterburg</a>
<a href="./?lat=45.0&lng=60.0&span=0.64">Aral Sea</a>
<a href="./?lat=30.0&lng=120.0&span=0.64">near Hangzhou</a>
<a href="./?lat=0.0&lng=30.0&span=0.64">near Lake George</a>
</center>
</body>
</html>
