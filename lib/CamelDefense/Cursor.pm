package CamelDefense::Cursor;

use Moose;
use MooseX::Types::Moose qw(Bool Str);
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Cursor::Tower';

has grid =>
    (is => 'ro', required => 1, isa => Grid, handles => [qw(should_show_shadow)]);

# state is one of: default, place_tower, cant_place_tower
has state         => (is => 'rw', required => 1, isa => Str , default => 'default');
has is_visible    => (is => 'rw', required => 1, isa => Bool, default => 0);
has render_shadow => (is => 'rw', required => 1, isa => Bool, default => 0);

# the shadow shows the tower about to be built in the cursor grid cell
# it is attached to the cursor
with 'MooseX::Role::BuildInstanceOf' => {target => Tower, prefix => 'shadow'};
has '+shadow' => (handles => [qw(points_px tower_def)]);
around merge_shadow_args => sub {
    my ($orig, $self) = @_;
    return (xy => $self->xy, grid => $self->grid, $self->$orig);
};

with 'CamelDefense::Role::Sprite';
with 'CamelDefense::Role::AnimatedSprite';

sub init_image_def {{
    image     => '../data/cursor.png',
    size      => [32, 32],
    sequences => [
        default          => [[0, 0]],
        place_tower      => [[1, 0]],
        cant_place_tower => [[2, 0]],
    ],
}}

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->sequence_animation($new_state);
    # some cells (e.g. tower) dont look nice with a shadow rendered on them
    if ($new_state ne 'default' && $self->should_show_shadow(@{$self->xy})) {
        $self->render_shadow(1);
        $self->shadow->change_to($new_state);
    } else {
        $self->render_shadow(0);
    }
}

around render => sub {
    my ($orig, $self, $surface) = @_;
    return unless $self->is_visible;
    $self->shadow->render($surface) if $self->render_shadow;
    $orig->($self, $surface);
};

after _update_sprite_xy => sub {
    my $self = shift;
    $self->shadow->xy($self->xy);
};

1;

