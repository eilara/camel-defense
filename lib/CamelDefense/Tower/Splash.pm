package CamelDefense::Tower::Splash;

use Moose;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Num);
use Time::HiRes qw(time);

extends 'CamelDefense::Tower::Base';

has cool_off_period => (is => 'ro', required => 1, isa => Num, default => 1.0);
has damage_per_sec  => (is => 'ro', required => 1, isa => Num, default => 10);

sub init_image_def {{
    image     => '../data/tower_splash.png',
    size      => [15, 15],
    sequences => [
        default          => [[0, 0]],
        place_tower      => [[1, 0]],
        cant_place_tower => [[2, 0]],
    ],
}}

sub start {
    my $self = shift;
};

1;

