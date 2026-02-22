import sys
from functools import reduce
from itertools import takewhile


def generate(seed, func):
    """Unfold an infinite sequence from a seed by repeatedly applying func.

    This is the dual of reduce() (fold/aggregate). Where reduce() consumes
    a sequence and collapses it into a single value (Iterable[T] -> T),
    generate() expands a single seed value out into a sequence (T -> Iterable[T]).
    Python provides reduce() built-in (via functools), but has no built-in unfold,
    which is why this function is needed.
    """
    current = seed
    while True:
        yield current
        current = func(current)


def zeckendorf(n):
    # Build the Fibonacci sequence up to n using an unfold from (1, 2).
    fibs = list(reversed([
        a for a, b in takewhile(lambda t: t[0] <= n, generate((1, 2), lambda t: (t[1], t[0] + t[1])))
    ]))

    # Greedily subtract the largest fitting Fibonacci number until we reach 0.
    _, result = reduce(
        lambda acc, fib: (acc[0] - fib, acc[1] + [fib]) if fib <= acc[0] else acc,
        fibs,
        (n, [])
    )
    return result


n = int(sys.argv[1])
print(','.join(str(f) for f in zeckendorf(n)))
