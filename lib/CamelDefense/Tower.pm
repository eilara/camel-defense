package CamelDefense::Tower;

use Moose;
use MooseX::Types::Moose qw(Num Int);
use aliased 'SDLx::Sprite';
use aliased 'CamelDefense::Grid';

has [qw(x y)] => (is => 'rw', required => 1, isa => Num);

has sprite => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Sprite, 
    handles    => [qw(load draw)],
);

has grid => (
    is       => 'ro',
    required => 1,
    isa      => Grid,
    handles  => [qw(compute_cell_center)],
);

sub _build_sprite {
    my $self = shift;
    my $center = $self->compute_cell_center($self->x, $self->y);
    my $sprite = Sprite->new(image => '../data/tower.png');
    $sprite->x($center->[0] - $sprite->w/2);
    $sprite->y($center->[1] - $sprite->h/2);
    return $sprite;
}

sub render {
    my ($self, $surface) = @_;
    $self->draw($surface);
}

1;

