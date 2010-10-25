package CamelDefense::Wave;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Creep';

has inter_creep_wait => (is => 'ro', required => 1, isa => Num);

has last_creep_birth => (is => 'rw', isa => Num);

has next_creep_idx => (is => 'rw', required => 1, isa => Int, default => 1);

has creeps =>
    (is => 'rw', required => 1, isa => ArrayRef[Creep], default => sub { [] });

sub BUILD { shift->last_creep_birth(time) }    

sub move {
    my ($self, $dt) = @_;
    my @creeps = map { $_->move($dt) } @{ $self->creeps };
    push(@creeps, $self->creep) if
        time - $self->last_creep_birth > $self->inter_creep_wait;
    $self->creeps(\@creeps);
}

with 'MooseX::Role::BuildInstanceOf' => {target => Creep, type => 'factory'};
around merge_creep_args => sub {
    my ($orig, $self) = @_;
    my $creep_idx = $self->next_creep_idx;
    $self->next_creep_idx($creep_idx + 1);
    $self->last_creep_birth(time);
    return (
        idx => $creep_idx,
        $self->$orig,
    );
};

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->creeps };
}

1;

