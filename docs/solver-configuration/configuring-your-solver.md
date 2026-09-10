# Configuring the solver

`raptor.build` returns a `raptor.RAPTOR` object whose `config` property controls the numerical pipeline:

```matlab
problem = raptor.build(ocp);

problem.config.transcription
problem.config.scaling
problem.config.solver
problem.config.postprocessing
```

Configuration is deliberately separate from the continuous model. You can compare numerical strategies without rewriting dynamics or constraints.

## Configuration order

Assign a stage's `method` before changing its method-specific `settings`. A method assignment resets the settings object:

```matlab
problem.config.solver.method = "Ipopt";
problem.config.solver.settings.output_print_level = 3;
```

Reassigning `method` afterward discards that custom print level and restores IPOPT defaults.

## A conservative starting point

```matlab
problem.config.transcription.method = "NLP";
problem.config.transcription.numericalJacobian = "CentralDifferences";
problem.config.transcription.finiteStep = 1e-5;

problem.config.scaling.method = "BoundsProjection";

problem.config.solver.method = "Ipopt";
problem.config.solver.tol = 1e-6;
problem.config.solver.iter_limit = 3000;

problem.config.postprocessing.validation.method = "RungeKutta45";
problem.config.postprocessing.validation.relTol = 1e-8;
problem.config.postprocessing.plotting.primal = true;
problem.config.postprocessing.plotting.dual = true;
problem.config.postprocessing.plotting.validation = true;
```

Central differences accept a wider range of MATLAB callbacks than complex-step differences. Bounds projection is useful only when the model supplies meaningful finite bounds; otherwise start with `"NoScaling"` or manual physical nondimensionalization.

## Tune one stage at a time

1. Make the problem build with representative callback values and dimensions.
2. Verify derivative accuracy or compare differentiation methods.
3. Choose a scaling strategy and inspect magnitudes.
4. Solve with moderate grid size and tolerances.
5. Inspect solver termination and continuous-time validation.
6. Refine the grid or tolerances based on evidence.

Changing the solver, scaling, node count, derivative method, and initial guess simultaneously makes failures difficult to diagnose.

## Defaults

The current API defaults to NLP transcription, central differences with step `1e-5`, no scaling, IPOPT with tolerance `1e-6` and iteration limit `3000`, Runge–Kutta validation with relative tolerance `1e-8`, and all automatic plot families enabled.

Exact supported values are listed in the [Configuration API](../api-reference/configuration.md).
