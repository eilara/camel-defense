package CamelDefense::Wave::Manager;

use Moose;
use MooseX::Types::Moose qw(ArrayRef);
use aliased 'CamelDefense::Wave';
use aliased 'CamelDefense::World';

has world  => (is => 'ro', required => 1, isa => World, handles => [qw(
    points_px
)], weak_ref => 1);

# the wave manager creates and manages waves
has waves => (
    is       => 'rw',
    required => 1,
    isa      => ArrayRef[Wave],
    default  => sub { [] },
);
with 'MooseX::Role::BuildInstanceOf' => {target => Wave, type => 'factory'};
around merge_wave_args => sub {
    my ($orig, $self) = @_;
    my %args = $self->$orig;
    push @{ $args{creep_args} ||= []}, (waypoints => $self->points_px);
    return %args;
};

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{$self->waves};
}

sub move {
    my ($self, $dt) = @_;
    my $wc = scalar @{$self->waves};
    my @waves = map { $_->move($dt) } @{ $self->waves };
    $self->waves(\@waves);
}

sub start_wave {
    my $self = shift;
    push @{ $self->waves }, $self->wave;
}

sub aim {
    my ($self, $sx, $sy, $range) = @_;
    for my $wave (@{ $self->waves }) {
        for my $creep (@{ $wave->creeps }) {
            if (
                $creep->is_alive &&
                $creep->is_in_range($sx, $sy, $range)
            ) {
                return $creep;
            }
        }
    }
}

1;

