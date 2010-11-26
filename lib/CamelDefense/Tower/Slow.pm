package CamelDefense::Tower::Slow;

use Moose;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Int Num);
use CamelDefense::Util qw(animate);
use aliased 'CamelDefense::Tower::Projectile';

my $ATTACK_COLOR = 0x00008F25;

extends 'CamelDefense::Tower::Base';

has cool_off_period   => (is => 'ro', required => 1, isa => Num, default => 1);
has slow_percent      => (is => 'ro', required => 1, isa => Num, default => 10);
has slow_time         => (is => 'ro', required => 1, isa => Num, default => 3);

has explosion_radius  => (is => 'rw', isa => Num, default => 0);
has explosion_color   => (is => 'rw', isa => Num, default => $ATTACK_COLOR);

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
        if ($self->aim(1)) {
            $self->attack;
            sleep $self->cool_off_period;
        }
    }
}

sub attack {
    my $self = shift;    
    animate
        type  => [linear => 1, $self->range, 6],
        on    => [explosion_radius => $self],
        sleep => 1/50;
    animate
        type  => [linear => $ATTACK_COLOR, 0x00008F05, 5],
        on    => [explosion_color => $self],
        sleep => 1/15;

    $self->explosion_radius(0);
    $self->explosion_color($ATTACK_COLOR);
}               

# render projectiles
sub render_attacks {
    my ($self, $surface) = @_;
    my $radius = $self->explosion_radius;
    return unless $radius;
    $surface->draw_circle_filled(
        [$self->center_x, $self->center_y],
        $radius,
        int($self->explosion_color),
    );
};

1;

