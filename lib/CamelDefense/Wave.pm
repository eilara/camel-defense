package CamelDefense::Wave;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Creep';

has [qw(creep_size creep_vel waypoints)] => (is => 'ro', required => 1);

has creep_color => (is => 'ro');

has inter_creep_wait => (is => 'ro', required => 1, isa => Num);

has last_creep_birth => (is => 'rw', isa => Num);

has next_creep_idx => (is => 'rw', required => 1, isa => Int, default => 1);

has creeps =>
    (is => 'rw', required => 1, isa => ArrayRef[Creep], default => sub { [] });

sub BUILD { shift->last_creep_birth(time) }    

sub move {
    my ($self, $dt) = @_;
    my @creeps = map { $_->move($dt) } @{ $self->creeps };
    push(@creeps, $self->make_creep) if
        time - $self->last_creep_birth > $self->inter_creep_wait;
    $self->creeps(\@creeps);
}

sub make_creep {
    my $self = shift;
    my $c = $self->creep_color;
    my $creep_idx = $self->next_creep_idx;
    $self->next_creep_idx($creep_idx + 1);
    $self->last_creep_birth(time);
    return Creep->new(
        waypoints => $self->waypoints,
        v         => $self->creep_vel,
        size      => $self->creep_size,
        idx       => $creep_idx,
        (defined $c? (color => $c): ()),
    );
}

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->creeps };
}

1;

