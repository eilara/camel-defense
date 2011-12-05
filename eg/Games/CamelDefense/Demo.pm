package Games::CamelDefense::Demo;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Moose;
use Moose::Util;
use Games::CamelDefense::MooseX::Util;

sub import {
    my ($class, @args) = @_;
    my $caller = caller;
    require feature;
    feature->import(':5.10');
    strict->import;
    warnings->import;

    eval "package $caller;use Moose";
    die "Importing Moose error: $@" if @$;
    
    import_helpers($caller, @args);
}

1;

=head1 NAME

Games::CamelDefense::Demo - helper for demo scripts


=head1 DESCRIPTION

  use Games::CamelDefense::Demo;


=head1 DESCRIPTION

Use in demo scripts to get the demos running from the dist dir.


=cut

