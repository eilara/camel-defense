package Games::CamelDefense::Event::Handler::Rectangular;

use Moose::Role;

with 'Games::CamelDefense::Event::Handler';

sub on_mouse_enter {}
sub on_mouse_leave {}

1;

=head1 NAME

Games::CamelDefense::Event::Handler::Rectangular - role for rectangular SDL event handlers


=head1 SYNOPSIS

  package MyGob;
  use Moose;
  with  'Games::CamelDefense::Event::Handler::Rectangular';
  sub on_mouse_enter { ... }
  sub on_mouse_leave { ... }



=head1 DESCRIPTION

Adds 2 event handling methods unique to rectangular event handlers:
mouse_enter/leave.


=head1 DOES

L<Games::CamelDefense::Event::Handler>


=cut
