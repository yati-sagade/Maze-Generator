#!/usr/bin/env perl
use strictures 2;
use feature qw(say);

use Maze::Generator;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Module::Load;
use Carp;

$SIG{__DIE__} = \&Carp::confess;

my $generator = Maze::Generator->new;
MAIN: {
    my $settings = _get_settings();
    my $grid = $generator->generate(%$settings);
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

    pod2usage()              if $options{help} || @ARGV;
    _print_available_algos() if $options{'list-algorithms'};

    my $algo_name = $options{algorithm} // 'binary_tree';
    my $size_str = $options{size} // "3x3";
    my ($rows, $cols) = _parse_size_str($size_str);
    return {
        algorithm => $algo_name,
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
    for my $module (@{$generator->algorithms}) {
        printf "%s\n\t%s\n", $module->name, $module->description;
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

