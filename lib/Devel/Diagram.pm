package Devel::Diagram;

use strict;
use warnings;

use Scalar::Util qw(isweak);

sub diagram {
    my $obj = shift;
    my $depth = shift || 0;
    my $history = shift || {};
    my $output = '';

    unless (defined $obj) {
        return "(undef)\n";
    }

    unless (ref $obj) {
        return "'$obj'\n";
    }

    my $weak = eval { isweak($obj) } ? '(weak) ' : '';

    $output .= "$weak$obj";

    if ($history->{$obj}) {
        return "$output ^^\n";
    }

    $output .= "\n";

    $history->{$obj}++;

    $depth++;

    my $pad = '  ' x $depth;

    eval {
        while (my ($key, $val) = each %$obj) {
            $output .= "$pad$key: ";
            $output .= diagram($val, $depth, $history);
        }
    };

    return $output unless $@;

    eval {
        foreach my $i (@$obj) {
            $output .= "$pad - ";
            $output .= diagram($i, $depth, $history);
        }
    };

    return $output unless $@;

    eval {
        $output .= "$pad** " . diagram($$obj);
    };

    return $output unless $@;

    return $output;
}

1;
