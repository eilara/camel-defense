package CamelDefense::Cursor::Tower;

# the cursor tower shadow shows an outline of the tower to be build
# or that can't be build currently
# also renders the range of the proposed tower
# refreshes image def and range def when tower def changes
# refreshes can/cant build state when change_to is called

use Moose;
use MooseX::Types::Moose qw(Num Str HashRef);
use aliased 'CamelDefense::Grid';
use CamelDefense::Tower::Laser;

has grid  => (is => 'ro', required => 1, isa => Grid, handles => [qw(compute_cell_center)]);
has state => (is => 'rw', required => 1, isa => Str, default => 'place_tower');

has range => (is => 'rw', lazy_build => 1, isa => Num);

# set to configure definition of next tower to create
# which will effect how the cursor shadow looks
has tower_def => (is => 'rw', required => 1, isa => HashRef, trigger => sub {
    my $self = shift;
    $self->range( $self->_build_range);
    $self->image_def( $self->init_image_def );
});

with 'CamelDefense::Role::GridAlignedSprite';
with 'CamelDefense::Role::AnimatedSprite';

sub _build_range {
    my $self = shift;
    $self->tower_type->merge_range($self->tower_def);
}

sub init_image_def {
    my $self = shift;
    return $self->tower_type->merge_image_def($self->tower_def);
}

# what is clss of currently defined tower?
sub tower_type { shift->tower_def->{type} || 'CamelDefense::Tower::Laser' }

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->sequence_animation($new_state)
        if $new_state ne 'default';
}

# render tower range on top of everything only when we can build here
before render => sub {
    my ($self, $surface) = @_;
    return unless $self->state eq 'place_tower';
    my $range = $self->range;
    $surface->draw_circle_filled(
        [$self->center_x, $self->center_y],
        $range,
        0x02720230,
    );
    $surface->draw_circle(
        [$self->center_x, $self->center_y],
        $range,
        0x024202FF,
        1,
    );
};

1;

