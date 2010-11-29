#!/usr/bin/perl
use lib '../lib';

package Ball;
use Moose;
use List::Util qw(max);
use Coro::Timer qw(sleep);
use CamelDefense::Time qw(poll);
use CamelDefense::Util qw(distance);

has next_xy => (is => 'rw');

with qw(
    CamelDefense::Role::Active
    CamelDefense::Role::Sprite
);

sub init_image_def { '../data/tower_splash_projectile.png' }

sub start {
    my $self  = shift;
    while (1) {
        poll sleep => 0.1, predicate => sub { $self->next_xy };
        my ($x2, $y2) = @{$self->next_xy};
        $self->next_xy(undef);
        $self->move_to($x2, $y2);
    }
}

sub move_to {
    my ($self, $x2, $y2) = @_;
    my $v                = 400;
    my $sleep            = max(1/$v, 1/60); # dont move pixel by 1 pixel if you are fast
    my $step             = $v * $sleep;
    my ($x1, $y1)        = @{ $self->xy };
    my ($d, $last_d)     = (0, 1_000_000); # never shall there be such a distance

    while (
        ($d = distance($x1, $y1, $x2, $y2)) > 1
     && $last_d >= $d
    ) {
        my $steps = $d / $step;
        last if $steps < 1;
        $x1 += ($x2 - $x1) / $steps;
        $y1 += ($y2 - $y1) / $steps;
        $self->xy([$x1, $y1]);
        sleep $sleep;
        $last_d = $d;
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



