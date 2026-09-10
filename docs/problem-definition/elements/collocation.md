# Collocation

Every phase needs a pseudospectral discretization. Configure it through `phase.collocation` before calling `raptor.build`.

```matlab
phase.collocation.interpolant = "Lagrange";
phase.collocation.polynomials = "Legendre";
phase.collocation.nodes = "Gauss-Radau";
phase.collocation.nNodes = 49;
```

## Available properties

| Property | Supported values | Default |
| --- | --- | --- |
| `interpolant` | `"Lagrange"`, `"Birkhoff_a"`, `"Birkhoff_b"` | `"Lagrange"` |
| `polynomials` | `"Legendre"`, `"Chebyshev"` | `"Legendre"` |
| `nodes` | `"Gauss"`, `"Gauss-Radau"`, `"flipped-Gauss-Radau"`, `"Gauss-Lobatto"` | `"Gauss-Lobatto"` |
| `nNodes` | integer | `10` |
| `timeDilation` | `"affine"` | `"affine"` |
| `dynamicsTolerance` | scalar | `0` |
| `interpolationMethod` | MATLAB interpolation method such as `"linear"` or `"pchip"` | `"linear"` |

Not every theoretical interpolant/polynomial/node combination necessarily has an implemented core class. The examples primarily use Lagrange interpolation with Legendre Gauss-Radau or Gauss-Lobatto nodes; begin with an example-backed combination.

## Number of nodes

More nodes increase the NLP dimension and computational cost. They may reduce discretization error for a smooth, correctly formulated problem, but they do not repair inconsistent equations, bad derivatives, or an infeasible guess.

A practical refinement study is:

1. solve on a moderate grid;
2. inspect independent propagation and constraint satisfaction;
3. increase `nNodes` while warm-starting or rebuilding from the previous trajectory where appropriate;
4. compare objective, state histories, and maximum validation error;
5. stop when changes meet application tolerances.

## Discretized and collocated grids

Some schemes include nodes where states or controls are represented but dynamics are not collocated. Consequently, `solution.phase.discretized` and `.collocated` may have different column counts. Always use the matching `time` field.

With Birkhoff formulations RAPTOR may augment the internal control representation. Inspect the returned control dimensions before assuming they exactly match the originally declared controls.
