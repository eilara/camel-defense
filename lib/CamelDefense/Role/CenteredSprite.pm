package CamelDefense::Role::CenteredSprite;

# a role for a visual object which has a sprite
# and that sprite is centered on the visual object xy

use Moose::Role;

with 'CamelDefense::Role::Sprite' => { -excludes => ['compute_sprite_xy'] };

sub compute_sprite_xy {
    my ($self, $sprite) = @_;
    my ($x, $y) = @{ $self->xy };
    # sdl rect does int(), we want round
    return ($x - $sprite->w / 2 + 0.5, $y - $sprite->h / 2 + 0.5);
}

1;

