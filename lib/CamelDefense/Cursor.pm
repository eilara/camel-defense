package CamelDefense::Cursor;

use Moose;
use MooseX::Types::Moose qw(Bool Str);

has state => (is => 'rw', required => 1, isa => Str, default => 'normal');

has is_visible => (is => 'rw', required => 1, isa => Bool, default => 0);

with 'CamelDefense::Role::Sprite';

sub init_image_file { '../data/normal.png' }

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->load("../data/$new_state.png");
}

around render => sub {
    my ($orig, $self, $surface) = @_;
    $orig->($self, $surface) if $self->is_visible;
};

1;

