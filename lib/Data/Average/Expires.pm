# $Id: /mirror/perl/Data-Average/trunk/lib/Data/Average/Expires.pm 9157 2007-11-14T07:11:14.821380Z daisuke  $
#
# Copyright (c) 2006 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Data::Average::Expires;
use strict;
use base qw(Data::Average);

sub new
{
    my $class = shift;
    my %args  = @_;
    my $self  = $class->SUPER::new(%args);
    $self->{expires_in} = $args{expires_in};

    return $self;
}

sub expire_items
{
    my $self   = shift;
    my $length = $self->SUPER::length;
    my $i      = 0;
    while ($i < $length) {
        if ($self->{data}->[$i]->expired) {
            splice(@{$self->{data}}, $i, 1);
            $length--;
        } else {
            $i++;
        }
    }
}

sub length
{
    my $self = shift;
    $self->expire_items();
    $self->SUPER::length(@_);
}

sub avg
{
    my $self = shift;
    $self->expire_items();
    $self->SUPER::avg(@_);
}

sub add
{
    my $self = shift;
    $self->expire_items;

    my @args;
    for (@_) {
        if (!ref($_) || ! $_->isa('Data::Average::Expires::Item')) {
            push @args, Data::Average::Expires::Item->new(expires_in => $self->{expires_in}, value => $_);
        }
    }
    $self->SUPER::add(@args);
}

package Data::Average::Expires::Item;
use strict;

sub new
{
    my $class = shift;
    my %args  = @_;
    my $self  = bless {
        expires_in => $args{expires_in},
        value      => $args{value},
        created_on => time()
    }, $class;
    return $self;
}

sub expires_in { $_[0]->{expires_in} }
sub value      { $_[0]->{value} }
sub created_on { $_[0]->{created_on} }
sub expired { $_[0]->{created_on} + $_[0]->{expires_in} < time() }

1;

__END__

=head1 NAME

Data::Average::Expires - Hold Data Set To Calculate Average

=head1 SYNOPSIS

  use Data::Average::Expires;

  my $data = Data::Average::Expires->new(expires_in => 10);
  $data->add($_) for (1..100);

  print $data->avg; # 55

  # sleep for more than 10 seconds...
  sleep(15);
  print $data->length; # 0

  $data->add(Data::Average::Expires::Item->new(expires_in => 60, value => 200));

=head1 DESCRIPTION

Data::Average::Expires only takes into account values that haven't expired:
for example, you can track the average value of something for the last 
10 minutes using this module.

=head1 METHODS

=head2 new(expires_in => $expires_in)

Creates a new Data::Average object, with default expire time set to the
value denoted by $expires_in

=head2 expire_items

Expires items.

=head2 add($value)

Adds a value to the Data::Average::Expires set. 

$value may be a scalar or a Data::Average::Expires::Item object. Items
are always checked for expiry before each operation.

=head2 length()

=head2 avg()

Same as Data::Average.

=head1 AUTHOR

Copyright (c) 2006 Daisuke Maki E<lt>dmaki@cpan.orgE<gt>
All rights reserved.

=cut
