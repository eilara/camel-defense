package Games::CamelDefense::Behavior::Cursor;

use Games::CamelDefense::Role;

consume qw(
    Geometry::Positionable
    Event::Handler::SDL
);

sub on_mouse_motion { shift->xy([@_]) }

sub on_app_mouse_focus { shift->is_visible(pop) }

1;


=head1 NAME

Games::CamelDefense::Behvaior::Cursor - position follows mouse


=head1 DESCRIPTION

A positionable that sets its position on mouse motion, and hides when app loses
focus.


=head1 DOES

L<Games::CamelDefense::Geometry::Positionable>, L<Games::CamelDefense::Event::Handler::SDL>

=cut


