package CamelDefense::Role::GridAlignedSprite;

# a role for a visual object which has a sprite
# and that sprite is aligned to a grid

use Moose::Role;
use MooseX::Types::Moose qw(Num);

requires 'compute_cell_center';

has [qw(center_x center_y)] => (is => 'rw', lazy_build => 1, isa => Num);

with 'CamelDefense::Role::Sprite' => { -excludes => ['compute_sprite_xy'] };

sub _build_center_x {
    my $self = shift;
    return $self->sprite_x + $self->w/2;
}

sub _build_center_y {
    my $self = shift;
    return $self->sprite_y + $self->h/2;
}

sub compute_sprite_xy {
    my $self = shift;
    my $center = $self->compute_cell_center(@{ $self->xy });
    $self->center_x($center->[0]);
    $self->center_y($center->[1]);
    return ($center->[0] - $self->w/2, $center->[1] - $self->h/2);
}

1;

