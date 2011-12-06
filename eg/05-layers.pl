#!/usr/bin/perl

package Games::CamelDefense::eg_Layers;
use Games::CamelDefense::Demo;

consume qw(
    Render::Paintable
    Geometry::Positionable
);

has color => (is => 'ro');

sub paint {
    my ($self, $surface) = @_;
    $surface->draw_circle_filled($self->pos, 100, $self->color, 1);
    $surface->draw_circle($self->pos, 100, $self->color, 1);
}

# ------------------------------------------------------------------------------

package Games::CamelDefense::eg_LayersEventHandler;
use Games::CamelDefense::Demo;

consume 'Event::Handler::SDL';

has circles => (is => 'ro', default => sub { [] });

my $counter;
sub on_mouse_button_up {
    my ($self, @pos) = @_;
    my $rand = ($counter++%3);#int rand 3;
    push @{ $self->circles }, Games::CamelDefense::eg_Layers->new(
        xy    => \@pos,
        color => [0xFF0000EF, 0x00FF00EF, 0x0000FFEF]->[$rand],
        layer => [qw(red green blue)]->[$rand],
    );
}

# ------------------------------------------------------------------------------

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title  => 'Layers',
                             layers => [qw(red green blue)];

my $event_handler = Games::CamelDefense::eg_LayersEventHandler->new;

App->run;

