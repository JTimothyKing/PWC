import sys
from functools import reduce

# Read the matrix from stdin, one row per line, values space-separated.
party = [[int(x) for x in line.split()] for line in sys.stdin]

def find_celebrity(party):
    n = len(party)

    # Phase 1: find the candidate.
    # If A knows B, A is not the celebrity. If A doesn't know B, B is not the celebrity.
    candidate = reduce(lambda a, b: b if party[a][b] else a, range(n))

    # Phase 2: verify the candidate.
    # The candidate must not know anyone, and everyone must know the candidate.
    valid = all(i == candidate or (not party[candidate][i] and party[i][candidate]) for i in range(n))

    return candidate if valid else -1

print(find_celebrity(party))

