import importlib
import numpy as np

module = importlib.import_module('numpy')
print(module.__version__)

rng1 = np.random.default_rng(seed=42)
a1 = rng1.integers(low=-10000, high=10000, size=100000)
b1 = rng1.random((350, 500))

rng2 = np.random.default_rng(seed=42)
a2 = rng2.integers(low=-10000, high=10000, size=100000)
b2 = rng2.random((350, 500))

assert np.array_equal(a1, a2)
assert np.array_equal(b1, b2)

