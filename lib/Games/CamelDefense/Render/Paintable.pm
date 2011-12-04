package Games::CamelDefense::Render::Paintable;

use Games::CamelDefense::Role;

# set these two before creating any paintables
my $Layer_Manager;
sub Set_Layer_Manager { $Layer_Manager = shift }

requires 'paint';

has layer => ( # layer name
    is       => 'ro',
    isa      => Str,
    default  => 'background',
);

has is_visible => (
    is       => 'rw',
    isa      => Bool,
    default  => 1,
);

# should we call paint on this paintable or will someone else do it
has auto_paint => (
    is       => 'ro',
    isa      => Bool,
    default  => 1,
);

sub show { shift->is_visible(1) }
sub hide { shift->is_visible(0) }

sub sdl_paint {
    my ($self, $surface) = @_;
    return unless $self->{is_visible};
    $self->paint($surface);
}

# permonks stvn trick to get BUILD time action from roles
sub BUILD {}
before 'BUILD' => sub {
    my $self = shift;
    $Layer_Manager->add_paintable_to_layer($self->layer, $self)
        if $self->auto_paint;
};

1;

=head1 NAME

Games::CamelDefense::Render::Paintable - role for paintable game objects


=head1 SYNOPSIS

  package MyGob;
  use Moose;
  with  'Games::CamelDefense::Render::Paintable';
  sub paint {
      my ($self, $surface);
      $self->draw_circle([100, 100], 200, 0xFFFFFFFF);
  }
  $gob = MyGob->new(
      is_visible => 1,          # visible=1 by default
      auto_paint => 1,          # auto_paint=1 by default
      layer      => 'my_layer', # layer name to paint on
  );
  $gob->is_visible(1);
  $layer->add_paintable($paintable);
  $layer->paint($surface);
  

=head1 DESCRIPTION

Consumers must implement C<paint($surface)>, where you can draw things on 
the surface. Paint should not change game state. Every paintable you will
created will automatically be painted every frame, unless you set C<auto_paint>
to false.

Set C<auto_paint> to false (default is true), if you want to call C<paint>
on your GOB yourself, in a background image role for example.

Set C<is_visible> to set if the paintable will be painted.

=head1 REQUIRES

C<paint($surface)>

=cut


