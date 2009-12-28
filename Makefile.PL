use inc::Module::Install;
name 'Geo-Google-StaticMaps-Navigation';
all_from 'lib/Geo/Google/StaticMaps/Navigation.pm';

# requires '';
requires 'Geo::Google::StaticMaps';
requires 'Geo::Mercator';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
