package CamelDefense::Role::AnimatedSprite;

# add to a sprite to get delegation on sprite animation methods

use Moose::Role;
use aliased 'SDLx::Sprite::Animated';

requires 'sprite';

has sprite_as_animated => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Animated, 
    handles    => {
        sequence_animation => 'sequence',
        next_animation     => 'next',
    },
);

sub _build_sprite_as_animated { shift->sprite }

1;

