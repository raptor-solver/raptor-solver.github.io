# Collocation

Each phase is discretized with a pseudospectral method, either on a single
segment (global collocation) or on several segments
([hp collocation](#hp-collocation)). It is set through `phase.collocation`
before the build:

```matlab
phase.collocation.interpolant = "Lagrange";
phase.collocation.polynomials = "Legendre";
phase.collocation.nodes       = "Gauss-Radau";
phase.collocation.nNodes      = 40;
```

| Property | Options | Default |
| --- | --- | --- |
| `interpolant` | `"Lagrange"`, `"Birkhoff_a"`, `"Birkhoff_b"` | `"Lagrange"` |
| `polynomials` | `"Legendre"`, `"Chebyshev"` | `"Legendre"` |
| `nodes` | `"Gauss-Radau"`, `"flipped-Gauss-Radau"`, `"Gauss-Lobatto"` | `"Gauss-Lobatto"` |
| `nNodes` | integer, or array of integers for an [hp grid](#hp-collocation) | `10` |
| `interpolationMethod` | any MATLAB `interp1` method, e.g. `"linear"`, `"pchip"` | `"linear"` |
| `dynamicsTolerance` | scalar | `0` |
| `timeDilation` | `"affine"` or a custom mapping (below) | `"affine"` |

!!! tip "Recommended settings"
    Most examples use Lagrange interpolation with Legendre polynomials and
    Gauss-Radau or Gauss-Lobatto nodes. Start with one of these settings and
    change one option at a time. Not all combinations in the table are
    implemented yet.

## Number of nodes

More nodes give a larger NLP and, for smooth problems, a smaller
discretization error. They do not fix modelling errors, wrong derivatives or
an infeasible guess. To choose the number of nodes:

1. Solve on a moderate grid.
2. Check the propagation error and the constraints.
3. Increase `nNodes` and solve again.
4. Compare objective, trajectories and validation error.
5. Stop when the changes are below the accuracy required by your
   application.

## hp collocation

By default, a phase is discretized with a single polynomial over the whole
phase (global collocation). Setting `nNodes` to an array divides the phase
into segments of equal duration, one for each element of the array, with
the given number of nodes in each segment:

```matlab
phase.collocation.nodes  = "Gauss-Radau";
phase.collocation.nNodes = [10 10 10 10];   % 4 segments, 10 nodes each
```

The states are continuous across the segment boundaries. hp collocation
increases the number of segments instead of the polynomial degree, which
usually works better for trajectories that are not smooth, for example with
bang-bang controls or sharp changes. Segments with more nodes can be used where the
trajectory changes faster, e.g. `nNodes = [6 6 15 6]`.

!!! note
    hp collocation is available with `"Gauss-Radau"` and
    `"flipped-Gauss-Radau"` nodes. `"Gauss-Lobatto"` nodes only support a
    single segment.

## Discretized and collocated grids

Some methods include points where the states and controls are defined but
the dynamics are not enforced (for example the final point with Gauss-Radau
nodes). The solution therefore has a `discretized` grid and a `collocated`
grid, which can have different lengths. Always use the `time` field of the
same grid.

With Birkhoff formulations, RAPTOR may add internal variables to the
controls. Check the size of the returned controls before indexing them.

## Custom time dilation

!!! abstract "Advanced"
    By default each phase maps pseudotime \(\tau \in [-1, 1]\) to physical
    time with the affine map
    \(t = t_0 + \tfrac{1}{2}(\tau + 1)(t_f - t_0)\). You can replace it with
    a different mapping \(t(\tau)\) and its derivative
    \(\mathrm{d}t/\mathrm{d}\tau\), for example to place more nodes where
    the trajectory changes quickly.

```matlab
phase.collocation.setTimeDilation(@timeMap, @timeRate, ...
    JacobianPattern = struct("initialTime", true, ...
                             "finalTime", true, ...
                             "localParameters", [true false]));
```

```matlab
function t = timeMap(inputData, tau)
% tau is a row of pseudotime nodes; return the matching physical times
T = inputData.finalTime - inputData.initialTime;
shape = inputData.localParameters(1);
t = inputData.initialTime + T .* (0.5 .* (tau + 1) + 0.25 .* shape .* (1 - tau.^2));
end

function rate = timeRate(inputData, tau)
T = inputData.finalTime - inputData.initialTime;
shape = inputData.localParameters(1);
rate = T .* (0.5 - 0.5 .* shape .* tau);
end
```

Both functions receive the phase `inputData` and a row vector of pseudotime
nodes, and return a row of the same length (they are
[vectorized](../getting-started/vectorized-functions.md) like the other model functions). `JacobianPattern` specifies
which endpoint times and local parameters the mapping depends on. The
derivatives of the mapping are computed with complex-step differences, so
the functions must support complex inputs. Alternatively, an analytical
`DilationJacobian` function can be provided, which is faster.

With an hp grid, the mapping is applied to each segment separately:
`inputData.initialTime` and `inputData.finalTime` are then the start and end
times of the segment.
