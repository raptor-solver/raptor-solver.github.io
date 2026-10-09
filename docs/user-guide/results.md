# Solution and Validation

```matlab
sol = problem.solve();
```

`solve` returns a structure with general fields and one field for each
phase, named after the phase.

## General fields

| Field | Meaning |
| --- | --- |
| `exitStatus` | `true` when the solver reported successful termination |
| `objective` | objective value, in your original units |
| `solveTime` | solve time, where the solver reports it |
| `nIterations` | iteration count, where the solver reports it |
| `raw` | solver-level multipliers and warm-start data |

## Phase results

Each phase contains up to three versions of the trajectory:

```matlab
disc = sol.descent.discretized;   % full pseudospectral representation
coll = sol.descent.collocated;    % nodes where the dynamics are enforced
prop = sol.descent.propagated;    % integration of the dynamics
```

Each has its own `time` field. Always plot an array against the `time` of
the same grid.

```matlab
plot(disc.time, disc.states(1, :), "o")
hold on
plot(prop.time, prop.states(1, :), "--")
```

### Primal fields

The trajectories contain the `inputData` fields: `time`, `states`,
`controls`, `initialTime`, `finalTime`, `initialStates`, `finalStates`,
`initialControls`, `finalControls`, `localParameters`, `globalParameters` and
`auxdata`. RAPTOR adds `dynamics` and one field per named constraint:

```matlab
q = sol.descent.discretized.dynamicPressure;
```

### Dual fields

When the covector reconstruction succeeds, the grids also contain:

```text
costates
hamiltonian
covectors.<constraintName>
covectors.lowerBound.<variableFamily>
covectors.upperBound.<variableFamily>
```

These are computed with the covector mapping theorem. They can be used to
check the optimality conditions, to study switching structures, and to find
active bounds.

## Validation

After each solve, RAPTOR integrates the dynamics with the optimal controls
and compares the result with the discretized solution. This is the most
direct measure of the accuracy of the solution between the nodes.

```matlab
problem.config.postprocessing.validation.method = "RungeKutta45";   % ode45
problem.config.postprocessing.validation.relTol = 1e-8;
problem.config.postprocessing.validation.absTol = 1e-6;
```

```matlab
e = sol.descent.propagated.errors;
e.states        % component-by-time error history
e.max           % maximum Euclidean state error
e.rms           % RMS Euclidean state error
e.final         % error at the final time
e.rmsRelative   % RMS error relative to the propagated-state RMS
e.integral      % time integral of the error norm
```

The scalar metrics combine all state components. If the states have
different units or magnitudes, also check each component separately.

!!! success "Accepting a solution"
    - The solver reports success and `exitStatus` is `true`.
    - The trajectory and objective are physically plausible.
    - Bounds, boundary values, path constraints and linkages are satisfied.
    - The propagation error is small for your application.
    - The result is stable when you add nodes.

## Plots

RAPTOR can plot three groups of results after each solve:

```matlab
problem.config.postprocessing.plotting.primal     = true;   % states, controls, constraints
problem.config.postprocessing.plotting.dual       = true;   % costates, Hamiltonian, covectors
problem.config.postprocessing.plotting.validation = true;   % collocated vs propagated
```

Names, labels and units come from [phase metadata](problems-and-phases.md#metadata)
and from each constraint's `label` and `unit`.

### Custom plots

A custom plotting function can be set. It receives the solution and is
called after the standard post-processing:

```matlab
problem.config.postprocessing.plotting.auxiliaryFunction = @plotMission;
```

```matlab
function plotMission(sol)
x = sol.flight.discretized.states(1, :);
y = sol.flight.discretized.states(2, :);
figure; plot(x, y); axis equal; grid on
end
```

Errors in plotting functions are reported as warnings, so the solution is
still returned.

### Plots of several phases

By default, the plots are created separately for each phase. You can select
which phases are plotted individually, and which phases are plotted together
in the same figures (for example, consecutive phases of one trajectory):

```matlab
problem.config.postprocessing.plotting.phases = "landing";   % default "all"; [] for none
problem.config.postprocessing.plotting.combinedPhases = ...
    {["boostback" "freefall" "landing"], ["freefall" "landing"]};
```

Each set of combined phases is plotted in its own figures, with the lines
interrupted at the phase boundaries. The combined phases must have the same
number of states and controls, and only the constraints defined in all of
them are plotted.

### Replotting

```matlab
problem.config.postprocessing.plotting.primal = false;
problem.rePlot(sol);
```

`rePlot` regenerates the figures for an existing solution, using the
post-processing settings of the latest solve.

??? abstract "Experimental: solving again from a previous solution"
    `problem.warmStart(sol)` solves the problem again starting from `sol`.
    `problem.reConverge(sol)` does the same, but first applies the current
    `problem.config` (for example a smaller `tol` or a different solver).
    These functions do not yet check that `sol` belongs to the same
    problem.
