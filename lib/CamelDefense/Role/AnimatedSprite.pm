package CamelDefense::Role::AnimatedSprite;

# add to a sprite to get delegation on sprite animation methods
# and the animate_sprite method

use Moose::Role;
use Coro::Timer qw(sleep);
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
    $self->sequence_animation($sequence);
    for my $frame (0..$frame_count) {
        sleep $sleep;
        $self->next_animation;
    }
    sleep $sleep;
}

1;

