use strict;
use warnings;
use Test::More tests => 15;
use Test::Exception;

my $CLASS;
BEGIN {
    $CLASS = 'Maze::Generator::Grid';
    use_ok $CLASS or die;
}

my $rows = 3;
my $cols = 3;

isa_ok my $grid = Maze::Generator::Grid->new(rows => $rows, cols => $cols), $CLASS, 'Constructing a grid should work';

is $grid->rows, $rows, 'Grid rows property should be set correctly';
is $grid->cols, $cols, 'Grid cols property should be set correctly';

my $center = $grid->cell_at(1, 1);
isa_ok $center, 'Maze::Generator::Cell', 'Accessing a cell should work';

is_deeply $center->north, $grid->cell_at(0, 1), 'North cell should be set correctly';

# $rows*$cols tests in total below
for my $i (0..$rows-1) {
    for my $j (0..$cols-1) {
        my $cell = $grid->cell_at($i, $j);
        my $expected_links;
        # corners
        $expected_links //= 2
            if  ($i == 0 && $j == 0)
             || ($i == 0 && $j == $cols - 1)
             || ($i == $rows - 1 && $j == 0)
             || ($i == $rows - 1 && $j == $cols - 1);

        # borders
        $expected_links //= 3
            if  (($i == 0 || $i == $rows - 1) && $j != 0 && $j != $cols - 1)
             || ($i != 0 && $i != $rows - 1 && ($j == 0 || $j == $cols - 1));

        $expected_links //= 4;

        is scalar @{$cell->neighbors}, $expected_links, "Number of links must be set correctly cell ($i, $j)";
    }
}



