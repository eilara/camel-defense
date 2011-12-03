#!/usr/bin/perl

package Games::CamelDefense::eg::Events;
use Games::CamelDefense::Demo;

last_click => (is => 'rw', default => sub { [0, 0] });


with qw(
    Games::CamelDefense::Render::Paintable
    Games::CamelDefense::Event::Handler::SDL
);

sub on_mouse_button_up {
    my ($self, $x, $y) = @_;
    $self->last_click([$x, $y]);
}

sub paint {
    my $self = shift;
    $self->draw_rect(undef, 0x000000FF); # undef means color entire surface
    my $text = join ',', @{ $self->last_click };
    $self->draw_gfx_text([100, 100], 0xFFFFFFFF, $text);
}

sub paint {
    shift->draw_gfx_text([100, 100], 0xFFFFFFFF, 'I can be painted');
}

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title => 'Paintable';

App->run;
