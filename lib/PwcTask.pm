package PwcTask;
use v5.38;
use warnings;

use Path::Tiny;

=head1 NAME

PwcTask - Module to test Perl Weekly Challenge solutions.

=head1 SYNOPSIS

    use PwcTask;
    my $challenge_dir = path($RealBin)->parent;
    my $task = PwcTask->new($challenge_dir, "ch-1");
    my $run;
    case $_->name => sub { $run = $_->prepare } for $task->language_cases;
    tests example_1 => sub {
        my $output = $run->(1, 2, 3);
        my $output_with_stdin = $run->with_stdin("text")->(1, 2, 3);
        is $output, 'expected output', 'Test example 1';
    };

=cut

sub new {
    my ($class, $dir, $name) = @_;
    return bless { dir => path($dir), name => $name }, $class;
}

sub dir { $_[0]->{dir} }
sub name { $_[0]->{name} }

sub language_cases {
    my $self = shift;
    return grep { $_->is_valid } map { PwcTask::Case->new($self, $_->basename) } grep { $_->is_dir } $self->{dir}->children;
}

package PwcTask::Case {
    use v5.38;
    use warnings;

    use Test2::V0 qw(diag);
    use Path::Tiny;

    sub new {
        my ($class, $task, $name) = @_;
        my $prepare = _make_prepare(path($task->dir), $name, $task->name);
        return bless { task => $task, name => $name, prepare => $prepare }, $class;
    }

    sub task { $_[0]->{task} }
    sub name { $_[0]->{name} }
    sub is_valid { defined $_[0]->{prepare} }
    sub prepare { $_[0]->{prepare}->() }

    sub _make_prepare {
        my ($dir, $lang, $task_name) = @_;

        if ($lang eq 'perl') {
            my $pldir = $dir->child($lang);
            my $pl = $pldir->child("$task_name.pl");
            return undef unless $pl->exists;
            return sub {
                diag "Using Perl source $pl";
                return PwcTask::Run->new('perl', '-I', "$pldir", $pl);
            };
        }

        if ($lang eq 'csharp') {
            my $proj = $dir->child($lang, $task_name, "$task_name.csproj");
            return undef unless $proj->exists;
            return sub {
                diag "Building C# project $proj";
                system(qw[dotnet build --configuration Release --framework net8.0], $proj) == 0 or die "Failed to build project $proj";
                my $dll = $dir->child($lang, $task_name, qw[bin Release net8.0], "$task_name.dll");
                die "Failed to build DLL $dll" unless -f $dll;
                diag "Using binary $dll";
                return PwcTask::Run->new('dotnet', $dll);
            }
        }

        return undef;
    }
}

package PwcTask::Run {
    use v5.38;
    use warnings;

    use overload '&{}' => \&_run_sub;

    sub new {
        my ($class, @cmd) = @_;
        return bless { cmd => \@cmd, stdin => undef }, $class;
    }

    sub with_stdin {
        my ($self, $stdin) = @_;
        my $clone = $self->_clone;
        $clone->{stdin} = $stdin;
        return $clone;
    }

    sub _clone {
        my $self = shift;
        return bless { %$self }, ref $self;
    }

    sub _run_sub {
        my ($self) = @_;
        sub {
            my @args = @_;
            my $cmd = $self->{cmd};
            my $stdin = $self->{stdin};
            my $output;
            if (defined $stdin) { $output = qx{echo "$stdin" | @$cmd @args}; }
            else { $output = qx{@$cmd @args}; }
            chomp $output;
            return $output;
        }
    }
}

1;