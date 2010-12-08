package CamelDefense::Grid;

# the grid:
#    * shows gridlines
#    * shows waypoints
#    * keeps the grid cells and answers the questions "can I build on a cell?"
#      and "does this cell have a tower that I can select?"
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
                    $cells->[$path_col]->[$path_row]->set_as_path;
                }
            }
        }
        @last_wp_cell = ($col, $row);
        $cells->[$col]->[$row]->set_as_waypoint;
    }

    return $cells;
}

sub add_tower {
    my ($self, $x, $y, $tower) = @_;
    my $cell = $self->get_cell($x, $y);
    return unless $cell;
    $cell->set_as_tower($tower);
}

sub can_build {
    my ($self, $x, $y) = @_;
    my $cell = $self->get_cell($x, $y);
    return unless $cell;
    return !$cell->has_contents;
}

sub select_tower {
    my ($self, $x, $y) = @_;
    my $cell = $self->get_cell($x, $y);
    return unless $cell;
    return unless $cell->is_tower;
    my $tower = $cell->contents;
    $tower->set_selected;
    return $tower;
}

sub unselect_tower {
    my ($self, $tower) = @_;
    my $cell = $self->get_cell(@{$tower->xy});
    return unless $cell;
    return unless $cell->is_tower;
    $tower->set_unselected;
    return $tower;
}

# is this a type of cell that cursor shadow would look nice on
sub should_show_shadow {
    my ($self, $x, $y) = @_;
    my $cell = $self->get_cell($x, $y);
    return 0 unless $cell;
    return
        $cell->has_contents
            ? $cell->is_tower? 0: 1
            : 1;
}

sub get_cell {
    my ($self, $x, $y) = @_;
    my ($col, $row) = @{ $self->find_cell($x, $y) };
    my $cells = $self->cells->[$col];
    return undef unless $col; # out of screen
    my $cell = $cells->[$row];
    return undef unless $row; # out of screen
    return $cell;
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
    my $c = $self->contents;
    return ref($c) && $c->isa('CamelDefense::Tower::Base')? 1: 0;
}

sub set_as_tower {
    my ($self, $tower) = @_;
    $self->contents($tower);
}

sub set_as_path {
    my $self = shift;
    $self->contents('path');
}

sub set_as_waypoint {
    my $self = shift;
    $self->contents('waypoint');
}

1;

