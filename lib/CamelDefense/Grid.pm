package CamelDefense::Grid;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use List::Util qw(min max);
use aliased 'CamelDefense::Grid::Markers';
use aliased 'CamelDefense::Waypoints';

has [qw(w h spacing)] =>
    ( is => 'ro', required => 1, isa => Int);

has [qw(grid_color bg_color waypoints_color path_color)] =>
    (is => 'rw', isa => Int);

has waypoints => (is => 'ro', required => 1);

has cells => (
    is         => 'ro',
    lazy_build => 1,
    isa        => ArrayRef[ArrayRef['Grid::Cell']],
);

has markers => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Markers,
    handles    => [qw(row_marks col_marks find_cell compute_cell_center)],
);

has waypoint_list => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Waypoints,
    handles    => [qw(points_px)],
);

sub _build_markers {
    my $self = shift;
    my $grid_color = $self->grid_color;
    my $bg_color = $self->bg_color;
    my $markers = Markers->new(
        w       => $self->w,
        h       => $self->h,
        spacing => $self->spacing,
        (defined($grid_color)? (color => $grid_color):()),
        (defined($bg_color)? (bg_color => $bg_color):()),
    );
    $self->grid_color($markers->color); # in case someone wants to know the grid color
    return $markers;
}

sub _build_waypoint_list {
    my $self = shift;
    my $waypoints_color = $self->waypoints_color;
    my $path_color = $self->path_color;
    return Waypoints->new(
        markers => $self->markers,
        points  => $self->waypoints,
        (defined($waypoints_color)? (color => $waypoints_color):()),
        (defined($path_color)? (path_color => $path_color):()),
    );
}

sub _build_cells {
    my $self = shift;
    my ($rows, $cols) = ($self->row_marks, $self->col_marks);
    my $cells = [map {[map { Grid::Cell->new } @$rows]} @$cols];

    # fill path into cells so that we can answer can_build on a cell
    my @last_wp_cell;
    for my $wp (@{ $self->points_px }) {
        my ($col, $row) = @{ $self->find_cell($wp->[0], $wp->[1]) };
        if (@last_wp_cell) {
            my ($lcol, $lrow) = (@last_wp_cell);
            for my $path_col (min($lcol, $col)..max($lcol, $col)) {
                for my $path_row (min($lrow, $row)..max($lrow, $row)) {
                    $cells->[$path_col]->[$path_row]->contents("path");
                }
            }
        }
        @last_wp_cell = ($col, $row);
        $cells->[$col]->[$row]->contents("waypoint");
    }

    return $cells;
}

sub add_tower {
    my ($self, $x, $y) = @_;
    my ($col, $row) = @{ $self->find_cell($x, $y) };
    my $cell = $self->cells->[$col]->[$row];
    $cell->contents('tower');
}

sub can_build {
    my ($self, $x, $y) = @_;
    my ($col, $row) = @{ $self->find_cell($x, $y) };
    my $cell = $self->cells->[$col]->[$row];
    return !$cell->has_contents;
}

sub render_markers {
    my ($self, $surface) = @_;
    $self->markers->render($surface);
}

sub render {
    my ($self, $surface) = @_;
    $self->waypoint_list->render($surface);
}

package Grid::Cell;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);

has contents => (is => 'rw', predicate => 'has_contents');


1;

