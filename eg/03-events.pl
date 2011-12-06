#!/usr/bin/perl

package Games::CamelDefense::eg_Events;
use Games::CamelDefense::Demo;

has last_click => (is => 'rw', isa => Vector2D, default => sub { V(0,0) });
has is_init    => (is => 'rw', isa => Bool    , default => 0);

consume qw(
    Render::Paintable
    Event::Handler::SDL
);

sub on_mouse_button_up {
    my ($self, @pos) = @_;
    $self->is_init(1);
    $self->last_click( V(@pos) );
}

sub paint {
    my ($self, $surface) = @_;
    my $text = $self->is_init?
        'mouse click at: '. $self->last_click:
        'click mouse to init Paintable SDL Event Handler GOB';
    $surface->draw_gfx_text([100, 100], 0xFFFFFFFF, $text);
}

# ------------------------------------------------------------------------------

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title => 'Events';

my $paintable = Games::CamelDefense::eg_Events->new;

App->run;
