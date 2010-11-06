package CamelDefense::Role::Sprite;

# a role for a visual object which has a sprite
# * answer init_image_file with path to image file
# * answer compute_sprite_xy with sprite xy, which may not be the same
#   self xy, because we may want this sprite centered on xy, aligned to
#   grid, etc.

use Moose::Role;
use MooseX::Types::Moose qw(Num Str ArrayRef);
use aliased 'SDLx::Sprite';

requires 'init_image_file';

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
    isa        => Sprite, 
    handles    => {
        load     => 'load',
        draw     => 'draw',
        w        => 'w',
        h        => 'h',
        sprite_x => 'x',
        sprite_y => 'y',
    },
);

has image_file => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    default  => sub { shift->init_image_file },
);

sub _build_sprite {
    my $self = shift;
    my $sprite = Sprite->new(image => $self->image_file);
    my ($x, $y) = $self->compute_sprite_xy($sprite);
    $sprite->x($x);
    $sprite->y($y);
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

