import sys

# Read the matrix from stdin, one row per line, values space-separated.
party = [[int(x) for x in line.split()] for line in sys.stdin]

def find_celebrity(party):
    n = len(party)

    # Phase 1: find the candidate.
    # If A knows B, A is not the celebrity. If A doesn't know B, B is not the celebrity.
    candidate = 0
    for i in range(1, n):
        if party[candidate][i]:
            candidate = i

    # Phase 2: verify the candidate.
    for i in range(n):
        if i == candidate:
            continue
        # The candidate must not know i, and i must know the candidate.
        if party[candidate][i] or not party[i][candidate]:
            return -1

    return candidate

print(find_celebrity(party))

