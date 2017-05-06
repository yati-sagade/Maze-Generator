#!/usr/bin/env perl
use strictures 2;
use feature qw(say);

use Maze::Generator;
use Maze::Generator::Drawing;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Module::Load;
use Carp;

$SIG{__DIE__} = \&Carp::confess;

my $generator = Maze::Generator->new;
MAIN: {
    my $settings = _get_settings();
    my $output = delete $settings->{output} || 'terminal';
    my $grid = $generator->generate(%$settings);
    if ($output eq 'terminal') {
        say $grid;
    } else {
        my $draw = Maze::Generator::Drawing->new(output_filename => $output);
        $draw->draw($grid);
    }
}

sub _get_settings {
    my %options;
    GetOptions(\%options,
        'algorithm|a=s',
        'size|s=s',
        'help|h',
        'list-algorithms|l',
        'output|o=s',
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
        output    => $options{output} // 'terminal',
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

    $ perl mz.pl
    ┌────────┐
    ├──────  ┤
    ├──────  ┤
    └────────┘

Generate a maze with a named algorithm:

    $ perl ./bin/mz.pl -a binary_tree
    ┌────────┐
    ├  ┬  ┬  ┤
    ├──┴  ┼  ┤
    └─────┴──┘

Generate a maze with a named algorithm and given size:

    $ perl ./bin/mz.pl -a sidewinder -s 5x5
    ┌──────────────┐
    ├  ┬  ┬  ───┬──┤
    ├  ┼  ┴──┬  ┼──┤
    ├──┴─────┴  ┴──┤
    ├  ┬───  ┬  ───┤
    └──┴─────┴─────┘

=head1 DESCRIPTION

This script uses C<Maze::Generator> to generate mazes, that are printed to the
standard output.

=head1 OPTIONS

=over

=item --algorithm NAME, -a NAME

Use the algorithm named by C<NAME>. To list all available algorithms, do

    perl mz.pl --list-algorithms

=item --size MxN, -s MxN

Size of the grid in rows and columns, in that order.

=item --help, -h

Show this help and quit.

=item --list-algorithms, -l

Show available maze drawing algorithms.

=item --output FILENAME, -o FILENAME

Instead of displaying the maze on the terminal, write it as an image to a file.
The type of the file is inferred from the extension.

=back

=cut

