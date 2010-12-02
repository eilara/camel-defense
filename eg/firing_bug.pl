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
                inter_creep_wait => 0.6,
                creep_count      => 1,
                creep_args       => [v => 60, hp => 10],
            },
        ],
    ],
    tower_manager_args => [
        tower_defs => [
            {
                type        => 'CamelDefense::Tower::Laser',
                fire_period => 3,
                range       => 300,
            },
            {
                type        => 'CamelDefense::Tower::Splash',
                range       => 300,
            },
            {
                type  => 'CamelDefense::Tower::Slow',
                range => 60,
                range => 100,
            },
        ],
    ],
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
        $e->key_sym == SDLK_SPACE;
}

sub show_handler {
    my $dt = shift;

    my $msg1 = "Hit 1 to build laser tower, then place with mouse and click";
    my $msg2 = "Hit Esc before placing tower to cancel build";
    my $msg3 = "Hit the space bar to start a wave";
    $app->draw_gfx_text([10, 10], 0xFFFF00FF, $msg1);
    $app->draw_gfx_text([10, 23], 0xFFFF00FF, $msg2);
    $app->draw_gfx_text([10, 36], 0xFFFF00FF, $msg3);

    $world->render_cursor($app);
    $app->update;
}

