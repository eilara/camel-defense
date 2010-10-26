package CamelDefense::Cursor::Tower;

use Moose;
use MooseX::Types::Moose qw(Str);

has state => (is => 'rw', isa => Str, default => 'place_tower');

with 'CamelDefense::Role::TowerView';

sub init_image_file { '../data/cursor_shadow_place_tower.png' }

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->load("../data/cursor_shadow_${new_state}.png")
        if $new_state ne 'normal';
}

# render tower range on top of everything when we can build here
after render => sub {
    my ($self, $surface) = @_;
    return unless $self->state eq 'place_tower';
    $self->render_range($surface, 0x027202FF);
};

1;

