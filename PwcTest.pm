package PwcTest;
use v5.38;

=head1 NAME

PwcTest - Test the solutions for the Perl Weekly Challenge

=head1 SYNOPSIS

    use PwcTest;
    my $tester = PwcTest->new(
        tasks => \%tasks,
    );
    $tester->test_program($_) for @ARGV;

=head1 DESCRIPTION

This module provides a simple way to test the solutions for the Perl
Weekly Challenge. It is used by the test.pl script in the root directory
of the project.

=head1 METHODS

=head2 new

    my $tester = PwcTest->new(
        tasks => \%tasks,
        root_dir => $root_dir,
    );

Creates a new PwcTest object. The C<tasks> parameter is a reference to a
hash with the tasks to be tested. The optional C<root_dir> parameter is
the root directory of the project, where the test.pl script is located.
It defaults to C<$FindBin::RealBin>, but C<$FindBin> must be imported
before using this module.

=cut

sub new {
    my ($class, %args) = @_;
    my $self = { %args };
    $self->{root_dir} //= $FindBin::RealBin;
    return bless $self, $class;
}

=head2 test_program

    $tester->test_program($program);

Runs the tests for a program. The C<$program> parameter is the name of
the program to be tested, in the format C<language/task-name.sh>.

=cut

sub test_program {
    my ($self, $program) = @_;
    my $root_dir = $self->{root_dir};
    my $tasks = $self->{tasks};

    # $program is $lang/$task-$name.sh, but we only need to know $lang and $task.
    if ($program !~ m[^(.+)/(\d+)-.+\.sh$]) {
        say STDERR "Invalid program spec: $program";
        return;
    }
    my $lang = $1;
    my $task = $2;

    my $name = $tasks->{$task}{name};
    my $cases = $tasks->{$task}{cases};
    print "Running tests for $name ($lang)\n";
    for (my $idx_case = 0; $idx_case < @$cases; $idx_case++) {
        my $case = $cases->[$idx_case];
        my $input = $case->{input};
        my $output = $case->{output};
        my $cmd = "echo '$input' | sh $root_dir/$program";
        my $result = `$cmd`;
        print "Example " . ($idx_case + 1) . ": ";
        if (_is_same($output, $result)) { say "OK"; }
        else {
            say "FAIL";
            say "Input: " . _trim($input);
            say "Expected: " . _trim($output);
            say "Got: " . _trim($result);
        }
    }
}

# Trim a string
sub _trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

# Compare two strings by lines
sub _is_same {
    my ($first, $second) = @_;
    my @first_lines = split /\n/, $first;
    my @second_lines = split /\n/, $second;
    return 0 if @first_lines != @second_lines;
    for (my $i = 0; $i < @first_lines; $i++) { return 0 if _trim($first_lines[$i]) ne _trim($second_lines[$i]); }
    return 1;
}

1;