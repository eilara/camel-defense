package Games::CamelDefense::MooseX::Compose;

use Moose;
use Moose::Exporter;
use Moose::Util qw(apply_all_roles);
use aliased 'MooseX::Role::BuildInstanceOf';

Moose::Exporter->setup_import_methods(
    with_meta => ['compose_from'],
);

sub _compute_prefix($) {
    my $target = shift;    
    $target =~ /([^:]+)$/;
    return lc $1;
}

# syntax sugar over MooseX::Role::BuildInstanceOf:
# 1) exports keyword instead of verbose "with 'MooseX::Role::Bui..."
# 2) adds inject feature which saves you (often) from writing the
#    around sub on merge args
sub compose_from {
    my ($meta, $target, %args) = @_;
    my $prefix = delete($args{prefix}) || _compute_prefix $target;
    my $inject = delete $args{inject};
    my $has    = delete $args{has};

    my $build_args = {target => $target, prefix => $prefix, %args};
    apply_all_roles($meta, BuildInstanceOf, $build_args);

    if ($inject) {
        if (my $ref = ref $inject) {

            if ($ref eq 'CODE') {
                $meta->add_around_method_modifier("merge_${prefix}_args", sub {
                    my ($orig, $self) = @_;
                    return ($self->$orig, $inject->($self));
                });

            } elsif ($ref eq 'ARRAY') {
                $meta->add_around_method_modifier("merge_${prefix}_args", sub {
                    my ($orig, $self) = @_;
                    return ($self->$orig, map { $_ => $self->$_ } @$inject);
                });

            } elsif ($ref eq 'HASH') {
                $meta->add_around_method_modifier("merge_${prefix}_args", sub {
                    my ($orig, $self) = @_;
                    return ($self->$orig, map {
                        my ($key, $method) = ($_, $inject->{$_});
                        ($key => $self->$method);
                    } keys %$inject);
                });

            } else {
                die 'inject can only take list of methods or code';
            }

        } else {
            die 'inject can only take list of methods or code';
        }
    }

    if ($has) {
        $meta->add_attribute("+$prefix", %$has);
    }
}

1;
