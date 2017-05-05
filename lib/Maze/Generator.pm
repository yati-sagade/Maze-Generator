package Maze::Generator;
use strictures 2;
use Module::Load;
use Moo;
use Scalar::Util qw(blessed);

use Maze::Generator::Grid;

has algorithm_name_to_module_map => (
    is      => 'ro',
    default => sub {
        my @algorithms = qw/
            Maze::Generator::Algorithm::BinaryTree
            Maze::Generator::Algorithm::Sidewinder
        /;
        my %name_to_algorithm;
        for my $module (@algorithms) {
            load $module;
            $name_to_algorithm{$module->name} = $module;
        }
        return \%name_to_algorithm;
    }
);

sub algorithms {
    my $self = shift;
    return [sort { $a->name cmp $b->name }
                values %{$self->algorithm_name_to_module_map}];
}

sub generate {
    my ($self, %args) = @_;
    die "Maze::Generator->generate() is supposed to be called as an instance method."
        unless blessed $self;
    my $rows = delete $args{rows}      or die "missing number of rows";
    my $cols = delete $args{cols}      or die "missing number of cols";
    my $algo = delete $args{algorithm} or die "missing algorithm name";
    my $algo_opts = delete $args{algorithm_options} || {};

    if (%args) {
        local $" = ',';
        die "Don't know what to do with these args: @{[keys %args]}.";
    }

    my $algo_mod = $self->algorithm_name_to_module_map->{$algo} //
        die "Unknown algorithm $algo.";

    my $grid = Maze::Generator::Grid->new(rows => $rows, cols => $cols);
    $algo_mod->new(options => $algo_opts)->generate($grid);
    return $grid;
}


1;
