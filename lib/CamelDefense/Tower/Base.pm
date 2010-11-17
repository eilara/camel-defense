package CamelDefense::Tower::Base;

# the tower base class is a grid aligned sprite which can draw its range
# the cursor shadow and the tower object are tower base subclasses

use Moose;
use MooseX::Types::Moose qw(Num Str);
use aliased 'CamelDefense::Grid';

has grid => (is => 'ro', required => 1, isa => Grid);

has range =>
    (is => 'ro', required => 1, isa => Num, default => 100); # in pixels

with 'CamelDefense::Role::GridAlignedSprite';

sub init_image_def { die "Abstract method called" }

sub compute_cell_center { shift->grid->compute_cell_center(@_) }

1;

