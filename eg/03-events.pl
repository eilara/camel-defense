#!/usr/bin/perl

package Games::CamelDefense::eg_Events;
use Games::CamelDefense::Demo;

has last_click => (is => 'rw', default => sub { [0, 0] });

consume qw(
    Render::Paintable
    Event::Handler::SDL
);

sub on_mouse_button_up {
    my ($self, $x, $y) = @_;
    $self->last_click([$x, $y]);
}

sub paint {
    my ($self, $surface) = @_;
    my $text = join ',', @{ $self->last_click };
    $surface->draw_gfx_text([100, 100], 0xFFFFFFFF, $text);
}

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title => 'Events';

my $paintable = Games::CamelDefense::eg_Events->new;

App->run;
