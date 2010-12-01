package CamelDefense::StateMachine;

use Moose;
use MooseX::Types::Moose qw(HashRef);

has cursor        => (is => 'ro', required   => 1);
has states        => (is => 'ro', required   => 1, isa => HashRef[HashRef]);
has current_state => (is => 'rw', lazy_build => 1, isa => HashRef);

sub _build_current_state {
    my $self = shift;
    return $self->states->{init};
}

sub handle_event {
    my ($self, $event_name, @args) = @_;
    my $state = $self->current_state;
    my $events = $state->{events};
    return unless $events; # do nothing, no events for state

    my $event = $events->{$event_name};
    return unless $event; # do nothing, event not defined

    my $next_state_name = $event->{next_state};
    $next_state_name = $next_state_name->(@args) if ref $next_state_name eq 'CODE';
    my $states = $self->states;

    if ($next_state_name) {
        my $next_state = $states->{ $next_state_name };
        $self->current_state($next_state);
    }
    
    my $code = $event->{code};
    $code->(@args) if $code;

    # update cursor AFTER running code, because running
    # code could have changed its state
    if ($next_state_name) {
        my $next_state = $states->{ $next_state_name };
        my $cursor = $next_state->{cursor};
        if ($cursor) {
            $cursor = $cursor->(@args) if ref $cursor eq 'CODE';
            $self->cursor->change_to($cursor);
        }
    }
    
}

1;

