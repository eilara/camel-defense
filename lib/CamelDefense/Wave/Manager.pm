package CamelDefense::Wave::Manager;

# the wave manager keeps a set of wave definitions
# every time a wave is requested with start_wave it shifts the
# next wave def out of the definitions and creates a wave out of it

use Moose;
use MooseX::Types::Moose qw(ArrayRef HashRef);
use aliased 'CamelDefense::Wave';
use aliased 'CamelDefense::Grid';

has grid  => (is => 'ro', required => 1, isa => Grid, handles => [qw(
    points_px
)]);

has wave_defs => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[HashRef],
    default  => sub { [] },
);

# the wave manager creates and manages waves
has waves => (
    is       => 'rw',
    required => 1,
    isa      => ArrayRef[Wave],
    default  => sub { [] },
);
with 'MooseX::Role::BuildInstanceOf' => {target => Wave, type => 'factory'};
around merge_wave_args => sub {
    my ($orig, $self)      = @_;
    my %args               = $self->$orig;
    my %wave_def           = %{ shift @{ $self->wave_defs }};
    my %next_creep_def     = @{ delete($wave_def{creep_args}) || [] };
    my %creep_args         = @{ $args{creep_args} ||= [] };
    $creep_args{waypoints} = $self->points_px;
    $args{creep_args}      = [%creep_args, %next_creep_def];
    return (%args, %wave_def);
};

# no more wave defs or waves
sub is_level_complete {
    my $self = shift;
    return (@{ $self->waves } + @{ $self->wave_defs })? 0: 1;
}

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
    return unless @{ $self->wave_defs };
    push @{ $self->waves }, $self->wave;
}

sub aim {
    my ($self, $sx, $sy, $range) = @_;
    for my $wave (@{ $self->waves }) {
        for my $creep (@{ $wave->creeps }) {
            return $creep if
                $creep->is_alive &&
                $creep->is_in_range($sx, $sy, $range);
        }
    }
}

1;

