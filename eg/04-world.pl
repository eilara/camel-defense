#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use SDL::Events;
use CamelDefense::Time qw(pause_resume);
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

# $app->fullscreen;

my $controller = Controller->new;

my $world = World->new(
    app               => $app,
    controller        => $controller,
    wave_manager_args => [
        level_complete_handler => sub { $game_over = 1 },
        wave_defs => [
            {
                creep_count      => 10,
                inter_creep_wait => 0.5,
                creep_args       =>
                    [v => 50],
            },
            {
                creep_count      => 7,
                inter_creep_wait => 0.2,
                creep_args       =>
                    [v => 85, kind => 'fast'],
            },
            {
                creep_count      => 13,
                inter_creep_wait => 0.3,
                creep_args       =>
                    [v => 20, kind => 'slow', hp => 20],
            },
        ],
    ],
    tower_manager_args => [
        tower_defs => [
            {
                type        => 'CamelDefense::Tower::Laser',
                fire_period => 1.5,
            },
            {
                type            => 'CamelDefense::Tower::Splash',
                cool_off_period => 1.0,
            },
            {
                type  => 'CamelDefense::Tower::Slow',
                range => 60,
            },
        ],
    ],
    waypoints  => [
        [0.50, 0.00],
        [0.50, 0.25],
        [0.25, 0.25],
        [0.25, 0.50],
        [0.75, 0.50],
        [0.75, 0.75],
        [0.50, 0.75],
        [0.50, 0.97],
    ],
);

$controller->add_event_handler(\&event_handler);
$controller->add_show_handler(\&show_handler);

$controller->run;

sub event_handler {
    my $e = shift;
    if (
        $e->type == SDL_QUIT || (
            $e->type    == SDL_KEYUP
         && $e->key_sym == SDLK_q
        )
    ) {
        $app->stop;
        exit;
    } elsif ($e->type == SDL_KEYUP && $e->key_sym == SDLK_p) {
        pause_resume;
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

    my @messages = (
        "Hit 1 to build laser tower, then place with mouse and click",
        "Hit 2 for splash tower, 3 for slow tower",
        "Click mouse on tower to select",
        "Hit Esc before placing tower to cancel build",
        "Hit the space bar to start a wave",
        "Hit p to pause/resume",
        "Hit q to quit the game",
    );
    my $y = 10;
    for my $m (@messages) {
        $app->draw_gfx_text([10, $y], 0xFFFF00FF, $m);
        $y += 13;
    }

    $world->render_cursor($app);
    $app->update;
}

