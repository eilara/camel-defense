package CamelDefense::Tower::Manager;

# call configure_next_tower with an index in tower_defs
# then call build_tower to build a tower at the cursor

use Moose;
use MooseX::Types::Moose qw(Bool Int ArrayRef HashRef);
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Tower';
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';

has wave_manager => (is => 'ro', required => 1, isa => WaveManager);

has cursor => (is => 'ro', required => 1, isa => Cursor);
has grid   => (is => 'ro', required => 1, isa => Grid, handles => [qw(
    grid_color add_tower
)]);

# true if surface needs redraw because towers changed
has is_dirty => (is => 'rw', required => 1, isa => Bool, default => 1);

# index in tower defs on next tower to build
has tower_def_idx => (is => 'rw', isa => Int, default => 0);

# array of tower definitions, each a has of tower constructor args
has tower_defs => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[HashRef],
    default  => sub { [] },
);

# the tower manager creates and manages towers
has towers => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[Tower],
    default  => sub { [] },
);
with 'MooseX::Role::BuildInstanceOf' => {target => Tower, type => 'factory'};
around merge_tower_args => sub {
    my ($orig, $self) = @_;
    my ($x, $y) = @{$self->cursor->xy};
    $self->add_tower($x, $y); # fills the tower cell in the grid
    $self->is_dirty(1);       # mark the bg layer as needing redraw
    return (
        grid          => $self->grid,
        wave_manager  => $self->wave_manager,
        xy            => [$x, $y],
        %{ $self->tower_defs->[ $self->tower_def_idx ] },
        $self->$orig,
    );
};

sub configure_next_tower {
    my ($self, $tower_def_idx) = @_;
    $self->tower_def_idx($tower_def_idx);
    $self->cursor->tower_def($self->tower_defs->[ $tower_def_idx ]);
}

sub build_tower {
    my $self = shift;
    push @{ $self->towers }, $self->tower;
}

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{$self->towers};
    $self->is_dirty(0); # no need to render until towers change
}

sub render_bg {
    my ($self, $surface) = @_;
    my $grid_color = $self->grid_color;
    $_->render_range($surface, $grid_color) for @{ $self->towers };
}

1;

