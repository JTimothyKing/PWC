import sys

def zeckendorf(n):
    # Build the Fibonacci sequence up to n.
    fibs = [1, 2]
    while fibs[-1] + fibs[-2] <= n:
        fibs.append(fibs[-1] + fibs[-2])

    # Subtract the largest possible Fibonacci numbers from n until we reach 0.
    result = []
    for fib in reversed(fibs):
        if fib <= n:
            result.append(fib)
            n -= fib
            if n == 0:
                break

    return result

n = int(sys.argv[1])
print(','.join(str(f) for f in zeckendorf(n)))

