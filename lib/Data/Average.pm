# $Id: /mirror/perl/Data-Average/trunk/lib/Data/Average.pm 9158 2007-11-14T07:11:39.898727Z daisuke  $
#
# Copyright (c) 2006 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Data::Average;
use strict;
use UNIVERSAL::isa;
use vars qw($VERSION);

BEGIN
{
    $VERSION = '0.03000';
}

sub new
{
    my $class = shift;
    my $self  = bless {
        data => []
    }, $class;
    return $self;
}

sub avg
{
    my $self   = shift;
    my $total  = 0;
    my $length = $self->length;

    return () if $length <= 0;
    my @data = @{ $self->{data} };
    foreach my $v (@data) {
        if (ref($v) && $v->can('value')) {
            $total += $v->value;
        } else {
            $total += $v;
        }
    }

    return $total / $length;
}

sub length { scalar(@{$_[0]->{data}}) }
sub add    { 
    my $self = shift;
    $self->{data}->[ $self->length ] = $_ for @_;
    1;
}

1;

__END__

=head1 NAME

Data::Average - Hold Data Set To Calculate Average

=head1 SYNOPSIS

  use Data::Average;

  my $data = Data::Average->new;
  $data->add($_) for (1..100);

  print $data->avg; # 55

=head1 DESCRIPTION

Data::Average is a very simple module: You add values to it, and then you
compute the average using the avg() function.

=head1 METHODS

=head2 new()

Creates a new Data::Average object

=head2 add($value)

Adds a value to the Data::Average set.

=head2 length()

Returns the current data set

=head2 avg()

Returns the average of the entire set

=head1 AUTHOR

Copyright (c) 2006-2007 Daisuke Maki E<lt>daisuke@endeworks.jp<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut