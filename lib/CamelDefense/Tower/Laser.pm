package CamelDefense::Tower::Laser;

use Moose;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Num);
use Time::HiRes qw(time);

extends 'CamelDefense::Tower::Base';

has cool_off_period => (is => 'ro', required => 1, isa => Num, default => 1.0);
has damage_per_sec  => (is => 'ro', required => 1, isa => Num, default => 10);
has laser_color     => (is => 'ro', required => 1, isa => Num, default => 0x009F00FF);
has fire_period     => (is => 'ro', required => 1, isa => Num, default => 1.0);

sub init_image_def {{
    image     => '../data/tower_laser.png',
    size      => [15, 15],
    sequences => [
        default          => [[0, 0]],
        place_tower      => [[1, 0]],
        cant_place_tower => [[2, 0]],
    ],
}}

sub start {
    my $self = shift;
    my $fire_period = $self->fire_period;
    my ($fire_start_time, $is_firing) = (time, 0);
    my $time_diff = sub { time - $fire_start_time };
    while (1) {
        while (&$time_diff < $fire_period) {
            if ($self->aim(&$time_diff)) {
                $fire_start_time = time unless $is_firing;
                $is_firing = 1;
                $self->fire(&$time_diff);
            }
        }
        sleep $self->cool_off_period if $is_firing;
        ($fire_start_time, $is_firing) = (time, 0);
    }
}

sub fire {
    my ($self, $since_fire_start) = @_;
    my $sleep   = 0.1;
    my $start   = time;
    my $target  = $self->current_target;
    my $damage  = $self->damage_per_sec * $sleep;
    my @xy      = @{ $self->xy };
    my $range   = $self->range;
    my $timeout = $self->fire_period - $since_fire_start;
    return if $timeout <= 0;
    while (
           time - $start < $timeout
        && $target->is_alive
        && $target->is_in_range(@xy, $range)
    ) {
        $target->hit($damage);
        sleep $sleep;
    }
    $self->current_target(undef);
}

# render laser to creep
sub render_attacks {
    my ($self, $surface) = @_;
    my $target = $self->current_target;
    if ($target && $target->is_alive) {
        my $sprite = $self->sprite;
        $surface->draw_line(
            [$self->center_x, $self->center_y - 4], # laser starts from antena
            $target->xy,
            $self->laser_color, 1,
        );
    }
}

1;

