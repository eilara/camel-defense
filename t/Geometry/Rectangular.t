
package Games::CamelDefense::t_Geometry_Rectangular;
use Moose;

with 'Games::CamelDefense::Geometry::Rectangular';

package main;
use strict;
use warnings;
use Test::More;

ok 1;

my $gob = Games::CamelDefense::t_Geometry_Rectangular->new(
    rect     => [320, 200, 20, 100],
    centered => 1,
);

is $gob->pos->[0], 310, 'centered pos';

done_testing;


