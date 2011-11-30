package Games::CamelDefense::Event::Router;

use Moose::Role;

requires 'find_child_at';

has active_mouse_sink => (is => 'rw');

with 'Games::CamelDefense::Event::Handler::Rectangular';

# child events handled before parent events

for my $event (qw(mouse_button_up mouse_button_down)) {
    my $method = "on_$event";
    before $method => sub {
        my ($self, @mouse_xy) = @_;
        my $child = $self->_find_listening_child_at(@mouse_xy);
        return unless $child;
        $child->$method(@mouse_xy);
    };
}

# mouse motion handled differently for benefit of mouse enter/leave
before on_mouse_motion => sub {
    my ($self, @mouse_xy) = @_;
    my $child = $self->_find_listening_child_at(@mouse_xy);

    # motion on an area with no children in it should still trigger mouse leave
    unless ($child) {
        $self->_child_mouse_leave;
        return;
    }

    my $active = $self->active_mouse_sink;
    if (!$active || ($active != $child)) {
        $active->on_mouse_leave if $active;
        $self->active_mouse_sink($child);
        $child->on_mouse_enter;
    }
    
    $child->on_mouse_motion(@mouse_xy);
};

before on_mouse_leave => sub { shift->_child_mouse_leave };

before on_app_mouse_focus => sub {
    my ($self, $is_focus) = @_;
    return if $is_focus;
    $self->_child_mouse_leave;
};

sub _child_mouse_leave {
    my $self = shift;
    my $active = $self->active_mouse_sink;
    return unless $active;
    $active->on_mouse_leave;
    $self->active_mouse_sink(undef);
}

sub _find_listening_child_at {
    my ($self, @xy) = @_;
    my $child = $self->find_child_at(@xy);
    return $child
        && $child->does('Games::CamelDefense::Event::Handler::Rectangular')
             ? $child
             : undef;
}

1;

=head1 NAME

Games::CamelDefense::Event::Router - route events to children


=head1 SYNOPSIS

  package MyGob;
  use Moose;
  with  'Games::CamelDefense::Event::Router';
  sub find_child_at {
      my ($self, $x, $y) = @_;
      ...
      retrun $child;
  }


=head1 DESCRIPTION


Visual containers (e.g. panels) can consume this, and implement C<find_child_at>,
which must return the L<Games::CamelDefense::Event::Handler::Rectangular> at the
provided xy position, or undef.

The container will then route any events it receives to the correct child, and
compute mouse_enter/leave events for the child.


=head1 DOES

L<Games::CamelDefense::Event::Handler::Rectangular>


=head1 REQUIRES

C<find_child_at>


=cut
