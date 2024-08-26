#!/usr/bin/perl
use v5.38;

# This script runs a test on a program with the input and output cases
# for the corresponding problem.
# Run it this way: perl test.pl <language>/<task>-<name>.sh ...
# multiple programs can be tested at once by listing them all.

my %tasks = (
    1 => {
        name => 'Lucky Integer',
        cases => [
            {
                input => "\@ints = (2, 2, 3, 4)\n",
                output => "2\n",
            },
            {
                input => "\@ints = (1, 2, 2, 3, 3, 3)\n",
                output => "3\n",
            },
            {
                input => "\@ints = (1, 1, 1, 3)\n",
                output => "-1\n",
            },
        ],
    },
    2 => {
        name => 'Relative Sort',
        cases => [
            {
                input => "\@list1 = (2, 3, 9, 3, 1, 4, 6, 7, 2, 8, 5)\n"
                    . "\@list2 = (2, 1, 4, 3, 5, 6)\n",
                output => "(2, 2, 1, 4, 3, 3, 5, 6, 7, 8, 9)\n",
            },
            {
                input => "\@list1 = (3, 3, 4, 6, 2, 4, 2, 1, 3)\n"
                    . "\@list2 = (1, 3, 2)\n",
                output => "(1, 3, 3, 3, 2, 2, 4, 4, 6)\n",
            },
            {
                input => "\@list1 = (3, 0, 5, 0, 2, 1, 4, 1, 1)\n"
                    . "\@list2 = (1, 0, 3, 2)\n",
                output => "(1, 1, 1, 0, 0, 3, 2, 4, 5)\n",
            },
        ],
    },
);

for my $program (@ARGV) {
    test_program($program);
}

# Test a single program
sub test_program {
    my $program = shift;
    # $program is $lang/$task-$name.sh, but we only need to know $lang and $task.
    if ($program !~ m[^(.+)/(\d+)-.+\.sh$]) {
        say STDERR "Invalid program spec: $program";
        return;
    }
    my $lang = $1;
    my $task = $2;
    my $name = $tasks{$task}{name};
    my $cases = $tasks{$task}{cases};
    print "Running tests for $name ($lang)\n";
    for (my $idx_case = 0; $idx_case < @$cases; $idx_case++) {
        my $case = $cases->[$idx_case];
        my $input = $case->{input};
        my $output = $case->{output};
        my $cmd = "echo '$input' | sh $program";
        my $result = `$cmd`;
        print "Example " . ($idx_case + 1) . ": ";
        if (is_same($output, $result)) {
            say "OK";
        }
        else {
            say "FAIL";
            say "Input: " . trim($input);
            say "Expected: " . trim($output);
            say "Got: " . trim($result);
        }
    }
}

# Trim a string
sub trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

# Compare two strings by lines
sub is_same {
    my ($first, $second) = @_;
    my @first_lines = split /\n/, $first;
    my @second_lines = split /\n/, $second;
    return 0 if @first_lines != @second_lines;
    for (my $i = 0; $i < @first_lines; $i++) {
        return 0 if trim($first_lines[$i]) ne trim($second_lines[$i]);
    }
    return 1;
}

__END__
