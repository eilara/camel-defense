package CamelDefense::Grid::Axis;

use Moose;
use MooseX::Types::Moose qw(Int ArrayRef);

has [qw(size spacing)] => (
    is       => 'ro',
    required => 1,
    isa      => Int,
);

has marks => (
    is         => 'ro',
    lazy_build => 1,
    isa        => ArrayRef[Int],
);

has type => (
    is         => 'ro',
    lazy_build => 1,
    isa        => ArrayRef[Int],
);

sub _build_marks {
    my $self  = shift;
    my $s     = $self->size;
    my $c     = $self->spacing;
    my $max_i = int( ($s-1) / $c );
    return [map { $_ * $c } 0..$max_i];
}

1;
