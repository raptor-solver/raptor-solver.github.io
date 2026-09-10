# Postprocessing

RAPTOR postprocessing assembles trajectories and constraints, reconstructs dual quantities, numerically propagates the dynamics, and optionally creates plots.

## Numerical validation

```matlab
problem.config.postprocessing.validation.method = "RungeKutta45";
problem.config.postprocessing.validation.relTol = 1e-8;
```

The current public method is `"RungeKutta45"`, based on MATLAB's variable-step `ode45` integrator. It propagates the dynamics using the recovered control history and compares the propagated states with the collocation solution.

This is an accuracy check distinct from NLP feasibility. Choose `relTol` tight enough that integration error is below the trajectory discrepancy you want to measure.

## Automatic plots

```matlab
problem.config.postprocessing.plotting.primal = true;
problem.config.postprocessing.plotting.dual = true;
problem.config.postprocessing.plotting.validation = true;
```

- `primal` plots states, controls, and registered constraints.
- `dual` plots reconstructed costates, Hamiltonian, and constraint covectors where available.
- `validation` compares discretized and propagated states and displays propagation error.

Metadata from each phase supplies names, labels, and units.

## Custom plotting callback

Register a one-input function handle to run after standard postprocessing:

```matlab
problem.config.postprocessing.plotting.auxiliaryFunction = @plotMission;
```

```matlab
function plotMission(solution)
    x = solution.flight.discretized.states(1, :);
    y = solution.flight.discretized.states(2, :);
    plot(x, y)
    axis equal
end
```

The callback must accept exactly one input. RAPTOR catches postprocessing plotting failures and reports them as warnings so that an otherwise completed solve can still return its solution.

## Replotting

After changing plot flags or the custom callback, regenerate plots from an existing compatible solution:

```matlab
problem.config.postprocessing.plotting.primal = false;
problem.config.postprocessing.plotting.validation = true;
problem.rePlot(solution);
```

`rePlot` uses the postprocessing configuration applied during the latest `solve`. If configuration was changed after that solve, solve again when necessary to rebuild internal postprocessing settings.

Interpretation of the result fields is covered in [Solution](../analyzing-results/solution.md) and [Visualization](../analyzing-results/visualization.md).
