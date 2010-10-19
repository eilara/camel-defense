#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use SDL::Events;
use aliased 'SDLx::App';
use aliased 'CamelDefense::World';

my ($app_w, $app_h)  = (640, 480);

my $app = App->new(
    title  => 'World Example',
    width  => $app_w,
    height => $app_h,
);

my $world = World->new(
    app              => $app,
    spacing          => 24,
    creep_size       => 17,
    creep_vel        => 10,
    inter_creep_wait => 0.6,
    waypoints        => [
        [0.50, 0.00],
        [0.50, 0.25],
        [0.25, 0.25],
        [0.25, 0.50],
        [0.75, 0.50],
        [0.75, 0.75],
        [0.50, 0.75],
        [0.50, 0.95],
    ],
);

$app->add_event_handler(\&event_handler);
$app->add_show_handler(\&show_handler);

$app->run;

sub event_handler {
    my $e = shift;
    $world->start_wave() if $e->type == SDL_KEYUP &&  $e->key_sym == SDLK_1;
}

sub show_handler {
    my $dt = shift;

    my $msg1 = "Hit space to create a tower, then place it with your mouse and click";
    my $msg2 = "Hit space again before placing the tower to cancel the build";
    my $msg3 = "Hit the 1 key to start a wave";
    $app->draw_gfx_text([10, 10], 0xFFFF00FF, $msg1);
    $app->draw_gfx_text([10, 23], 0xFFFF00FF, $msg2);
    $app->draw_gfx_text([10, 36], 0xFFFF00FF, $msg3);

    $world->render_cursor($app);
    $app->update;
}

