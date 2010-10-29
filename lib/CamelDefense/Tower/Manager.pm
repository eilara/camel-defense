package CamelDefense::Tower::Manager;

use Moose;
use MooseX::Types::Moose qw(ArrayRef);
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Tower';
use aliased 'CamelDefense::World';

has cursor => (is => 'ro', required => 1, isa => Cursor);
has world  => (is => 'ro', required => 1, isa => World, handles => [qw(
    grid_color add_tower
)]);

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
    $self->add_tower($x, $y);
    return (world => $self->world, xy => [$x, $y], $self->$orig);
};

sub move {
    my ($self, $dt) = @_;
    $_->move($dt) for @{ $self->towers };
}

sub render {
    my ($self, $surface) = @_;
    $_->render($surface) for @{$self->towers};
}

sub render_bg {
    my ($self, $surface) = @_;
    my $grid_color = $self->grid_color;
    $_->render_range($surface, $grid_color) for @{ $self->towers };
}

sub build_tower {
    my $self = shift;
    push @{ $self->towers }, $self->tower;
}

1;

