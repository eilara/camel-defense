package CamelDefense::Cursor::Tower;

use Moose;
use MooseX::Types::Moose qw(Num Str);
use Time::HiRes qw(time);

has state => (is => 'rw', isa => Str, default => 'can_build');

with 'CamelDefense::Role::TowerView';

sub init_image_file {
    '../data/cursor_shadow_place_tower.png';
}

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->load("../data/cursor_shadow_${new_state}.png")
        unless $self->state eq 'normal';
}

1;

