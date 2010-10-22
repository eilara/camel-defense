package CamelDefense::Role::GridAlignedSprite;

use Moose::Role;
use MooseX::Types::Moose qw(Num);
use aliased 'SDLx::Sprite';

requires 'compute_cell_center', 'image_file';

has [qw(x y)] => (is => 'rw', required => 1, isa => Num);

has sprite => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Sprite, 
    handles    => [qw(load draw w h)],
);

has [qw(center_x center_y)] => (is => 'rw');

sub BUILD {
    my $self = shift;
    $self->center_x($self->sprite->x + $self->w/2);
    $self->center_y($self->sprite->y + $self->h/2);
}

sub _build_sprite {
    my $self = shift;
    my $center = $self->compute_cell_center($self->x, $self->y);
    my $sprite = Sprite->new(image => $self->image_file);
    $sprite->x($center->[0] - $sprite->w/2);
    $sprite->y($center->[1] - $sprite->h/2);
    return $sprite;
}

sub render {
    my ($self, $surface) = @_;
    $self->draw($surface);
}

1;

