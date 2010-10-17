#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use SDL::Events;
use SDL::Mouse;
use SDLx::App;
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::StateMachine';
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Tower';

my ($app_w, $app_h)  = (640, 480);

my $app = SDLx::App->new(
    title  => 'Tower Example',
    width  => $app_w,
    height => $app_h,
);

SDL::Mouse::show_cursor(SDL_DISABLE);

my $grid = Grid->new(
    w         => $app_w,
    h         => $app_h,
    spacing   => 24,
    waypoints => [[0.50, 0.20], [0.50, 0.81]],
);

my $cursor = Cursor->new;

my @towers;

# would be more accurate to use current mouse pos instead of the pos from last loop
my $can_build = sub {
    $grid->can_build($cursor->x, $cursor->y)?
        'place_tower':
        'cant_place_tower';
};

my $build_tower = sub {
    push @towers, Tower->new(
        grid => $grid,
        x     => $cursor->x,
        y     => $cursor->y,
    );
    $grid->add_tower($cursor->x, $cursor->y);
};

my $state = StateMachine->new(
    cursor => $cursor,
    states => {
        init => {
            cursor => 'normal',
            events => {
                space_key_up => {
                    next_state => $can_build,
                },
            },
        },
        place_tower => {
            cursor => 'place_tower',
            events => {
                space_key_up => {
                    next_state => 'init',
                },
                mouse_motion => {
                    next_state => $can_build,
                },
                mouse_button_up => {
                    next_state => 'init',
                    code       => $build_tower,
                },
            },
        },
        cant_place_tower => {
            cursor => 'cant_place_tower',
            events => {
                mouse_motion => {
                    next_state => $can_build,
                },
            },
        },
});

$app->add_event_handler(\&event_handler);
$app->add_show_handler(\&show_handler);

$app->run;

sub event_handler {
    my $e = shift;
    if ($e->type == SDL_QUIT) {
        $app->stop;

    } elsif ($e->type == SDL_KEYUP && $e->key_sym == SDLK_SPACE) {
        $state->handle_event('space_key_up');

    } elsif ($e->type == SDL_MOUSEMOTION) {
        my ($x, $y) = ($e->motion_x, $e->motion_y);
        $cursor->x($x);
        $cursor->y($y);
        $state->handle_event('mouse_motion');

    } elsif ($e->type == SDL_MOUSEBUTTONUP) {
        $state->handle_event('mouse_button_up');

    } elsif ($e->type == SDL_APPMOUSEFOCUS) {
        $cursor->is_visible($e->active_gain);
    }
}

sub show_handler {
    my $dt = shift;
    $grid->render($app);
    $_->render($app) for @towers;
    my $msg1 = "Hit space to create a tower, then place it with your mouse and click";
    my $msg2 = "Hit space again before placing the tower to cancel the build";
    $app->draw_gfx_text([10, 10], 0xFFFF00FF, $msg1);
    $app->draw_gfx_text([10, 23], 0xFFFF00FF, $msg2);
    $cursor->render($app);
    $app->update;
}

