package CamelDefense::Grid::Markers;

# draws grid markers and converts from xy -> cell index

use Moose;
use MooseX::Types::Moose qw(Int ArrayRef);
use aliased 'CamelDefense::Grid::Axis';

has [qw(w h)] => (
    is       => 'ro',
    required => 1,
    isa      => Int,
);

has spacing => (
    is       => 'ro',
    required => 1,
    isa      => Int,
    default  => 32,
);

has grid_color => (
    is       => 'ro',
    required => 1,
    isa      => Int,
    default  => 0x1F1F1FFF,
);

has bg_color => (
    is       => 'ro',
    required => 1,
    isa      => Int,
    default  => 0x5F5F5FFF,
);

for my $ax (qw(x y)) {
    my $col_or_row = $ax eq 'x'? 'col': 'row';
    has "${ax}_axis" => (
        is         => 'ro',
        lazy_build => 1,
        isa        => Axis,
        handles    => {"${col_or_row}_marks" => 'marks'},
    );
}
    
sub _build_x_axis { shift->_build_axis('w') }
sub _build_y_axis { shift->_build_axis('h') }
    
sub _build_axis {
    my ($self, $accessor) = @_;
    return Axis->new(
        size    => $self->$accessor,
        spacing => $self->spacing,
    );
}

sub find_cell {
    my ($self, $x, $y) = @_;
    my $s = $self->spacing;
    return [int( $x / $s ), int( $y / $s )];
}

sub compute_cell_center {
    my ($self, $x, $y) = @_;
    my $s = $self->spacing;
    my $half = $s / 2;
    return [
        int( $x / $s ) * $s + $half,
        int( $y / $s ) * $s + $half,
    ];
}

sub compute_cell_center_from_ratio {
    my ($self, $rx, $ry) = @_;
    my $s = $self->spacing;
    my $half = $s / 2;
    return [
        int( ($rx*$self->w) / $s ) * $s + $half,
        int( ($ry*$self->h) / $s ) * $s + $half,
    ];
}

sub render {
    my ($self, $surface) = @_;
    my ($w, $h, $c) = ($self->w, $self->h, $self->grid_color);
    $surface->draw_rect([0, 0, $w, $h], $self->bg_color);
    $surface->draw_line([$_, 0], [$_, $h], $c, 0) for @{ $self->col_marks };
    $surface->draw_line([0, $_], [$w, $_], $c, 0) for @{ $self->row_marks };
}

1;

