package CamelDefense::Cursor::Tower;

# the cursor tower shadow shows an outline of the tower to be build
# or that can't be build currently
# also renders the range of the proposed tower

use Moose;
use MooseX::Types::Moose qw(Num Str HashRef);
use aliased 'CamelDefense::Grid';

has grid  => (is => 'ro', required => 1, isa => Grid, handles => [qw(compute_cell_center)]);
has state => (is => 'rw', required => 1, isa => Str, default => 'place_tower');
has range => (is => 'rw', required => 1, isa => Num, default => 100); # in pixels

# set to configure definition of next tower to create
# which will effect how the cursor shadow looks
has tower_def => (is => 'rw', isa => HashRef, default => sub { {} });

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

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->sequence_animation($new_state)
        if $new_state ne 'normal';
    my $tower_def = $self->tower_def;
    $self->range($tower_def->{range}) if exists $tower_def->{range};
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

