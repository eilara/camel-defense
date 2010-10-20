#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use SDL::Events;
use SDLx::App;
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Wave';
$|=1;

my ($app_w, $app_h)  = (640, 480);
my $creep_vel        = 15;         # creep velocity
my $inter_creep_wait = 0.6;        # time to wait between creep births in seconds
my $creep_size       = 31;         # pixel size of one creep

my $app = SDLx::App->new(
    title  => 'Wave Example',
    width  => $app_w,
    height => $app_h,
);

my $grid = Grid->new(
    w         => $app_w,
    h         => $app_h,
    spacing   => 48,
    waypoints => [
        [0.50, 0.00],
        [0.50, 0.25],
        [0.25, 0.25],
        [0.25, 0.50],
        [0.75, 0.50],
        [0.75, 0.75],
        [0.50, 0.75],
        [0.50, 0.99],
    ],
);

my @wave_defs = ({
    creep_vel        => $creep_vel,
    creep_size       => $creep_size,
    inter_creep_wait => $inter_creep_wait,
}, {
    creep_vel        => $creep_vel * 2,
    creep_size       => $creep_size - 6,
    inter_creep_wait => $inter_creep_wait * 0.9,
    creep_color      => 0xFF0000FF,
}, {
    creep_vel        => $creep_vel * 2.7,
    creep_size       => $creep_size - 12,
    inter_creep_wait => $inter_creep_wait * 0.8,
    creep_color      => 0x0000FFFF,
}, {
    creep_vel        => $creep_vel * 3.5,
    creep_size       => $creep_size - 18,
    inter_creep_wait => $inter_creep_wait * 0.6,
    creep_color      => 0x00FF00FF,
});

my @waves;
my $last_log = time;

$app->add_event_handler(\&event_handler);
$app->add_move_handler(\&move_handler);
$app->add_show_handler(\&show_handler);

$app->run;

sub event_handler {
    my $e = shift;
    if ($e->type == SDL_QUIT) { $app->stop }
    elsif ($e->type == SDL_KEYUP) {
        my $k = $e->key_sym == SDLK_1? 1:
                $e->key_sym == SDLK_2? 2:
                $e->key_sym == SDLK_3? 3:
                $e->key_sym == SDLK_4? 4:
                undef;
        if (defined $k) {
            my $def = $wave_defs[$k - 1];
            push @waves, Wave->new(%$def, waypoints => $grid->points_px);
        }
    }
}

sub move_handler {
    my $dt = shift;
    $_->move($dt) for @waves;

    if (time - $last_log > 1) {
        $last_log = time;
        my $cnt = 0;
        for my $w (@waves) { $cnt += scalar @{$w->creeps} }
        print "# Number of creeps=$cnt\n";
    }
}

sub show_handler {
    my $dt = shift;
    $grid->render($app);
    $_->render($app) for @waves;
    $app->draw_gfx_text
        ([10, 10], 0xFFFF00FF, "Hit 1,2,3, or 4 to create a wave");
    $app->update;
}
