
package Games::CamelDefense::t_Geometry_Positionable;
use Games::CamelDefense::Class;

consume 'Geometry::Positionable';

package main;
use strict;
use warnings;
use Test::More;

ok 1;

my $gob = Games::CamelDefense::t_Geometry_Positionable->new(
    xy     => [320, 200],
    offset => [-20,  50],
);

is $gob->pos->[0], 300, 'pos';

done_testing;


