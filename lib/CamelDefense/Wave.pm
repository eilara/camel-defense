package CamelDefense::Wave;

# the wave creates creep_count creeps every inter creep wait seconds

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Creep';

has creep_count      => (is => 'ro', required => 1, isa => Int, default => 6);
has inter_creep_wait => (is => 'ro', required => 1, isa => Num, default => 1);

has last_creep_birth => (is => 'rw', isa => Num);
has next_creep_idx   => (is => 'rw', required => 1, isa => Int, default => 1);

has creeps =>
    (is => 'rw', required => 1, isa => ArrayRef[Creep], default => sub { [] });

with 'MooseX::Role::BuildInstanceOf' => {target => Creep, type => 'factory'};
around merge_creep_args => sub {
    my ($orig, $self) = @_;
    my $creep_idx = $self->next_creep_idx;
    $self->next_creep_idx($creep_idx + 1);
    $self->last_creep_birth(time);
    return (idx => $creep_idx, $self->$orig);
};

sub BUILD { shift->last_creep_birth(time) }    

# returns empty list if wave has no more living creeps or creeps to be born
# or self if it has such waves
sub move {
    my ($self, $dt) = @_;
    # TODO: should listen to channel of creep death broadcast on channel wave death
    my @creeps       = grep { $_->is_in_game } @{ $self->creeps };
    my $should_build = time - $self->last_creep_birth > $self->inter_creep_wait;
    my $still_left   = $self->creep_count - $self->next_creep_idx + 1;
    my $not_enough   = $still_left > 0;
    push(@creeps, $self->creep) if $should_build && $not_enough;
    $self->creeps(\@creeps);
    return (($still_left + scalar @creeps)? $self: ());
}

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->creeps };
}

1;

