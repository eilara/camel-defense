package CamelDefense::Wave;

# the wave creates creep_count creeps every inter creep wait seconds

use Moose;
use MooseX::Types::Moose qw(Bool Num Int ArrayRef);
use aliased 'CamelDefense::Creep';
use CamelDefense::Time qw(interval);

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
    interval
        times => $self->creep_count,
        sleep => $self->inter_creep_wait,
        code  => sub { push @{$self->children}, $self->creep };
    $self->is_done_creating(1);
}

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->children };
}

sub aim_one {
    my ($self, $x, $y, $range) = @_;
    for my $creep (@{ $self->living_children }) {
        return $creep if
            $creep->is_in_range($x, $y, $range);
    }
}

sub aim_all {
    my ($self, $x, $y, $range) = @_;
    return grep { $_->is_in_range($x, $y, $range) }
               @{ $self->living_children };
}

1;

__END__


