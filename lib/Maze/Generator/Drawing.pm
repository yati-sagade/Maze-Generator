package Maze::Generator::Drawing;
use strictures 2;
use GD::Simple;
use Moo;

has output_filename => (
    is  => 'ro',
    isa => sub {
        my $val = shift;
        die 'Only jpeg and png outputs are supported at the moment'
            unless _get_extension($val);
    },
);

has cell_size => (
    is      => 'ro',
    default => sub { 10 },
);

sub draw {
    my ($self, $grid) = @_;

    my $img_height = $self->cell_size * $grid->rows;
    my $img_width  = $self->cell_size * $grid->cols;

    my $img = GD::Simple->new($img_width + 1, $img_height + 1);
    $img->bgcolor(undef);
    $img->fgcolor('black');

    $grid->with_each_cell_do(sub {
        my $cell = shift;

        my ($x1, $x2, $y1, $y2) = $self->get_cell_rect_bounds($cell);

        $self->_draw_line($img, $x1, $y1, $x2, $y1) unless $cell->north;
        $self->_draw_line($img, $x1, $y1, $x1, $y2) unless $cell->west;
        $self->_draw_line($img, $x2, $y1, $x2, $y2)
            if !$cell->east || !$cell->is_linked_to($cell->east);
        $self->_draw_line($img, $x1, $y2, $x2, $y2)
            if !$cell->south || !$cell->is_linked_to($cell->south);

    });

    {
        open my $out, '>', $self->output_filename
            or die "Could not open $self->output_filename for writing";
        binmode $out;
        my $meth = lc _get_extension($self->output_filename);
        $meth = 'jpeg' if $meth eq 'jpg';
        print $out $img->$meth;
    }
}

sub get_cell_rect_bounds {
    my ($self, $cell) = @_;

    my $x1 = $cell->col       * $self->cell_size;
    my $y1 = $cell->row       * $self->cell_size;
    my $x2 = ($cell->col + 1) * $self->cell_size;
    my $y2 = ($cell->row + 1) * $self->cell_size;

    return ($x1, $x2, $y1, $y2);
}

sub _draw_line {
    my ($self, $img, $x1, $y1, $x2, $y2) = @_;
    $img->moveTo($x1, $y1);
    $img->lineTo($x2, $y2);
}

sub _get_extension {
    my $val = shift;
    $val =~ /^.+\.(png|jpeg|jpg)$/;
    return $1;
}


1;
