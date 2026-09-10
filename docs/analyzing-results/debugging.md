# Debugging

Diagnose the earliest failing stage: installation, model callback, build, NLP solve, or continuous-time validation. Later-stage settings cannot fix an earlier-stage error.

## The problem does not build

Check, in order:

1. Every user function accepts one input argument.
2. Path functions work with several time columns and return the expected row count.
3. Constraint output rows match their bound-vector lengths.
4. State, control, and parameter order is consistent everywhere.
5. Fixed endpoint values lie within box bounds.
6. Initial-guess state and control matrices have matching column counts.
7. All guess values, local parameters, and global parameters are defined.
8. Collocation strings use exact supported spelling and case.

Reproduce a failing callback outside RAPTOR with a manually populated `raptor.inputData`. The first MATLAB exception usually contains more actionable information than the later build context.

## The solver does not converge

Before changing tolerances:

1. Recheck equations, signs, units, and component ordering against the mathematical formulation.
2. Confirm that boundary conditions, bounds, and general constraints are mutually feasible.
3. Plot the initial guess and evaluate all functions on it.
4. Verify numerical derivatives on representative points.
5. Inspect variable, objective, constraint, gradient, and Jacobian magnitudes.
6. Start on a moderate collocation grid.
7. Read the solver's exact termination reason.

Typical interpretations:

- **Restoration or infeasibility failure:** suspect inconsistent constraints, poor scaling, or an initial guess far from a feasible region.
- **Tiny steps or no progress:** suspect bad derivatives, ill-conditioning, non-smooth functions, or overly tight tolerances.
- **Diverging iterates:** suspect missing bounds, sign errors, an unbounded objective, or invalid values returned by callbacks.
- **Iteration limit:** inspect whether feasibility and optimality were improving before increasing the limit.

## Complex-step gives a different answer

Search callbacks for `abs`, `norm`, comparisons, clipping, lookup routines that discard imaginary parts, or external code that is not complex-safe. Compare with central differences. A very small complex step is helpful only when the full evaluation chain preserves it.

## The solver converges but propagation is inaccurate

- Plot discretized and propagated states component by component.
- Locate the time interval where error grows.
- Increase nodes and repeat a refinement study.
- Use a smoother or more appropriate control interpolation method.
- Check for discontinuities or sharp boundary layers.
- Tighten the validation integrator tolerance if it is not already below the observed error.
- Verify that linked phases propagate from the intended upstream final state.

Tightening only the NLP tolerance may not reduce discretization error.

## Automatic plotting or dual reconstruction fails

Postprocessing stages are guarded so the main solve can still return a structure. Inspect the warning and verify which fields actually exist before indexing them. A missing `costates` or `propagated` field usually means that corresponding postprocessing stage failed, not that the primal NLP result disappeared.

## Minimal reproducible report

Include:

- RAPTOR version and commit if available;
- MATLAB release, operating system, and architecture;
- selected solver and its version;
- complete build and solver output;
- configuration values changed from defaults;
- a minimal problem and callbacks;
- result of the bundled double-integrator example;
- solver status and validation error metrics.

Remove proprietary data while preserving dimensions, value scales, and the behavior that reproduces the issue.
