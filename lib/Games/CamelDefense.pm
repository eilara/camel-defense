package Games::CamelDefense;

use Moose;
use Games::CamelDefense::MooseX::Util;

sub import {
    my ($class, %args) = @_;
    my $caller = caller;
    require feature;
    feature->import(':5.10');
#    strict->import;
#    warnings->import;
#
#    eval "package $caller;use Moose";
#    die "Importing Moose error: $@" if @$;
    
    import_helpers($caller);
}




1;

=head1 NAME

Games::CamelDefense - a simple Perl tower defense game


=cut

