# Solution and validation

`problem.solve()` returns a structure with solver-level fields and one field per phase name.

```matlab
solution = problem.solve();
```

## Solver-level fields

The current adapters populate:

| Field | Meaning |
| --- | --- |
| `exitStatus` | logical success recognized by the selected adapter |
| `objective` | objective value in original problem scaling |
| `solveTime` | reported solve time where available |
| `nIterations` | reported iteration count where available |
| `raw` | backend-oriented multipliers and warm-start data |

Use `exitStatus` together with the solver's command-window termination message. Some backends do not currently provide every timing or iteration metric and may return `NaN` or `Inf` for unavailable data.

## Phase-level grids

For a phase named `descent`:

```matlab
disc = solution.descent.discretized;
coll = solution.descent.collocated;
prop = solution.descent.propagated;
```

**`discretized`** contains the full pseudospectral representation, including endpoint-only nodes where applicable.

**`collocated`** contains values at nodes where the differential equations are enforced. It may have fewer columns.

**`propagated`** is produced independently by numerical integration using interpolated optimized controls.

Always pair an array with the `time` field from the same grid:

```matlab
plot(disc.time, disc.states(1, :))
hold on
plot(prop.time, prop.states(1, :), "--")
```

## Primal fields

The discretized trajectory includes the public `raptor.inputData` fields as applicable:

```text
time, states, controls
initialTime, finalTime
initialStates, finalStates
initialControls, finalControls
localParameters, globalParameters, auxdata
```

RAPTOR adds `dynamics` and named constraint fields. If a path constraint was named `dynamicPressure`, access:

```matlab
q = solution.descent.discretized.dynamicPressure;
```

## Dual fields

When covector reconstruction succeeds, phase grids contain:

```text
costates
hamiltonian
covectors.<constraintName>
covectors.lowerBound.<variableFamily>
covectors.upperBound.<variableFamily>
```

These quantities are reconstructed through the covector mapping theorem. Use them for optimality analysis, switching interpretation, and diagnosing active bounds, while keeping sign conventions and solver tolerances in mind.

## Validation errors

RAPTOR interpolates the discretized states to the propagation times and subtracts the propagated states. The result is:

```matlab
errors = solution.descent.propagated.errors;
errors.states       % component-by-time error history
errors.rms          % RMS Euclidean state error
errors.max          % maximum Euclidean state error
errors.final        % final Euclidean state error
errors.rmsRelative  % RMS error normalized by propagated-state RMS
errors.integral     % time integral of the error norm
```

These metrics combine state components. When states have different units or scales, also inspect component-wise errors or compute nondimensional metrics appropriate to the application.

## Acceptance checklist

- The backend reports successful termination and `exitStatus` is true.
- The objective and trajectory are physically plausible.
- Bounds, boundary values, path constraints, and linkage conditions are satisfied within appropriate tolerances.
- Propagation error is small relative to application accuracy requirements.
- Results remain stable under a reasonable grid-refinement study.
- Derivative and scaling choices have been verified rather than merely tuned until convergence.
