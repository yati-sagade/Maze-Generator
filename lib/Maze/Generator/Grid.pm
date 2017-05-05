package Maze::Generator::Grid;
use utf8;
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
binmode STDOUT, ":encoding(utf8)";

use Maze::Generator::Cell;
use Maze::Generator::Validations qw(validate_index);
use Moo;

use overload '""' => 'to_string';

our $MAX_INDEX_BITS = 8;

use constant {
    TOPLEFT  => '┌',
    HBAR     => '─',
    VBAR     => '│',
    VRIGHT   => '├',
    VHORIZ   => '┼',
    VLEFT    => '┤',
    HDOWN    => '┬',
    HUP      => '┴',
    TOPRIGHT => '┐',
    BOTLEFT  => '└',
    BOTRIGHT => '┘',
};

has rows => (
    is  => "ro",
    isa => sub { validate_index($_[0], $MAX_INDEX_BITS) },
    required => 1,
);

has cols => (
    is  => "ro",
    isa => sub { validate_index($_[0], $MAX_INDEX_BITS) },
    required => 1,
);

has grid => (
    is      => "rw",
    lazy    => 1,
    builder => sub {
        my $self = shift;
        my @ret;
        for my $i (0..$self->rows-1) {
            push @ret, [];
            for my $j (0..$self->cols-1) {
                my $cell =
                    Maze::Generator::Cell->new(row => $i, col => $j);
                push @{$ret[-1]}, $cell;
                # add_neighbor is bidirectional by default, so we only need to
                # link to north and west.
                $cell->add_neighbor($ret[$i-1][$j]) if $i > 0;
                $cell->add_neighbor($ret[$i][$j-1]) if $j > 0;
            }
        }
        return \@ret;
    },
);

sub with_each_cell_do {
    my ($self, $code) = @_;
    for my $row (0..$self->rows-1) {
        for my $col (0..$self->cols-1) {
            my $cell = $self->cell_at($row, $col);
            $code->($cell);
        }
    }
}

sub cell_at {
    my ($self, $row, $col) = @_;
    return $self->grid->[$row][$col];
}

sub last_row {
    return shift->rows-1;
}

sub last_col {
    return shift->cols-1;
}

sub to_string {
    my $self = shift;
    # Since most of the times fonts are longer than they are wider,
    # we print each horizontal linking character multiple times to try
    # to make up. This is not perfect though.
    my $num_horiz_reps = 2;
    my @ret;

    # Top boundary.
    push @ret, TOPLEFT;
    for my $i (0..$self->cols-1) {
        push @ret, (HBAR) x $num_horiz_reps;
        if ($i == $self->cols-1) {
            push @ret, TOPRIGHT, "\n";
        } else {
            my $cell_below = $self->cell_at(0, $i);
            my $cell_below_linked_to_its_east =
                                $cell_below
                             && $cell_below->east
                             && $cell_below->is_linked_to($cell_below->east);
            push @ret, ($cell_below_linked_to_its_east ? HBAR : HDOWN);
        }
    }
    # Intermediate rows
    for my $i (0..$self->rows-1) {
        if ($i < $self->rows-1) {
            push @ret, VRIGHT;
        } else {
            push @ret, BOTLEFT;
        }
        for my $j (0..$self->cols-1) {
            my $cell  = $self->cell_at($i, $j);
            my $south = $cell->south;

            # Rightmost cell in any row has no east cell, so always "unlinked".
            my $east_linked = $cell->east
                           && $cell->is_linked_to($cell->east);

            my $south_linked = $cell->south
                            && $cell->is_linked_to($cell->south);

            if ($south_linked) {
                push @ret, (' ') x $num_horiz_reps;
            } else {
                push @ret, (HBAR) x $num_horiz_reps;
            }

            # For the bottom row, assume a value of false.
            my $south_linked_to_its_east =
                                $cell->south
                             && $cell->south->east
                             && $cell->south->is_linked_to($cell->south->east);

            my $is_right_boundary_cell  = ($j == $self->cols-1);
            my $is_bottom_boundary_cell = ($i == $self->rows-1);

            my $conn_char;
            if (!$east_linked && !$south_linked_to_its_east) {
                $conn_char = BOTRIGHT
                    if $is_right_boundary_cell && $is_bottom_boundary_cell;
                $conn_char = VLEFT
                    if $is_right_boundary_cell && !$is_bottom_boundary_cell;
                $conn_char = HUP
                    if !$is_right_boundary_cell && $is_bottom_boundary_cell;
                $conn_char = VHORIZ
                    if !$is_right_boundary_cell && !$is_bottom_boundary_cell;
            } elsif (!$east_linked && $south_linked_to_its_east) {
                $conn_char = HUP;
            } elsif ($east_linked && !$south_linked_to_its_east) {
                $conn_char = $is_bottom_boundary_cell ? HBAR : HDOWN;
            } elsif ($east_linked && $south_linked_to_its_east) {
                $conn_char = HBAR;
            }
            push @ret, $conn_char;
        }
        push @ret, "\n";
    }
    return join "", @ret;
}

1;
