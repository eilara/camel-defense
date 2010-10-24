#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use SDL::Events;
use SDLx::App;
use aliased 'CamelDefense::Grid::Markers';

my ($app_w, $app_h)  = (640, 480);

my $app = SDLx::App->new(
    title  => 'Markers Example',
    width  => $app_w,
    height => $app_h,
);

my $markers = Markers->new(
    w => $app_w,
    h => $app_h,
);

$app->add_event_handler(sub { $_[1]->stop if $_[0]->type == SDL_QUIT });
$app->add_show_handler(\&show_handler);

$app->run;

sub show_handler {
    my $dt = shift;
    $markers->render($app);
    $app->update;
}

