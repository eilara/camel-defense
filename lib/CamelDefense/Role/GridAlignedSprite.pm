package CamelDefense::Role::GridAlignedSprite;

# a role for a visual object which has a sprite
# and that sprite is aligned to a grid

use Moose::Role;
use MooseX::Types::Moose qw(Num);

requires 'compute_cell_center';

has [qw(center_x center_y)] => (is => 'rw', isa => Num);

with 'CamelDefense::Role::Sprite' => { -excludes => ['compute_sprite_xy'] };

sub BUILD {
    my $self = shift;
    $self->center_x($self->sprite_x + $self->w/2);
    $self->center_y($self->sprite_y + $self->h/2);
}

sub compute_sprite_xy {
    my ($self, $sprite) = @_;
    my $center = $self->compute_cell_center(@{ $self->xy });
    $self->center_x($center->[0]);
    $self->center_y($center->[1]);
    return ($center->[0] - $sprite->w/2, $center->[1] - $sprite->h/2);
}

1;

