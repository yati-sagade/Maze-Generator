#!/usr/bin/env perl
use strictures 2;
use feature qw(say);

use Maze::Generator::Grid;
use Maze::Generator::Algorithm;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Module::Load;

my @algorithms = qw/
    Maze::Generator::Algorithm::BinaryTree
/;

my %name_to_algorithm;
for my $module (@algorithms) {
    load $module;
    $name_to_algorithm{$module->name} = $module;
}

MAIN: {
    my $settings = _get_settings();
    my $algo = $settings->{algorithm}->new;
    my $grid = Maze::Generator::Grid->new(
        rows => $settings->{rows}, cols => $settings->{cols});
    $algo->generate($grid);
    say $grid;
}

sub _get_settings {
    my %options;
    GetOptions(\%options,
        'algorithm|a=s',
        'size|s=s',
        'help|h',
        'list-algorithms|l',
    ) or pod2usage();

    pod2usage()              if $options{help};
    _print_available_algos() if $options{'list-algorithms'};

    my $algo_name = $options{algorithm} // 'binary_tree';
    my $algo_module = $name_to_algorithm{$algo_name} // do {
        local $" = ',';
        die "Invalid algorithm name $algo_name, must be one of @{[keys %name_to_algorithm]}.";
    };

    my $size_str = $options{size} // "3x3";
    my ($rows, $cols) = _parse_size_str($size_str);
    return {
        algorithm => $algo_module,
        rows      => $rows,
        cols      => $cols,
    };
}

sub _parse_size_str {
    my $size = shift;
    die "Invalid size specification $size, must be like 'MxN'."
        unless $size =~ /^(\d+)x(\d+)$/;
    my ($rows, $cols) = ($1, $2);
    return ($rows, $cols);
}

sub _print_available_algos {
    say "These are the available algorithms:";
    for my $name (sort keys %name_to_algorithm) {
        my $mod = $name_to_algorithm{$name};
        say "$name\n\t" . $mod->description;
    }
    exit 0;
}

__END__

=pod

=head1 NAME

mz.pl

=head1 SYNOPSIS

    perl mz.pl [OPTIONS]

Generate a maze with the default algorithm:

    perl mz.pl

Generate a maze with a named algorithm:

    perl mz.pl --algorithm=binary_tree

Generate a maze with a named algorithm and given size:

    perl mz.pl --algorithm=binary_tree --size=7x6

=head1 DESCRIPTION

This script uses C<Maze::Generator> to generate mazes, that are printed to the
standard output.

=head1 OPTIONS

=over

=item --algorithm NAME, -a NAME

Use the algorithm named by C<NAME>. To list all available algorithms, do

    perl mz.pl --list-algorithms

=cut

