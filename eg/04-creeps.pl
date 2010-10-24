#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use Time::HiRes qw(time);
use SDL::Events;
use SDLx::App;
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Creep';

my ($app_w, $app_h)  = (640, 480);
my $creep_vel        = 20;         # creep velocity
my $inter_creep_wait = 0.5;        # time to wait between creep births in seconds

my $app = SDLx::App->new(
    title  => 'Creep Example',
    width  => $app_w,
    height => $app_h,
);

my $grid = Grid->new(
    w         => $app_w,
    h         => $app_h,
    waypoints => [
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
my @creeps;
my $creep_idx;
my $last_creep_birth = time;

$app->add_event_handler(sub { $_[1]->stop if $_[0]->type == SDL_QUIT });
$app->add_move_handler(\&move_handler);
$app->add_show_handler(\&show_handler);

$app->run;

sub move_handler {
    my $dt = shift;
    @creeps = map { $_->move($dt) } @creeps;
    if (time - $last_creep_birth > $inter_creep_wait) {
        $last_creep_birth = time;
        push @creeps, Creep->new(
            waypoints => $grid->points_px,
            v         => $creep_vel,
            idx       => ++$creep_idx,
        );
    }
}

sub show_handler {
    my $dt = shift;
    $grid->render_markers($app);
    $grid->render($app);
    $_->render($app) for @creeps;
    $app->update;
}

