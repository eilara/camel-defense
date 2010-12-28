package CamelDefense::Player;

use Moose;
use MooseX::Types::Moose qw(Bool Num);

has hp       => (is => 'rw', required => 1, isa => Num , default => 100);
has gold     => (is => 'rw', required => 1, isa => Num , default => 40);
has is_alive => (is => 'rw', required => 1, isa => Bool, default => 1);

has start_hp => (is => 'rw', isa => Num);

sub BUILD {
    my $self = shift;
    $self->start_hp($self->hp);
}

sub hit {
    my ($self, $damage) = @_;
    my $hp = $self->hp - $damage;
    $hp = 0 if $hp < 0;
    $self->hp($hp);
    unless ($hp > 0) {
    }
}

sub gain_gold {
    my ($self, $gold) = @_;
    $self->gold( $self->gold + $gold );
    print "gained: $gold\n";
}

sub hp_ratio {
    my $self = shift;
    return $self->hp / $self->start_hp;
}

1;

