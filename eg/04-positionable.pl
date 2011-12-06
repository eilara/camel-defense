#!/usr/bin/perl

package Games::CamelDefense::eg_Positionable;
use Games::CamelDefense::Demo;

has last_click => (is => 'rw', default => sub { [0, 0] });

consume qw(
    Render::Paintable
    Event::Handler::SDL
    Geometry::Positionable
);

sub on_mouse_button_up {
    my ($self, $x, $y) = @_;
    $self->xy([$x, $y]);
}

sub paint {
    my ($self, $surface) = @_;
    $surface->draw_circle($self->pos, 100, 0xFFFFFFFF, 1);
    $surface->draw_gfx_text(
        [@{ $self->xy - V(240, -120) }],
        0xFFFFFFFF,
        'A Paintable Positionable SDL Event Handler GOB: click to reposition',
    );
}

# ------------------------------------------------------------------------------

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title => 'Positionable';

my $paintable = Games::CamelDefense::eg_Positionable->new(xy => [320, 200]);

App->run;



