use inc::Module::Install;
name 'Geo-Google-StaticMaps-Navigation';
all_from 'lib/Geo/Google/StaticMaps/Navigation.pm';

# requires '';
requires 'URI';
requires 'List::Util';
requires 'Storable';
requires 'Geo::Coordinates::Converter';
requires 'Geo::Mercator';

requires_any_moose(
    prefer => 'Mouse',
    moose => '0.56',
    mouse => '0.40',
);

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
