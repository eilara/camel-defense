package Games::CamelDefense::Render::Layer;

use Games::CamelDefense::Class;

has children => (is => 'rw', default => sub { [] });

sub add_paintable {
    my ($self, $paintable) = @_;
    my $children = $self->children;
    unshift @$children, $paintable;
    weaken $children->[0];
}

sub paint {
    my ($self, $surface) = @_;
    my $children = $self->children;
    my $are_dead;
    # we need to clean dead weak refs
    for my $child (@$children) {
        if ($child)        { $child->sdl_paint($surface) }
        elsif (!$are_dead) { $are_dead = 1 }
    }
    if ($are_dead) {
        my $new_children = [grep { defined $_ } @$children];
        weaken($new_children->[$_]) for 1..scalar(@$new_children);
    }
}

1;

=head1 NAME

Games::CamelDefense::Render::Layer - a layer of paintables


=head1 SYNOPSIS

  $layer = Games::CamelDefense::Render::Layer->new;
  $layer->add_paintable($paintable);
  $layer->paint($surface);
  

=head1 DESCRIPTION

A layer keeps a list of weak refs to its paintables, and paints them all
in order on C<paint()>.

=cut


