#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use Test::More;
use aliased 'CamelDefense::Grid::Markers';

test_marks(
    [3,  8,  9, [0,3,6  ], [0,3,6    ]],
    [3, 10, 11, [0,3,6,9], [0,3,6,9  ]],
    [5, 10, 20, [0,5    ], [0,5,10,15]],
);

{
    my $iut = Markers->new(w => 10, h => 20, spacing => 3);
    is_deeply
        $iut->compute_cell_center_from_ratio(0.0,0.5),
        [1.5, 10.5],
        'cell center';
}

done_testing();

sub test_marks {
    my (@tests) = @_;
    my $i;
    test_mark(++$i, @$_) for @tests;
}

sub test_mark {
    my ($i, $spacing, $w, $h, $expected_cols, $expected_rows) = @_;
    my $iut = Markers->new(
        w        => $w,
        h        => $h,
        spacing  => $spacing,
    );
    is_deeply $iut->col_marks, $expected_cols, "col marks $i";
    is_deeply $iut->row_marks, $expected_rows, "row marks $i";
}

