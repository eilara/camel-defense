package CamelDefense::Living::Parent;

# role for a parent of living things
# living things have children that need to be shown
# and living children that can be killed

use Moose::Role;
use MooseX::Types::Moose qw(Int ArrayRef);

has [qw(children living_children)] => (
    is       => 'rw',
    required => 1,
    isa      => ArrayRef,
    default  => sub { [] },
);

has next_child_idx => (is => 'rw', required => 1, isa => Int , default => 0);

sub update_next_child_idx {
    my $self = shift;
    my $idx = $self->next_child_idx;
    $self->next_child_idx($idx + 1);
    return $idx;
}

sub handle_child_not_shown {
    my ($self, $child) = @_;
    $self->children([grep { $_ ne $child } @{$self->children}]);
}

sub handle_child_not_alive {
    my ($self, $child) = @_;
    $self->living_children([grep { $_ ne $child } @{$self->living_children}]);
}

sub handle_child_is_alive {
    my ($self, $child) = @_;
    push @{$self->living_children}, $child;
}

1;

