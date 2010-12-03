package CamelDefense::Grid;

# the grid:
#    * shows gridlines
#    * shows waypoints
#    * keeps the grid cells and answers the question "can I build on a cell?"
#    * updates grid cells with items that are placed in them: waypoints,
#      path cells

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use List::Util qw(min max);
use aliased 'CamelDefense::Grid::Markers';
use aliased 'CamelDefense::Waypoints';

has cells => (
    is         => 'ro',
    lazy_build => 1,
    isa        => ArrayRef[ArrayRef['Grid::Cell']],
);

# a grid has markers which show the grid lines and handle translation xy -> cells
with 'MooseX::Role::BuildInstanceOf' => {target => Markers, prefix => 'marks'};
has '+marks' => (handles => [qw(
    grid_color
    row_marks col_marks
    find_cell compute_cell_center
)]);

# a grid has waypoints which can be queried by objects that need to move
# through them
with 'MooseX::Role::BuildInstanceOf' =>
    {target => Waypoints, prefix => 'waypoint_list'};
has '+waypoint_list' => (handles => [qw(points_px)]);
around merge_waypoint_list_args => sub {
    my ($orig, $self) = @_;
    return (marks => $self->marks, $self->$orig);
};

# TODO: above should be written so:
# compose_from
#     target  => Waypoints,
#     prefix  => 'waypoint_list',
#     handles => [qw(points_px)],
#     merge   => sub {
#         my ($orig, $self) = @_;
#         return (marks => $self->marks, $self->$orig);
#     };
    

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

# is this a type of cell that cursor shadow would look nice on
sub should_show_shadow {
    my ($self, $x, $y) = @_;
    my ($col, $row) = @{ $self->find_cell($x, $y) };
    my $cells = $self->cells->[$col];
    return 0 unless $col; # out of screen shows no shadow
    my $cell = $cells->[$row];
    return 0 unless $row; # out of screen shows no shadow
    return
        $cell->has_contents
            ? $cell->is_tower? 0: 1
            : 1;
}

sub render_markers {
    my ($self, $surface) = @_;
    $self->marks->render($surface);
}

sub render {
    my ($self, $surface) = @_;
    $self->waypoint_list->render($surface);
}

package Grid::Cell;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);

has contents => (is => 'rw', predicate => 'has_contents');

sub is_tower {
    my $self = shift;
    return $self->contents eq 'tower';
}

1;

