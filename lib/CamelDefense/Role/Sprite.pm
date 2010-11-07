package CamelDefense::Role::Sprite;

# a role for a visual object which has a sprite
# * answer init_image_def with path to image file or animation spec
#   if it is a hash ref the sprite will be animated, in which case
#   you may want to consume the AnimatedSprite role as well, and
#   get delegation on some sprite animation methods
# * answer compute_sprite_xy with sprite xy, which may not be the same
#   self xy, because we may want this sprite centered on xy, aligned to
#   grid, etc.

use Moose::Role;
use MooseX::Types::Moose qw(Num Str ArrayRef);
use aliased 'SDL::Rect';
use aliased 'SDLx::Sprite';
use aliased 'SDLx::Sprite::Animated';

requires 'init_image_def';

has xy => (
    is       => 'rw',
    required => 1,
    isa      => ArrayRef[Num],
    default  => sub { [0,0] },
    trigger  => sub { shift->_update_sprite_xy },
);

has sprite => (
    is         => 'ro',
    lazy_build => 1,
    handles    => {
        load     => 'load',
        draw     => 'draw',
        w        => 'w',
        h        => 'h',
        sprite_x => 'x',
        sprite_y => 'y',
    },
);

has image_def => (
    is       => 'ro',
    required => 1,
    default  => sub { shift->init_image_def },
);

sub _build_sprite {
    my $self = shift;
    my $image_def = $self->image_def;
    my $sprite = ref($image_def) eq 'HASH'?
        $self->_build_animated_sprite($image_def):
        Sprite->new(image => $self->image_def);
    my ($x, $y) = $self->compute_sprite_xy($sprite);
    $sprite->x($x);
    $sprite->y($y);
    return $sprite;
}

sub _build_animated_sprite {
    my ($self, $def) = @_;
    my $size = $def->{size};
    my $sprite = Animated->new(
        image => $def->{image},
        rect  => Rect->new(0, 0, $size->[0], $size->[1]),
    );
    my $sequences = $def->{sequences};
    $sprite->set_sequences(@$sequences);
    $sprite->sequence($sequences->[0]);
    return $sprite;
}

sub _update_sprite_xy {
    my $self = shift;
    my ($x, $y) = $self->compute_sprite_xy($self->sprite);
    $self->sprite_x($x);
    $self->sprite_y($y);
}

# default implementation has sprite xy = self xy
sub compute_sprite_xy {
    my ($self, $sprite) = @_;
    return (@{ $self->xy });
}

sub render {
    my ($self, $surface) = @_;
    $self->draw($surface);
}

sub x {
    my $self = shift;
    return $self->xy->[0] unless @_;
    my $x = shift;
    $self->xy([$x, $self->xy->[1]]);
}

sub y {
    my $self = shift;
    return $self->xy->[1] unless @_;
    my $y = shift;
    $self->xy([$self->xy->[0], $y]);
}

1;

