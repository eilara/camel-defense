package CamelDefense::Role::AnimatedSprite;

# add to a sprite to get delegation on sprite animation methods
# and the animate_sprite method

use Moose::Role;
use CamelDefense::Time qw(interval);
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

sub animate_sprite {
    my ($self, $sequence, $frame_count, $sleep) = @_;
    interval
        times => $frame_count,
        sleep => $sleep,
        step  => sub { $self->next_animation },
        start => sub { $self->sequence_animation($sequence) };
}

1;
