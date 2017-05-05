package Maze::Generator::Algorithm::Sidewinder;
use strictures 2;
use Moo;
use Maze::Generator::Util qw(random_choice);

with 'Maze::Generator::Algorithm';

sub name { 'sidewinder' }

sub description {
    return <<END
In this algorithm, each cell of the grid is visited, row after row, with each
row being dealt with left to right. At each cell, we do a coinflip and either
carve eastwards to elongate a run of cells, or we freeze the current run and
carve up from a random cell in the frozen run.
END
}

sub generate {
    my ($self, $grid) = @_;
    for (my $row = $grid->last_row; $row >= 0; --$row) {
        my @run;
        for my $col (0..$grid->last_col) {
            my $cell = $grid->cell_at($row, $col);
            next unless $cell->east;
            push @run, $cell if $row;
            if ($col != $grid->last_col && ($row == 0 || rand 1 < 0.5)) {
                $cell->link($cell->east);
            } else {
                my $carve_up_from = random_choice(\@run);
                $carve_up_from->link($carve_up_from->north);
                @run = ();
            }
        }
        if (@run) {
            my $carve_up_from = random_choice(\@run);
            $carve_up_from->link($carve_up_from->north);
            @run = ();
        }
    }
    return $grid;
}

1;
