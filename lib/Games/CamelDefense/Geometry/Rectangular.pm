package Games::CamelDefense::Geometry::Rectangular;

use Moose::Role;
use MooseX::Types::Moose qw(Bool);
use Games::CamelDefense::Types qw(Vector2D);

has size     => (is => 'ro', isa => Vector2D, required => 1, coerce => 1);
has centered => (is => 'ro', isa => Bool    , default  => 0);

# TBD: should centered be default?

with 'Games::CamelDefense::Geometry::Positionable';

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    $args{size} = [$args{w}, $args{h}]
        if exists($args{w}) && exists($args{h});
    if (my $rect = delete $args{rect}) {
        $args{xy}   = [ @$rect[0,1] ];
        $args{size} = [ @$rect[2,3] ];
    }
    if ($args{centered}) {
        my $offset = $args{offset} || [0, 0];
        my $size   = $args{size}   || die 'No "size" given';
        $args{offset} = [$offset->[0] - int($size->[0]/2),
                         $offset->[1] - int($size->[1]/2)];
    }
    return $class->$orig(%args);
};

sub w { shift->size->[0] }
sub h { shift->size->[1] }

1;

=head1 NAME

Games::CamelDefense::Geometry::Rectangular - role for rectangular things


=head1 DESCRIPTION

  package MyGob;
  with 'Games::CamelDefense::Geometry::Rectangular';
  1;
  ...
  $gob = MyGob->new(rect => [320, 200, 20, 40]);         # xy=320,200, size=20,40
  $gob = MyGob->new(xy => [320, 200], size => [20, 40]); # same
  $gob = MyGob->new(xy => [320, 200], w => 20, h => 40); # same
  $gob = MyGob->new(                                     # same but centered
      rect     => [320, 200, 20, 40],
      centered => 1,
  );
  $w           = $gob->h;
  $h           = $gob->w;
  $size        = $gob->size;               # returns Math::Vector::Real
  $is_centered = $gob->centered;           # returns bool


=head1 DESCRIPTION

A positionable with width and height. If centered, then positionable offset is
set so that C<pos()> will return the object centered.


=head1 DOES

L<Games::CamelDefense::Geometry::Positionable>


=cut

