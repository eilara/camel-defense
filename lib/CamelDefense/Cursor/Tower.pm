package CamelDefense::Cursor::Tower;

# the cursor tower shadow shows an outline of the tower to be build
# or that can't be build currently
# also renders the range of the proposed tower

use Moose;
use MooseX::Types::Moose qw(Str);

has state => (is => 'rw', isa => Str, default => 'place_tower');

extends 'CamelDefense::Tower::Base';
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
}

# render tower range on top of everything only when we can build here
before render => sub {
    my ($self, $surface) = @_;
    return unless $self->state eq 'place_tower';
    $self->render_range($surface, 0x027202FF, 0x02720250);
};

1;

