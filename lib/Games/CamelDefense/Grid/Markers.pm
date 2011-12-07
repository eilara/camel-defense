package Games::CamelDefense::Grid::Markers;

# draws grid markers and converts from xy -> cell index

use Games::CamelDefense::Class qw(Grid::Markers::Axis);

has spacing => (
    is       => 'ro',
    required => 1,
    isa      => Int,
    default  => 24,
);

has grid_color => (
    is       => 'ro',
    required => 1,
    isa      => Int,
    default  => 0x2F2F2FFF,
);

consume qw(
    Geometry::Rectangular
    Render::Paintable
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

sub compute_cell_pos {
    my ($self, $xy) = @_;
    my $s = $self->spacing;
    my ($x, $y) = @{ $self->xy };
    return [int( ($xy->[0] - $x) / $s ), int( ($xy->[1] - $y) / $s )];
}

sub cell_center_xy {
    my ($self, $xy) = @_;
    my $pos    = V( @{ $self->compute_cell_pos($xy) } );
    my $s      = $self->spacing;
    my $offset = $self->xy_vec;
    return [@{ $offset + $pos * $s + V($s/2, $s/2) }];
}

sub paint {
    my ($self, $surface) = @_;
    my ($x, $y, $w, $h, $c) = (@{$self->xy}, @{$self->size}, $self->grid_color);
    $surface->draw_line([$x + $_, $y], [$x + $_, $y + $h], $c, 0) for @{ $self->col_marks };
    $surface->draw_line([$x, $y + $_], [$x + $w, $y + $_], $c, 0) for @{ $self->row_marks };
}

1;

