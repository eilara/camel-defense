#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use SDL::Events;
use aliased 'SDLx::App';
use aliased 'CamelDefense::World';

use aliased 'SDLx::Controller::Coro' => 'Controller';
use Coro;
use Coro::EV;
use AnyEvent;
$|=1;

my ($app_w, $app_h)  = (640, 480);

my $game_over;

my $app = App->new(
    title  => 'World Example',
    width  => $app_w,
    height => $app_h,
);

my $controller = Controller->new;

my $world = World->new(
    app                    => $app,
    controller             => $controller,
    grid_args              => [
        marks_args         => [bg_color   => 0x210606FF],
        waypoint_list_args => [path_color => 0x202010FF],
    ],
    wave_manager_args => [
        level_complete_handler => sub { $game_over = 1 },
        wave_defs => [
            {
                creep_count      => 10,
                inter_creep_wait => 0.5,
                creep_args       =>
                    [v => 100],
            },
            {
                creep_count      => 7,
                inter_creep_wait => 0.2,
                creep_args       =>
                    [v => 170, kind => 'fast'],
            },
            {
                creep_count      => 13,
                inter_creep_wait => 0.3,
                creep_args       =>
                    [v => 60, kind => 'slow', hp => 20],
            },
        ],
    ],
    tower_manager_args => [tower_args => [fire_period => 1.5]],
    waypoints  => [
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

$controller->add_event_handler(\&event_handler);
$controller->add_show_handler(\&show_handler);

$controller->run;

sub event_handler {
    my $e = shift;
    if ($e->type == SDL_QUIT) {
        $app->stop;
        exit;
    }
    $world->start_wave if
        $e->type == SDL_KEYUP &&
        $e->key_sym == SDLK_SPACE;
}

sub show_handler {
    my $dt = shift;

    if ($game_over) {
        my $msg = "Game Over";
        $app->draw_gfx_text([$app_w/2 - 40, $app_h/2 - 4], 0xFFFF00FF, $msg);
    }

    my $msg1 = "Hit 1 to build laser tower, then place with mouse and click";
    my $msg2 = "Hit 1 or Esc before placing tower to cancel build";
    my $msg3 = "Hit the space bar to start a wave";
    $app->draw_gfx_text([10, 10], 0xFFFF00FF, $msg1);
    $app->draw_gfx_text([10, 23], 0xFFFF00FF, $msg2);
    $app->draw_gfx_text([10, 36], 0xFFFF00FF, $msg3);

    $world->render_cursor($app);
    $app->update;
}

