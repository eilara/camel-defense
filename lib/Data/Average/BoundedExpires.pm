# $Id: /mirror/perl/Data-Average/trunk/lib/Data/Average/BoundedExpires.pm 9150 2007-11-14T06:59:35.566402Z daisuke  $
#
# Copyright (c) 2006 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Data::Average::BoundedExpires;
use strict;
use base qw(Data::Average::Expires);

sub new
{
    my $class = shift;
    my %args  = @_;
    my $self  = $class->SUPER::new(%args);
    $self->{max}        = $args{max};

    return $self;
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
    if ($self->{max} <= $self->length) {
        shift @{$self->{data}};
    }
    $self->SUPER::add(@_);
}

1;

__END__

=head1 NAME

Data::Average::BoundedExpires - Bounded Data::Average With Expiry

=head1 SYNOPSIS

  use Data::Average::BoundedExpires;

  my $data = Data::Average::BoundedExpires->new(max => 10, expires_in => 120);

=head1 DESCRIPTION

Data::Average::Bounded is a mix of Data::Average::Bounded and
Data::Average::Expires.

=head1 METHODS

=head2 new(max => $max, expires_in => $expires_in)

Creates a new Data::Average::BoundedExpires object

=head2 add($value)

Behaves like a combination of Data::Average::Bounded and Data::Average::Expires.

=head2 length()

=head2 avg()

Same as Data::Average.

=head1 AUTHOR

Copyright (c) 2006 Daisuke Maki E<lt>dmaki@cpan.orgE<gt>
All rights reserved.

=cut
