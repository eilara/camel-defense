package Games::CamelDefense::MooseX::Util;

use Moose;
use Moose::Util;
use MooseX::Role::Listenable;

sub import {
    my $class = shift;
    my $caller = caller;
    {   no strict 'refs';
        *{"${caller}::import_helpers"} = \&import_helpers;
    }
}

sub has_event { 
    Moose::Util::apply_all_roles
        (scalar caller, 'MooseX::Role::Listenable', {event => shift});
}

sub consume { 
    Moose::Util::apply_all_roles
        (scalar caller, map { "Games::CamelDefense::$_" } @_);
}

sub import_helpers {
    my ($caller, @args) = @_;
    eval <<"IMPORTS";

package $caller;
use Scalar::Util qw(weaken);
use Math::Vector::Real;
use MooseX::Types::Moose qw(Bool Int Num Str ArrayRef HashRef);
use Games::CamelDefense::MooseX::Compose;
use Games::CamelDefense::MooseX::Types qw(Vector2D);
${\( join qq{\n}, map {qq{
use aliased 'Games::CamelDefense::$_';
}} @args )}

IMPORTS
    die "Importing Moose error: $@" if @$;
   
    {   no strict 'refs';
        *{"${caller}::consume"}   = \&consume;
        *{"${caller}::has_event"} = \&has_event;
    }
}

1;
