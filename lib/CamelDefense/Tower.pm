package CamelDefense::Tower;

use Moose;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Num Str);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';

extends 'CamelDefense::Tower::Base';

has wave_manager    => (is => 'ro', required => 1, isa => WaveManager);

has laser_color     => (is => 'ro', required => 1, isa => Num, default => 0xFF0000FF);
has cool_off_period => (is => 'ro', required => 1, isa => Num, default => 1.0);
has fire_period     => (is => 'ro', required => 1, isa => Num, default => 1.0);
has damage_per_sec  => (is => 'ro', required => 1, isa => Num, default => 10);

has current_target  => (is => 'rw');

with 'CamelDefense::Role::Active';

sub init_image_def { '../data/tower.png' }

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

sub aim {
    my ($self, $timeout) = @_;
    my $sleep = 0.1;
    my $start = time;
    my @args  = ($self->center_x, $self->center_y, $self->range);
    while (time - $start < $timeout) {
        sleep $sleep;
        if (my $target = $self->wave_manager->aim(@args)) {
            $self->current_target($target);
            return $target;
        }
    }
    return undef;
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

after render => sub {
    my ($self, $surface) = @_;
    my $target = $self->current_target;
    if ($target && $target->is_alive) {
        # render laser to creep
        my $sprite = $self->sprite;
        $surface->draw_line(
            [$self->center_x, $self->center_y],
            $target->xy,
            $self->laser_color, 1,
        );
    }
};

# should be called before render, on background layer
sub render_range {
    my ($self, $surface, $color) = @_;
    $surface->draw_circle(
        [$self->center_x, $self->center_y],
        $self->range,
        $color,
        1,
    );
}

1;

