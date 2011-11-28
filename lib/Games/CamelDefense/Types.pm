package Games::CamelDefense::Types;

use strict;
use warnings;
use Math::Vector::Real;
use MooseX::Types -declare => [qw(
    Vector2D
)];
use MooseX::Types::Moose qw(ArrayRef);

subtype Vector2D, as 'Math::Vector::Real';

coerce Vector2D, from ArrayRef, via { V(@$_) };

1;
