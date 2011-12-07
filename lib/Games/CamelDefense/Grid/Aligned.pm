package Games::CamelDefense::Grid::Aligned;

use Games::CamelDefense::Role qw(Grid::Markers);

consume 'Geometry::Rectangular';

has markers => (
    is       => 'ro',
    required => 1,
    isa      => Markers,
    handles  => [qw(cell_center_xy)],
);

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    $args{centered} = 1;
    return $class->$orig(%args);
};

after BUILD => sub {
    my $self = shift;
    $self->align_to_cell_center($self->xy);
};

sub align_to_cell_center {
    my ($self, $xy) = @_;
    $self->xy( $self->cell_center_xy($xy) );
}

1;


=head1 NAME

Games::CamelDefense::Grid::Aligned - a positionable centered on cell center


=head1 DESCRIPTION

Treat as a normal positionable, but provide with grid markers in constructor.
You can set xy using C<align_to_cell_center($xy)>, where C<$xy> is a 2D 
array ref. The positionable will always be centered on the cell center of
the cell that includes the C<$xy> position.


=head1 REQUIRES

L<Games::CamelDefense::Grid::Markers> in C<markers> key of constructor


=head1 DOES

L<Games::CamelDefense::Geometry::Rectangular>


=cut


