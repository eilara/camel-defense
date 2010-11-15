package CamelDefense::Living::Base;

# base class for things that live and die
#
# * is_alive - can be hit
# * is_shown - needs to be drawn (enter animation,
#              leave animation, frozen, etc.)
# we start at is_alive=0, is_shown=1
# subclass set is_alive, is_shown as needed
#
# parent methods handle_child_not_shown, handle_child_not_alive,
# and handle_child_is_alive are called when the flags set to false

use Moose;
use MooseX::Types::Moose qw(Bool Int);
use aliased 'CamelDefense::Living::Parent';


has parent => (is => 'ro', required => 1, does => Parent, weak_ref => 1);
has idx    => (is => 'ro', required => 1, isa  => Int); # index in parent

has is_alive => (
    is           => 'rw',
    required     => 1,
    isa          => Bool,
    default      => 0,
    trigger      => sub {
        my $self = shift;
        my $method = 'handle_child_'. ($self->is_alive? 'is': 'not'). '_alive';
        $self->parent->$method($self);
    },
);

has is_shown => (
    is           => 'rw',
    required     => 1,
    isa          => Bool,
    default      => 1,
    trigger      => sub {
        my $self = shift;
#        use Data::Dumper;print Dumper $self unless $self->parent;
        $self->parent->handle_child_not_shown($self)
            unless $self->is_shown;
    },
);

1;

