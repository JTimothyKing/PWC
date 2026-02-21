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
- The Python solutions require a Python interpreter.

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

The Python solutions use Python 3.12. To run the automated tests, a
virtual Python environment should be put in `.venv` off of the
repository root.

## Running the Tests

Each challenge's solution has a corresponding `.t` file in the `t`
directory, which contains tests for the solution. This file can be run
directly, using `perl`, or can be run using `yath` or `prove`.

To run all the tests, from the repository root:

yath */t/*.t

To run the tests for a specific challenge, from the repository root:

yath challenge-xxx/t/*.t

## Adding a New Challenge

To add a new challenge directory and tests:

1. **Create the challenge directory:**
    - Name it `challenge-xxx`, where `xxx` is the challenge number.
    - Inside, create subdirectories for each language you want to implement (e.g., `perl/`, `python/`, `csharp/`), and a
      `t/` directory for tests. (Only the language directories you plan to use are needed; you can add more later if you
      want.)

2. **Create a new test file:**
    - Use the provided script to generate a boilerplate test:

      ```sh
      perl tools/new_test.pl challenge-xxx ch-1
      ```
        - Replace `challenge-xxx` with your challenge directory and `ch-1` with your task ID (e.g., `ch-2`).
        - The script will create `challenge-xxx/t/ch-1.t` with a template for you to fill in.

3. **Add solution implementations:**
    - For Perl: Add your solution as `challenge-xxx/perl/ch-1.pl` (or `ch-2.pl`).
    - For Python: Add your solution as `challenge-xxx/python/ch-1.py` (or `ch-2.py`).
    - For C#: Add your solution as `challenge-xxx/csharp/ch-1/ch-1.csproj` (or `ch-2/ch-2.csproj`) and your code as
      `challenge-xxx/csharp/ch-1/ch-1.cs` (or `ch-2/ch-2.cs`). You may also want to create a solution file in the
      `csharp` directory to include the new project, but it isn't required for the tests to run.

4. **Edit the test file:**
    - Fill in the test template with input/output examples and test logic.
    - Tests are run using `yath`, `prove`, or directly with `perl`, as described in the "Running the Tests" section
      above.
