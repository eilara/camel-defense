package CamelDefense::Wave;

# the wave creates creep_count creeps every inter creep wait seconds

use Moose;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Bool Num Int ArrayRef);
use aliased 'CamelDefense::Creep';

extends 'CamelDefense::Living::Base';

has creep_count      => (is => 'ro', required => 1, isa => Int , default => 6);
has inter_creep_wait => (is => 'ro', required => 1, isa => Num , default => 1);

has next_creep_idx   => (is => 'rw', required => 1, isa => Int , default => 0);
has is_done_creating => (is => 'rw', required => 1, isa => Bool, default => 0);

with 'MooseX::Role::BuildInstanceOf' => {target => Creep, type => 'factory'};
around merge_creep_args => sub {
    my ($orig, $self) = @_;
    my $creep_idx = $self->next_creep_idx;
    $self->next_creep_idx($creep_idx + 1);
    return (idx => $creep_idx, parent => $self, $self->$orig);
};

with qw(
    CamelDefense::Role::Active
    CamelDefense::Living::Parent
);

after handle_child_not_shown => sub {
    my $self = shift;
    $self->is_shown(0) if
        $self->is_done_creating &&
        !@{ $self->children };
};

after handle_child_not_alive => sub {
    my $self = shift;
    $self->is_alive(0) if
        $self->is_done_creating &&
        !@{ $self->living_children };
};

after handle_child_is_alive => sub {
    my ($self, $child) = @_;
    $self->is_alive(1) unless $self->is_alive;
};

sub start {
    my $self = shift;
    my $sleep = $self->inter_creep_wait;
    for (1..$self->creep_count) {
        push @{$self->children}, $self->creep;
        sleep $sleep;
    }
    $self->is_done_creating(1);
}

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->children };
}

sub aim {
    my ($self, $x, $y, $range) = @_;
    for my $creep (@{ $self->living_children }) {
        return $creep if
            $creep->is_in_range($x, $y, $range);
    }
}

1;

__END__


# returns empty list if wave has no more living creeps or creeps to be born
# or self if it has such waves
sub move {
    my ($self, $dt) = @_;
    # TODO: should listen to channel of creep death broadcast on channel wave death
    my @creeps       = grep { $_->is_shown } @{ $self->creeps };
    my $should_build = time - $self->last_creep_birth > $self->inter_creep_wait;
    my $still_left   = $self->creep_count - $self->next_creep_idx + 1;
    my $not_enough   = $still_left > 0;
    push(@creeps, $self->creep) if $should_build && $not_enough;
    $self->creeps(\@creeps);
    return (($still_left + scalar @creeps)? $self: ());
}
