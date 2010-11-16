package CamelDefense::Role::Active;

# active objects have a coro and must implement start()
# a new coro is created on construction which runs your start()

use Moose::Role;
use Coro;

requires 'start';

has coro => (
    is       => 'rw',
    isa      => 'Coro',
    required => 1,
    default  => sub { my $self = shift; return async { $self->start } },
    handles  => {
        deactivate => 'cancel',
    },
);

1;

