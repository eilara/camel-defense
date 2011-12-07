#!/usr/bin/perl

use Games::CamelDefense::Demo qw(Grid::Markers);
use Games::CamelDefense::App title => 'Markers',
                             size  => [640, 480];

# a simple paintable- grid markers

my $markers = Markers->new
    (size => App->size, xy => [0, 0], spacing => 32);

App->run;


