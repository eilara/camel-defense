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
use MooseX::Types::Moose qw(Bool Int Num ArrayRef);
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
        sprite_x => 'x',
        sprite_y => 'y',
    },
);

has image_def => (
    is       => 'rw',
    required => 1,
    default  => sub { shift->init_image_def },
    trigger  => sub {
        my $self = shift;
        my $image_def = $self->image_def;
        $self->load( $image_def->{image} );
        # TODO: bug- this should only happen for animated sprites
        $self->sprite->set_sequences( @{ $image_def->{sequences} } );
        $self->sequence_animation($self->state);
    },
);

has is_animated => (is => 'ro', lazy_build => 1, isa => Bool);
has [qw(w h)]   => (is => 'ro', lazy_build => 1, isa => Int);

# maybe memoize these two?
sub center_x {
    my $self = shift;
    return $self->sprite_x + $self->w/2;
}

sub center_y {
    my $self = shift;
    return $self->sprite_y + $self->h/2;
}

sub _build_sprite {
    my $self = shift;
    my $image_def = $self->image_def;
    my $sprite = $self->is_animated?
        $self->_build_animated_sprite($image_def):
        Sprite->new(image => $image_def);
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

sub _build_is_animated { ref(shift->image_def) eq 'HASH' }

sub _build_w {
    my $self = shift;
    return $self->is_animated? $self->image_def->{size}->[0]:
                               $self->sprite->w;
}

sub _build_h {
    my $self = shift;
    return $self->is_animated? $self->image_def->{size}->[1]:
                               $self->sprite->h;
}

sub _update_sprite_xy {
    my $self = shift;
    my ($x, $y) = $self->compute_sprite_xy;
    $self->sprite_x($x);
    $self->sprite_y($y);
}

# default implementation has sprite xy = self xy
sub compute_sprite_xy {
    my $self = shift;
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

