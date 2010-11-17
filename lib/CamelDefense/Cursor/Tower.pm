package CamelDefense::Cursor::Tower;

# the cursor tower shadow shows an outline of the tower to be build
# or that can't be build currently
# also renders the range of the proposed tower

use Moose;
use MooseX::Types::Moose qw(Num Str);
use aliased 'CamelDefense::Grid';

has grid  => (is => 'ro', required => 1, isa => Grid);
has state => (is => 'rw', required => 1, isa => Str, default => 'place_tower');
has range => (is => 'ro', required => 1, isa => Num, default => 100); # in pixels

with 'CamelDefense::Role::GridAlignedSprite';
with 'CamelDefense::Role::AnimatedSprite';

sub init_image_def {{
    image     => '../data/cursor_shadow.png',
    size      => [15, 15],
    sequences => [
        place_tower      => [[0, 0]],
        cant_place_tower => [[1, 0]],
    ],
}}

sub compute_cell_center { shift->grid->compute_cell_center(@_) }

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->sequence_animation($new_state)
        if $new_state ne 'normal';
}

# render tower range on top of everything only when we can build here
before render => sub {
    my ($self, $surface) = @_;
    return unless $self->state eq 'place_tower';
    $surface->draw_circle_filled(
        [$self->center_x, $self->center_y],
        $self->range,
        0x02720250,
    );
    $surface->draw_circle(
        [$self->center_x, $self->center_y],
        $self->range,
        0x027202FF,
        1,
    );
};

1;

