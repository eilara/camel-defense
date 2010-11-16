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
    # render laser to creep
    if (my $target = $self->current_target) {
        if ($target->is_alive) {
            my $sprite = $self->sprite;
            $surface->draw_line(
                [$self->center_x, $self->center_y],
                $target->xy,
                $self->laser_color, 1,
            );
        }
    }
};

1;

__END__

sub move {
    my ($self, $dt)     = @_;

    my $last_fire       = $self->last_fire_time;
    my $cool_off_period = $self->cool_off_period;
    my $fire_period     = $self->fire_period;
    my $diff            = time - $last_fire;
    my $state           = $self->state;

    if ($state eq 'init') {
        if (my $target = $self->aim($self->center_x, $self->center_y, $self->range)) {
            $self->current_target($target);
            $self->last_damage_update(time);
            $self->last_fire_time(time);
            $self->state('firing');
        }
    } elsif ($state eq 'firing') {
        my $target = $self->current_target;
        if (
            $target &&
            $target->is_alive &&
            $target->is_in_range
                ($self->center_x, $self->center_y, $self->range)
        ) {
            my $damage_period = time - $self->last_damage_update;
            my $damage = $self->damage_per_sec * $damage_period;
            $self->last_damage_update(time);
            $target->hit($damage);
            $self->current_target(undef) unless $target->is_alive;
        } else {
            if (my $target = $self->aim($self->center_x, $self->center_y, $self->range)) {
                $self->current_target($target);
                $self->last_damage_update(time);
            } else {
                $self->current_target(undef);
            }
        }
        if ($diff >= $fire_period) {
            $self->current_target(undef);
            $self->state('cooling');
        }
    } elsif ($state eq 'cooling') {
        if ($diff >= $cool_off_period + $fire_period) {
            $self->state('init');
        }
    } else {
        die "Unknown state: $state";
    }
}
