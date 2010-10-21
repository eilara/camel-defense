package CamelDefense::Tower;

use Moose;
use MooseX::Types::Moose qw(Num Str);
use Time::HiRes qw(time);
use aliased 'SDLx::Sprite';
use aliased 'CamelDefense::World';
use aliased 'CamelDefense::Creep';

has [qw(x y)] => (is => 'rw', required => 1, isa => Num);

has sprite => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Sprite, 
    handles    => [qw(load draw w h)],
);

has world => (
    is       => 'ro',
    required => 1,
    isa      => World,
    handles  => [qw(compute_cell_center aim)],
);

has laser_color     => (is => 'ro', isa => Num, default => 0xFF0000FF);
has cool_off_period => (is => 'ro', isa => Num, default => 0.5);
has fire_period     => (is => 'ro', isa => Num, default => 0.5);
has damage_per_sec  => (is => 'ro', isa => Num, default => 15);
has range           => (is => 'ro', isa => Num, default => 100); # in pixels

has last_fire_time  => (is => 'rw', isa => Num, default => 0);
has state           => (is => 'rw', isa => Str, default => 'init');

has [qw(current_target last_damage_update center_x center_y)] => (is => 'rw');

sub BUILD {
    my $self = shift;
    $self->center_x($self->sprite->x + $self->w/2);
    $self->center_y($self->sprite->y + $self->h/2);
}

sub _build_sprite {
    my $self = shift;
    my $center = $self->compute_cell_center($self->x, $self->y);
    my $sprite = Sprite->new(image => '../data/tower.png');
    $sprite->x($center->[0] - $sprite->w/2);
    $sprite->y($center->[1] - $sprite->h/2);
    return $sprite;
}

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

sub render_range {
    my ($self, $surface, $color) = @_;
    my $sprite = $self->sprite;
    $surface->draw_circle(
        [$self->center_x, $self->center_y],
        $self->range,
        $color,
    );
}

sub render {
    my ($self, $surface) = @_;
    $self->draw($surface);
    # render laser to creep
    if ($self->state eq 'firing') {
        my $target = $self->current_target;
        if ($target && $target->is_alive) {
            my $sprite = $self->sprite;
            $surface->draw_line(
                [$self->center_x, $self->center_y],
                [$target->x, $target->y],
                $self->laser_color, 1,
            );
        } else {
            $self->current_target(undef);
        }
    }
}

1;

