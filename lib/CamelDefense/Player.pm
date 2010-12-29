package CamelDefense::Player;

use Moose;
use MooseX::Types::Moose qw(Bool Num);

has hp       => (is => 'rw', required => 1, isa => Num , default => 100);
has gold     => (is => 'rw', required => 1, isa => Num , default => 100);
has is_alive => (is => 'rw', required => 1, isa => Bool, default => 1);

has start_hp => (is => 'rw', isa => Num);

with 'MooseX::Role::Listenable' => {event => 'player_hp_changed'};
with 'MooseX::Role::Listenable' => {event => 'player_gold_changed'};

sub BUILD {
    my $self = shift;
    $self->start_hp($self->hp);
}

sub hit {
    my ($self, $damage) = @_;
    my $hp = $self->hp - $damage;
    $hp = 0 if $hp < 0;
    $self->hp($hp);
    $self->player_hp_changed;
}

sub gain_gold {
    my ($self, $gold) = @_;
    $self->gold( $self->gold + $gold );
    $self->player_gold_changed;
}

sub spend_gold {
    my ($self, $gold) = @_;
    my $new_gold = $self->gold - $gold;
    $new_gold = 0 if $new_gold < 0;
    $self->gold($new_gold);
    $self->player_gold_changed;
}

sub hp_ratio {
    my $self = shift;
    return $self->hp / $self->start_hp;
}

sub player_hp   { shift->hp }
sub player_gold { shift->gold }

1;

