# $Id: /mirror/perl/Data-Average/trunk/lib/Data/Average/Bounded.pm 9150 2007-11-14T06:59:35.566402Z daisuke  $
#
# Copyright (c) 2006 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Data::Average::Bounded;
use strict;
use base qw(Data::Average);

sub new
{
    my $class = shift;
    my %args  = @_;
    my $self  = $class->SUPER::new(%args);
    $self->{max} = $args{max};

    return $self;
}

sub add
{
    my $self = shift;
    if ($self->{max} <= $self->length) {
        shift @{$self->{data}};
    }
    $self->SUPER::add(@_);
}

1;

__END__

=head1 NAME

Data::Average::Bounded - Data::Average With Bounded

=head1 SYNOPSIS

  use Data::Average::Bounded;

  my $data = Data::Average::Bounded->new(max => 10);
  $data->add($_) for (1..100);

  print $data->avg; # 95 (avg of 90 .. 100)

=head1 DESCRIPTION

Data::Average::Bounded is a bounded version of Data::Average, which keeps
the data size to a predefined size.

=head1 METHODS

=head2 new(max => $max)

Creates a new Data::Average::Bounded object, bounded by $max.

=head2 add($value)

Adds a value to the Data::Average::Bounded set. If the data size exceeds the 
length specified by 'max' given to the constructor, old elements are popped 
out of the set to keep the data size.

$value may either be an object that implements a method 'value()' which
returns a numerical representation of the object, or a simple scalar.

=head2 length()

=head2 avg()

Same as Data::Average.

=head1 AUTHOR

Copyright (c) 2006 Daisuke Maki E<lt>dmaki@cpan.orgE<gt>
All rights reserved.

=cut
