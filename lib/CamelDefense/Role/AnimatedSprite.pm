package CamelDefense::Role::AnimatedSprite;

# add to a sprite to get delegation on sprite animation methods

use Moose::Role;
use aliased 'SDLx::Sprite::Animated';

requires 'sprite';

has animated_sprite => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Animated, 
    handles    => {
        set_sequences => 'set_sequences',
    },
);

sub _build_animated_sprite { shift->sprite }

1;

