package CamelDefense::Tower;

use Moose;
use MooseX::Types::Moose qw(Num Str);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';

has wave_manager =>
    (is => 'ro', required => 1, isa => WaveManager, handles => [qw(aim)]);

has laser_color     => (is => 'ro', required => 1, isa => Num, default => 0xFF0000FF);
has cool_off_period => (is => 'ro', required => 1, isa => Num, default => 0.5);
has fire_period     => (is => 'ro', required => 1, isa => Num, default => 1.0);
has damage_per_sec  => (is => 'ro', required => 1, isa => Num, default => 10);

has last_fire_time  => (is => 'rw', isa => Num, default => 0);
has state           => (is => 'rw', isa => Str, default => 'init');

has [qw(current_target last_damage_update)] => (is => 'rw');

with 'CamelDefense::Role::TowerView';

sub init_image_file { '../data/tower.png' }

sub move {
    my ($self, $dt)     = @_;

    my $last_fire       = $self->last_fire_time;
    my $cool_off_period = $self->cool_off_period;
    my $fire_period     = $self->fire_period;
    my $diff            = time - $last_fire;
    my $state           = $self->state;

# HACK: this should be in a state machine or something!
#       this logic is too complex for me to grok easily. help.

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

after render => sub {
    my ($self, $surface) = @_;
    # render laser to creep
    if ($self->state eq 'firing') {
        my $target = $self->current_target;
        if ($target && $target->is_alive) {
            my $sprite = $self->sprite;
            $surface->draw_line(
                [$self->center_x, $self->center_y],
                $target->xy,
                $self->laser_color, 1,
            );
        } else {
            $self->current_target(undef);
        }
    }
};

1;

__END__


sub start {
    my $self = shift;
    my ($fire_period, $cool_off_period, $damage_per_sec, $xy, $range) =
        map { $self->$_ }
            qw(fire_period cool_off_period damage_per_sec xy range);
    while (1) {
        my $target = $self->aim;
        my $start_fire_time = time;
        while (time - $start_fire_time <= $fire_period) {
            while (
                $target->is_in_game &&
                $target->is_in_range(@$xy, $range)
            ) {
            }

target alive
target in range
fire period
        $self->current_target($target);

    }
    
}

