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
    handles    => [qw(load draw)],
);

has world => (
    is       => 'ro',
    required => 1,
    isa      => World,
    handles  => [qw(compute_cell_center aim)],
);

has laser_color     => (is => 'ro', isa => Num, default => 0xFF0000FF);
has cool_off_period => (is => 'ro', isa => Num, default => 0.5);
has fire_period     => (is => 'ro', isa => Num, default => 1.0);
has damage_per_sec  => (is => 'ro', isa => Num, default => 10);

has last_fire_time  => (is => 'rw', isa => Num, default => 0);
has state           => (is => 'rw', isa => Str, default => 'init');

has [qw(current_target last_damage_update)] => (is => 'rw');

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

# HACK: this should be in a state machine

    if ($state eq 'init') {
        if (my $target = $self->aim($self->x, $self->y)) {
            $self->current_target($target);
            $self->last_damage_update(time);
            $self->last_fire_time(time);
            $self->state('firing');
        }
    } elsif ($state eq 'firing') {
        my $target = $self->current_target;
        if ($target->is_alive) {
            my $damage_period = time - $self->last_damage_update;
            my $damage = $self->damage_per_sec * $damage_period;
            $self->last_damage_update(time);
            $target->hit($damage);
        } else {
            $self->current_target(undef);
            $self->state('cooling');
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

#        init
#            tick event
#                live tower in range?
#                    aim
#                    set current target
#                    set last damage update
#                    set last start fire time
#                    state = firing
#                else stay in seeking
#        firing
#            fire period over?
#                state = cooloff
#                hit target for remaining damage
#                unset target and last damage update
#            else
#               current target still alive and in range?
#                   current target still in range?
#                        calc damage from last damage update
#                        set last damage update
#                        stay in firing
#                   else
#                       aim
#                       set current target
#                       set last damage update
#                       dont set last start fire time
#                       stay in firing
#        cooling off
#            cooling off period over?
#                
#            else
#                stay in cooling off


sub render {
    my ($self, $surface) = @_;
    $self->draw($surface);
    # render laser to creep
    if ($self->state eq 'firing') {
#        if ($target->is_alive) {
            my $target = $self->current_target;
            my $sprite = $self->sprite;
            $surface->draw_line(
                [$sprite->x + $sprite->w/2, $sprite->y + $sprite->h/2],
                [$target->x, $target->y],
                $self->laser_color, 1,
            );
#        } else {
#            $self->current_target(undef);
#        }
    }
}

1;

