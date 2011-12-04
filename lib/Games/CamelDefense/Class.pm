package Games::CamelDefense::Class;

use Moose;
use Games::CamelDefense::MooseX::Util;

sub import {
    my ($class, %args) = @_;
    my $caller = caller;
    require feature;
    feature->import(':5.10');
    strict->import;
    warnings->import;

    eval <<"IMPORTS";

package $caller;
use Moose;

IMPORTS

    die "Importing Moose error: $@" if @$;
   
    import_helpers($caller);
}




1;

=head1 NAME

Games::CamelDefense::Role - a camel defense role


=head1 DESCRIPTION

Consume when coding a game object role. A thin sugary wrapper around Moose::Role.


=cut

