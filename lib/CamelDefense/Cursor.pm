package CamelDefense::Cursor;

use Moose;
use MooseX::Types::Moose qw(Bool Int Str);
use aliased 'SDLx::Sprite';

has sprite => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Sprite, 
    handles    => [qw(x y load draw)],
);

has state => (is => 'rw', required => 1, isa => Str, default => 'normal');

has is_visible => (is => 'rw', required => 1, isa => Bool, default => 0);

sub _build_sprite {
    return Sprite->new(
        image => '../data/normal.png',
        x     => 0,
        y     => 0,
    );        
}

sub change_to {
    my ($self, $new_state) = @_;
    $self->state($new_state);
    $self->load("../data/$new_state.png");
}

sub render {
    my ($self, $surface) = @_;
    $self->draw($surface) if $self->is_visible;
}

1;

