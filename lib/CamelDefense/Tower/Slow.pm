package CamelDefense::Tower::Slow;

use Moose;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Int Num);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Tower::Projectile';

extends 'CamelDefense::Tower::Base';

has cool_off_period   => (is => 'ro', required => 1, isa => Num, default => 1);
has slow_percent      => (is => 'ro', required => 1, isa => Num, default => 10);
has slow_time         => (is => 'ro', required => 1, isa => Num, default => 3);

has explosion_radius  => (is => 'rw', isa => Num, default => 0);
has explosion_color   => (is => 'rw', isa => Num, default => 0x00008F25);

sub init_image_def {{
    image     => '../data/tower_slow.png',
    size      => [15, 15],
    sequences => [
        default          => [[0, 0]],
        place_tower      => [[1, 0]],
        cant_place_tower => [[2, 0]],
    ],
}}

sub start {
    my $self = shift;
    while (1) {
        my $did_fire;
        if ($self->aim(1)) {
            $did_fire = 1;

            my $explosion_steps = 6;
            my $explosion_sleep = 1/50;
            my $explosion_step  = ($self->range - 1) / $explosion_steps;
            my $radius          = 1;
            for (1..$explosion_steps) {
                $self->explosion_radius($radius);
                $radius += $explosion_step;
                sleep $explosion_sleep;
            }
            $self->explosion_radius($self->range);
            for my $color (
                0x00008F25, 0x00008F20, 0x00008F15, 0x00008F10, 0x00008F05,
            ) {
                $self->explosion_color($color);
                sleep 1/20;
            }
            $self->explosion_radius(0);
            $self->explosion_color(0x00008F25);
               
        }
        sleep $self->cool_off_period if $did_fire;
        $did_fire = 0;
    }
};

# render projectiles
sub render_attacks {
    my ($self, $surface) = @_;
    my $radius = $self->explosion_radius;
    return unless $radius;
    $surface->draw_circle_filled(
        [$self->center_x, $self->center_y],
        $radius,
        $self->explosion_color,
    );
};

1;

