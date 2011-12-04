package Games::CamelDefense::MooseX::Util;

use Moose;
use Moose::Util;

sub import {
    my $class = shift;
    my $caller = caller;
    {   no strict 'refs';
        *{"${caller}::import_helpers"} = \&import_helpers;
    }
}

sub consume { 
    Moose::Util::apply_all_roles
        (scalar caller, map { "Games::CamelDefense::$_" } @_);
}

sub import_helpers {
    my ($caller) = @_;
    eval <<"IMPORTS";

package $caller;
use MooseX::Types::Moose qw(Bool Int Num Str ArrayRef HashRef);
use Scalar::Util qw(weaken);
use Games::CamelDefense::MooseX::Compose;
use Games::CamelDefense::MooseX::Types qw(Vector2D);

IMPORTS
    die "Importing Moose error: $@" if @$;
   
    {   no strict 'refs';
        *{"${caller}::consume"} = \&consume;
    }
}

1;
