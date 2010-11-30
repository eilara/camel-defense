#!/usr/bin/perl
use lib '../lib';

package Ball;
use Moose;
use CamelDefense::Time qw(poll move);

has next_xy => (is => 'rw');

with qw(
    CamelDefense::Role::Active
    CamelDefense::Role::CenteredSprite
);
with 'CamelDefense::Role::AnimatedSprite';

sub init_image_def {
    my $self = shift;
    return {
        image     => '../data/creep_fast.png',
        size      => [21, 21],
        sequences => [
            alive => [[0, 1]],
            birth => [map { [6 - $_, 1] } 0..6],
            death => [map { [$_, 0] } 0..6],
        ],
    };
}

sub start {
    my $self  = shift;
    while (1) {
        poll sleep => 0.1, predicate => sub { $self->next_xy };
        move
            xy   => sub { $self->xy(@_) },
            to   => sub { $self->next_xy(@_) },
            v    => 100,
            wild => 1;
        $self->animate_sprite(death => 7, 0.1);
        $self->animate_sprite(birth => 7, 0.1);
    }
}

package main;

use strict;
use warnings;
use SDL::Events;
use aliased 'SDLx::App';
use aliased 'SDLx::Controller::Coro' => 'Controller';
use SDLx::Coro::REPL;
use Coro;
use Coro::EV;
use AnyEvent;
$|=1;

my ($app_w, $app_h)  = (640, 480);

our ($ball, $last_click); # our not my so REPL can get it

my $app = App->new(
    title  => 'Move Example',
    width  => $app_w,
    height => $app_h,
);

my $repl = SDLx::Coro::REPL::start();
my $controller = SDLx::Controller::Coro->new;

$controller->add_event_handler(sub {
    my $e = shift;
    if ($e->type == SDL_QUIT) {
        $controller->stop;
        exit;
    } elsif ($e->type == SDL_MOUSEBUTTONUP) {
        click_mouse($e->motion_x, $e->motion_y);
        $last_click = [$e->motion_x, $e->motion_y];
    }
});

$controller->add_show_handler(\&show_handler);

$controller->run;

sub show_handler {
    $app->draw_rect([0, 0, $app_w, $app_h], 0x0);
    $ball->render($app) if $ball;
    $app->update;
}

sub click_mouse {
    my ($x, $y) = @_;
    unless ($last_click) { # first click create ball
        $ball = Ball->new;
        $ball->xy([$x, $y]);
        $last_click = 1;
        return;
    }
    $ball->next_xy([$x, $y]);
}



