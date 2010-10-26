package CamelDefense::Cursor;

use Moose;
use MooseX::Types::Moose qw(Bool Str);
use aliased 'CamelDefense::Cursor::Tower';
use aliased 'CamelDefense::World';

has world      => (is => 'ro', required => 1, isa => World);
has state      => (is => 'rw', required => 1, isa => Str , default => 'normal');
has is_visible => (is => 'rw', required => 1, isa => Bool, default => 0);

# the shadow shows the tower about to be build in the cursor grid cell
# it is attached to the cursor
with 'MooseX::Role::BuildInstanceOf' => {target => Tower, prefix => 'shadow'};
has '+shadow' => (handles => [qw(points_px)]);
around merge_shadow_args => sub {
    my ($orig, $self) = @_;
    return (world => $self->world, xy => $self->xy, $self->$orig);
};

with 'CamelDefense::Role::Sprite';

sub init_image_file { '../data/cursor_normal.png' }

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->load("../data/cursor_${new_state}.png");
    $self->shadow->change_to($new_state);
}

around render => sub {
    my ($orig, $self, $surface) = @_;
    return unless $self->is_visible;
    $self->shadow->render($surface) if $self->state ne 'normal';
    $orig->($self, $surface);
};

after _update_sprite_xy => sub {
    my $self = shift;
    $self->shadow->xy($self->xy);
};

1;

