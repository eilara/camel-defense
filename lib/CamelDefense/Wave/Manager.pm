package CamelDefense::Wave::Manager;

# the wave manager keeps a set of wave definitions
# every time a wave is requested with start_wave it shifts the
# next wave def out of the definitions and creates a wave out of it

use Moose;
use MooseX::Types::Moose qw(Int ArrayRef HashRef CodeRef);
use aliased 'CamelDefense::Wave';
use aliased 'CamelDefense::Grid';

with 'CamelDefense::Living::Parent';

has grid  => (is => 'ro', required => 1, isa => Grid, handles => [qw(
    points_px
)]);

has wave_defs => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[HashRef],
    default  => sub { [] },
);

has level_complete_handler =>
    (is => 'ro', required => 1, isa => CodeRef, default => sub { sub {} });

has next_wave_idx => (is => 'rw', required => 1, isa => Int , default => 0);

# the wave manager creates and manages waves
with 'MooseX::Role::BuildInstanceOf' => {target => Wave, type => 'factory'};
around merge_wave_args => sub {
    my ($orig, $self)      = @_;
    my %args               = $self->$orig;
    my %wave_def           = %{ shift @{ $self->wave_defs }};
    my %next_creep_def     = @{ delete($wave_def{creep_args}) || [] };
    my %creep_args         = @{ $args{creep_args} ||= [] };
    $creep_args{waypoints} = $self->points_px;
    $args{creep_args}      = [%creep_args, %next_creep_def];
    my $idx                = $self->next_wave_idx;
    $self->next_wave_idx($idx + 1);
    return (%args, parent => $self, idx => $idx, %wave_def);
};

after handle_child_not_shown => sub {
    my $self = shift;
    # when no more wave defs or waves
    $self->level_complete_handler->() unless
        @{ $self->children } + @{ $self->wave_defs };
};

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{$self->children};
}

sub start_wave {
    my $self = shift;
    return unless @{ $self->wave_defs };
    push @{ $self->children }, $self->wave;
}

sub aim {
    my ($self, @range) = @_;
    for my $wave (@{ $self->living_children }) {
        my $creep = $wave->aim(@range);
        return $creep if $creep;
    }
}

1;

