package CamelDefense::Role::GridAlignedSprite;

# a role for a visual object which has a sprite
# and that sprite is aligned to a grid

use Moose::Role;
use MooseX::Types::Moose qw(Num);

requires 'compute_cell_center';

with 'CamelDefense::Role::Sprite' => { -excludes => ['compute_sprite_xy'] };

sub compute_sprite_xy {
    my $self = shift;
    my $center = $self->compute_cell_center(@{ $self->xy });
    $self->center_x($center->[0]);
    $self->center_y($center->[1]);
    return ($center->[0] - $self->w/2, $center->[1] - $self->h/2);
}

1;

