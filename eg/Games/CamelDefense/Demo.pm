package Games::CamelDefense::Demo;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use strict;
use warnings;

sub import {
    my $class   = shift;

      strict->import;
    warnings->import;

    require feature;
    feature->import(':5.10');
}

1;

=head1 NAME

Games::CamelDefense::Demo - helper for demo scripts


=head1 DESCRIPTION

  use Games::CamelDefense::Demo;


=head1 DESCRIPTION

Use in demo scripts to get the demos running from the dist dir.


=cut

