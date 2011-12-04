package Games::CamelDefense::Event::Handler;

use Games::CamelDefense::Role;

sub on_mouse_motion            {}
sub on_mouse_button_up         {}
sub on_mouse_button_down       {}
sub on_left_mouse_button_up    {}
sub on_left_mouse_button_down  {}
sub on_right_mouse_button_up   {}
sub on_right_mouse_button_down {}
sub on_app_mouse_focus         {}

1;

=head1 NAME

Games::CamelDefense::Event::Handler - role for SDL event handlers


=head1 SYNOPSIS

  package MyGob;
  use Moose;
  with  'Games::CamelDefense::Event::Handler';
  sub on_mouse_motion            { ... }
  sub on_mouse_button_up         { ... }
  sub on_mouse_button_down       { ... }
  sub on_left_mouse_button_up    { ... }
  sub on_left_mouse_button_down  { ... }
  sub on_right_mouse_button_up   { ... }
  sub on_right_mouse_button_down { ... }
  sub on_app_mouse_focus         { ... }



=head1 DESCRIPTION

You can override all or any of the event handling methods.  You will only get
events if you consume L<Games::CamelDefense::Event::Handler::SDL>, or if you
place the event handler inside a container which routes events to its children,
e.g. L<Games::CamelDefense::UI::Panel::Box>.


=cut
