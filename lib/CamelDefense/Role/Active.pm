package CamelDefense::Role::Active;

# active objects have a coro and must implement start()
# a new coro is created on construction which runs your start()

use Moose::Role;
use Coro;
use CamelDefense::Time qw(cleanup_thread);

requires 'start';

has coro => (
    is       => 'rw',
    isa      => 'Coro',
    required => 1,
    default  => sub { my $self = shift; return async { $self->start } },
);

sub deactivate {
    my $self = shift;
    my $coro = $self->coro;
    $coro->cancel;
    cleanup_thread($coro);
}

1;

