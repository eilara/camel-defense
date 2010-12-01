package CamelDefense::Tower::Laser;

use Moose;
use MooseX::Types::Moose qw(Num);
use CamelDefense::Time qw(work_while);

extends 'CamelDefense::Tower::Base';

has damage_per_sec => (is => 'ro', required => 1, isa => Num, default => 3);
has laser_color    => (is => 'ro', required => 1, isa => Num, default => 0x501265FF);

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
    while (1) { $self->attack if $self->aim(1) }
}

sub attack {
    my $self   = shift;
    my $sleep  = 0.1;
    my $target = $self->current_target;
    my $damage = $self->damage_per_sec * $sleep;
    my @range  = (@{ $self->xy }, $self->range);
    work_while
        sleep     => $sleep,
        work      => sub { $target->hit($damage) },
        predicate => sub {
               $target
            && $target->is_alive
            && $target->is_in_range(@range)
        };
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

