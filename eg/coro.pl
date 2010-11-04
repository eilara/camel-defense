#!/usr/bin/perl

use strict;
use warnings;
use SDL::Video;
use SDL::Events;
use SDLx::App;
use SDLx::Controller::Coro;
use Coro;
use Coro::EV;
use AnyEvent;

$|=1;

my @balls;

my ($app_w, $app_h) = (640, 480);
my ($max_v, $min_v) = (450, 100);

my $app = SDLx::App->new(
   title  => 'Coro Example',
   width  => $app_w,
   height => $app_h,
);

my $controller = SDLx::Controller::Coro->new;

$controller->add_event_handler(sub {
    my $e = shift;
    if ($e->type == SDL_QUIT) {
        $controller->stop;
        exit;
    }
    if($e->type == SDL_MOUSEBUTTONDOWN) {
        start_dance($e->motion_x, $e->motion_y);
    }
});

sub rest($) {
   my $time = shift;
   my $done = AnyEvent->condvar;
   my $delay = AnyEvent->timer( after => $time, cb => sub { $done->send;  } );
   $done->recv;
}

$controller->add_show_handler(\&show_handler);

$controller->run;

sub show_handler {
    $app->draw_rect([0, 0, $app_w, $app_h], 0x0);
    for my $ball (@balls) {
        SDL::Video::fill_rect
            ($app, SDL::Rect->new($ball->{x}, $ball->{y}, 10, 10), $ball->{c});
    }
    $app->update;
}

sub start_dance {
    my ($init_x, $init_y) = @_;
    async {
        my $c = SDL::Video::map_RGB($app->format, rand int 256,rand int 256,rand int 256);
        my $ball = {x => $init_x, y => $init_y, c => $c};
        push @balls, $ball;
        while(1) {
           for ($min_v..$max_v) {
               $ball->{x}++;
               rest 1/$_;
           }
           for ($min_v..$max_v) {
               $ball->{x}--;
               rest 1/($max_v+$min_v-$_);
           }
        }
    };
}

__END__

