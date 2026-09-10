# Build, solve, and results API

## `raptor.build`

```matlab
problem = raptor.build(ocp)
```

Converts a `raptor.api.v1.OptimalControlProblem` into a `raptor.RAPTOR` solver object.

During the build RAPTOR:

- converts phases and linkages to internal descriptors;
- creates and interpolates the initial trajectories;
- creates collocation operators;
- evaluates callbacks to establish output sizes and dependencies;
- estimates missing Jacobian sparsity patterns;
- validates the internal problem representation;
- creates default `raptor.api.config.RaptorConfig` and postprocessing metadata.

The returned object is independent of later edits to `ocp`. Build errors occur before an NLP backend is called.

## `raptor.RAPTOR.solve`

```matlab
solution = problem.solve()
```

Uses the current configuration to instantiate transcription, solver, scaling, and validation routines; builds the transcription and scaling; runs the NLP backend; then assembles and plots postprocessed results.

The selected backend writes iteration information to the MATLAB Command Window. Postprocessing failures are normally reported as warnings and may leave only some result fields populated.

## `raptor.RAPTOR.rePlot`

```matlab
problem.rePlot(solution)
```

Regenerates enabled primal, dual, validation, and auxiliary plots from a compatible existing solution. It does not rerun the NLP solver.

## Warm-start methods

### `reConverge`

```matlab
newSolution = problem.reConverge(previousSolution)
```

Copies each phase's previous discretized trajectory into the initial guess, reconstructs transcription, solver, scaling, and validation routines from the current configuration, and passes `previousSolution.raw` to the backend as warm-start information.

### `warmStart`

```matlab
newSolution = problem.warmStart(previousSolution)
```

Copies the previous discretized trajectory into the initial guess and resolves while reusing more of the existing internal routine state, including the existing scaling object.

!!! warning
    The current source marks compatibility checks for both warm-start paths as TODO. Use only with a previous solution from the same built problem and compatible grid, configuration, phase names, dimensions, and backend. Call `solve()` at least once before `warmStart()` so the required internal objects exist.

## Top-level solution fields

| Field | Description |
| --- | --- |
| `exitStatus` | Backend-specific success mapped to a logical value |
| `objective` | Descaled objective value |
| `solveTime` | Solve time where the adapter provides it |
| `nIterations` | Iteration count where provided |
| `raw.zl`, `raw.zu` | Raw/lower and upper bound multiplier data |
| `raw.lambda` | Raw NLP constraint multipliers |
| `<phaseName>` | Phase-specific postprocessed data |

Do not interpret `raw` as a backend-independent scientific result. Its primary use is internal warm-start support; conventions can differ between adapters.

## Phase solution fields

```text
solution.<phase>.discretized
solution.<phase>.collocated
solution.<phase>.propagated
```

### Discretized and collocated

Both contain relevant `raptor.inputData` fields. RAPTOR adds:

```text
dynamics
<namedConstraint>
costates
hamiltonian
covectors
```

`costates`, `hamiltonian`, and `covectors` are present only when dual postprocessing succeeds.

### Propagated

Numerical validation returns:

```text
time, states, controls
initialTime, finalTime
initialStates, finalStates
initialControls, finalControls
localParameters, globalParameters, auxdata
errors.states
errors.rms, errors.max, errors.final
errors.rmsRelative, errors.integral
```

The propagated grid is chosen by the validation integrator and generally differs from both pseudospectral grids.

## Dynamic field access

Phase and constraint names are user-defined fields. For a variable name stored as a string:

```matlab
phaseName = "descent";
constraintName = "dynamicPressure";
q = solution.(phaseName).discretized.(constraintName);
```

This form is useful for reusable analysis across problems and phases.
