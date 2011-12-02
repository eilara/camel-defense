package Games::CamelDefense::Render::LayerManager;

use Moose;
use MooseX::Types::Moose qw(Str ArrayRef HashRef);
use aliased 'Games::CamelDefense::Render::Layer';

# layer names in order from front to back
has layers => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[Str],
    default  => sub { [] },
);

# map of layer name -> layer
has layer_map => (
    is         => 'ro',
    lazy_build => 1,
    isa        => HashRef[Layer],
);

sub _build_layer_map {
    my $self = shift;
    return {map { $_ => Layer->new } @{ $self->layers }};
}

sub BUILD {
    my $self = shift;
    unshift @{ $self->layers }, 'background'; # auto add background layer
}

# called by paintables to register themselves for painting in
# the correct layer
sub add_paintable_to_layer {
    my ($self, $layer, $paintable) = @_;
    $self->layer_map->{$layer}->add_paintable($paintable);
}

sub paint {
    my ($self, $surface) = @_;
    my $layers = $self->layer_map;
    my $names  = $self->layers;
    $layers->{$_}->paint($surface) for @$names;
}

1;

=head1 NAME

Games::CamelDefense::Render::LayerManager - an ordered list of paintable layers


=head1 SYNOPSIS

  $layer = Games::CamelDefense::Render::LayerManager->new(
      layers => [qw(bottom_layer my_layer top_layer)],
  );
  $layer->add_paintable_to_layer('my_layer', $paintable);
  $layer->paint($surface);
  

=head1 DESCRIPTION

Default layer is called 'background', and is always added in the bottom of the list.
Keeps a list of L<Games::CamelDefense::Render::LayerManager>. Create with a list of
layer names. Then you create paintables with the correct C<layer> attribute, and
the paintable will be painted in that layer.


=cut


