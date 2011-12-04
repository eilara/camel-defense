package Games::CamelDefense::Geometry::Positionable;

use Games::CamelDefense::Role;

has _xy    => (is => 'ro', isa => Vector2D, required => 1, coerce => 1);
has offset => (is => 'ro', isa => Vector2D, required => 1, coerce => 1,
               default => sub { V(0, 0) });

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    $args{xy} = [$args{x}, $args{y}]
        if exists($args{x}) && exists($args{y});
    $args{_xy} = $args{xy};
    return $class->$orig(%args);
};

sub xy {
    my $self = shift;
    return $self->{_xy} unless @_;
    $self->{_xy}->set(shift);
}
 
sub x {
    my $self = shift;
    return $self->{_xy}->[0] unless @_;
    $self->{_xy}->[0] = shift;
}

sub y {
    my $self = shift;
    return $self->{_xy}->[1] unless @_;
    $self->{_xy}->[1] = shift;
}

sub pos {
    my $self = shift;
    my ($xy, $y, $ox, $oy) = (@{$self->{_xy}}, @{$self->{offset}});
    return [$xy + $ox, $y + $oy];
}

1;

=head1 NAME

Games::CamelDefense::Geometry::Positionable - role for positionable things


=head1 DESCRIPTION

  package MyGob;
  with 'Games::CamelDefense::Geometry::Positionable';
  1;
  ...
  $gob = MyGob->new(xy => [320, 200]);   # create a gob at 320,200
  $gob = MyGob->new(xy => V(320, 200));  # provide a Math::Vector::Real
  $gob = MyGob->new(x => 320, y => 200); # separate x and y
  $gob = MyGob->new(
      xy     => [320, 200],
      offset => [ 20,  50],              # offset only used when painting
                                         # by real_xy method
                                         # used to center sprites and things
  );
  $x         = $gob->x;
  $y         = $gob->y;
  $xy        = $gob->xy;                 # returns Math::Vector::Real
  $offset    = $gob->offset;             # returns Math::Vector::Real 
  $offset_xy = $gob->pos;                # returns 2D array ref 
                                         # returns where to paint this GOB, adds xy offset
                                         # for the gob above: {340, 250}

  $gob->x(640);
  $gob->y(480);
  $gob->xy([640, 480]);
  $gob->xy(V(640, 480));


=head1 DESCRIPTION

Wraps L<Math::Vector::Real>. 

A positionable has an optional offset.

=cut

