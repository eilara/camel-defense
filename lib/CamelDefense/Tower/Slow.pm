package CamelDefense::Tower::Slow;

use Moose;
use MooseX::Types::Moose qw(Int Num ArrayRef);
use CamelDefense::Time qw(animate repeat_work);
use aliased 'CamelDefense::Tower::Projectile';
use aliased 'CamelDefense::Creep';

my $ATTACK_COLOR = 0x39257235;

extends 'CamelDefense::Tower::Base';

has cool_off_period   => (is => 'ro', required => 1, isa => Num, default => 1);
has slow_percent      => (is => 'ro', required => 1, isa => Num, default => 10);
has slow_time         => (is => 'ro', required => 1, isa => Num, default => 3);

has explosion_radius  => (is => 'rw', isa => Num, default => 0);
has explosion_color   => (is => 'rw', isa => Num, default => $ATTACK_COLOR);

has current_targets   => (is => 'ro', required => 1, isa => ArrayRef[Creep], default => sub { [] });

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
    repeat_work
        predicate => sub { $self->aim(1) },
        work      => sub { $self->attack },
        sleep     => $self->cool_off_period;
}

sub attack {
    my $self = shift;    

    my @args = ($self->center_x, $self->center_y, $self->range);
    if (my $targets = $self->find_creeps_in_range(@args))
        { $_->slow($self->slow_percent) for @$targets }

    animate
        type  => [linear => 1, $self->range, 6],
        on    => [explosion_radius => $self],
        sleep => 1/50;

    animate
        type  => [linear => $ATTACK_COLOR, 0x39257205, 5],
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

