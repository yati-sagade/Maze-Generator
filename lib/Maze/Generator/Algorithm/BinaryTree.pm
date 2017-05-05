package Maze::Generator::Algorithm::BinaryTree;
use strictures 2;
use Moo;
use feature qw(say);

with 'Maze::Generator::Algorithm';

sub name { 'binary_tree' }

sub description { 'The binary tree algorithm' }

sub generate {
    my ($self, $grid) = @_;
    $grid->with_each_cell_do(sub {
        my ($cell) = @_;
        my @neighbors;
        push @neighbors, $cell->north if $cell->north;
        push @neighbors, $cell->east  if $cell->east;
        return unless @neighbors;
        my $index = int rand scalar @neighbors;
        $cell->link($neighbors[$index]);
    });
    return $grid;
}

1;
