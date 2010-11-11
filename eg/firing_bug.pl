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

my $app = App->new(
    title  => 'World Example',
    width  => $app_w,
    height => $app_h,
);

my $controller = Controller->new;

my $world = World->new(
    app                    => $app,
    controller             => $controller,
    wave_manager_args => [
        wave_defs => [
            {
                creep_count => 1,
                creep_args  => [v => 10, hp => 1000],
            },
        ],
    ],
    tower_manager_args => [tower_args => [
        fire_period => 3,
        cool_off_period => 2,
        range       => 300,
    ]],
    waypoints  => [
        [0.00, 0.50],
        [0.95, 0.50],
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
        $e->key_sym == SDLK_1;
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

