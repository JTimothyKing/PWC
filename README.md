# Tim King's Perl Weekly Challenge Solutions

© 2024 J. Timothy King

The source code for this repository is licensed under the terms of the
MIT License. See the file [LICENSE](LICENSE) for details.

This repository contains my solutions to the weekly challenges published
by the [Perl Weekly Challenge](https://perlweeklychallenge.org/). The
Perl Weekly Challenge is a weekly challenge for Perl programmers. Each
week, the site publishes two new challenges, and the community submits
solutions in Perl and other languages.

## Directory Structure

Each week's solutions are in a separate directory, named
`challenge-xxx`, where `xxx` is the week number on The Perl Weekly
Challenge site. Each directory contains subdirectories for each language
the solution is written in, as well as a `t` directory containing test
scripts. A `blog.md` file contains a write-up of the solution.

## Requirements

- The test scripts are written in Perl, so you need Perl to run them.
  They also require `Test2::V0`, `Test2::Tools::Spec`, and `Path::Tiny`.
  Individual tests may require additional CPAN modules.
- The Perl solutions require a sufficiently recent Perl interpreter,
  plus any CPAN modules that they use.
- The C# solutions require the .NET SDK.

I recommend using [perlbrew](https://perlbrew.pl/) to install and use an
appropriate version of Perl. These projects require at least Perl 5.38.
In general, I try to write the Perl solutions and tests not to require
additional CPAN modules, but in some case, this may be needed. If you're
using `perlbrew`, you can install missing modules using `cpanm`.

To run the C# solutions and tests, you need to have
the [.NET SDK](https://dotnet.microsoft.com/download) installed. These
projects use .NET 8.0. Multiple versions of the SDK are installed
side-by-side on the same machine, so you can install the latest version
without affecting other projects.

## Running the Tests

(Some early solutions use a `test.pl` script to test the solutions.
These will be refactored to use `.t` tests, which can be run as below.)

Each challenge's solution has a corresponding `.t` file in the `t`
directory, which contains tests for the solution. This file can be run
directly, using `perl`, or can be run using `yath` or `prove`.
