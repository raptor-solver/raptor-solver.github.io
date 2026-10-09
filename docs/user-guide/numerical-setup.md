# Numerical Setup

After `raptor.build`, all numerical settings are in `problem.config`. They
can be changed between solves without rebuilding the problem:

```matlab
problem.config.transcription    % derivatives
problem.config.scaling          % conditioning
problem.config.solver           % NLP back end, see NLP Solvers
problem.config.postprocessing   % validation and plots, see Solution and Validation
```

!!! warning "Set `method` first"
    Setting `method` resets the corresponding `settings` to their default
    values. Set the method first, then change its settings:

    ```matlab
    problem.config.solver.method = "Ipopt";
    problem.config.solver.settings.output_print_level = 3;
    ```

The defaults are central differences with step `1e-5`, no scaling, and IPOPT
with tolerance `1e-6` and at most `3000` iterations. When changing the
settings, change one at a time.

## Derivatives

The NLP solver needs the gradient of the cost and the Jacobian of the
constraints. RAPTOR obtains them from three sources: terms marked as
`"linear"`, optional user-supplied derivatives, and a numerical
differentiation method for all other terms.

```matlab
problem.config.transcription.numericalJacobian = "CentralDifferences";
problem.config.transcription.finiteStep = 1e-5;
```

### Central differences

Works with any smooth, real-valued MATLAB code. The default step `1e-5` is a
starting value: with a smaller step the round-off error increases, with a
larger step the truncation error increases.

### Complex-step differences

```matlab
problem.config.transcription.numericalJacobian = "ComplexStepDifferences";
problem.config.transcription.finiteStep = 1e-10;
```

Complex-step differentiation has no subtractive cancellation, so a very
small step can be used and the derivatives are accurate to near machine
precision. All functions must handle complex inputs correctly. The following
operations are not compatible:

- `abs`, `norm`, `vecnorm` and other non-analytic functions;
- comparisons and branches on perturbed values (`if`, `max`, `min`);
- `real`, `imag`, or casts to a real type;
- external code that rejects complex input.

Write norms as `sqrt(sum(v.^2, 1))` instead (other replacements are
listed in [Vectorized Functions](../getting-started/vectorized-functions.md#complex-step-differentiation)).
If in doubt, compare the results with central differences.

### Dual-step differences

`"DualStepDifferences"` is also available. Use it only if your functions
support dual-number arithmetic. The examples use central and complex-step
differences.

??? info "Sparsity detection and manual derivatives"
    During the build, RAPTOR finds which inputs each function depends on by
    setting the inputs to `NaN`. If a function does not accept `NaN`, RAPTOR
    uses small perturbations around the initial guess instead. This can miss
    dependencies that are inactive at the initial guess, for example a branch
    or saturation that becomes active later. Avoid branches where possible.

    Derivative information can also be provided on the term returned by
    `add`, through `term.jacobian.pattern.<field>` or
    `term.jacobian.value.<field>`, where the field names are the `inputData`
    fields. Compare user-supplied derivatives with finite differences before
    using them.

## Scaling

Scaling brings the variables, constraints and cost to similar orders of
magnitude, which improves the numerical behaviour of the NLP solver. It does
not change the solution, and results are always returned in the original
units.

```matlab
problem.config.scaling.method = "BoundsProjection";
```

| Method | What it does |
| --- | --- |
| `"NoScaling"` | Leaves the NLP unchanged. A good baseline for nondimensional models. |
| `"BoundsProjection"` | Maps each variable using its box bounds. Needs realistic finite bounds. |
| `"RuizStatic"` | Iteratively equilibrates the rows and columns of the Jacobian. |
| `"JacobianRowNormalization"` | Normalizes constraint Jacobian rows. |
| `"PJRN"` | Projected Jacobian row normalization: bounds projection, then row normalization of the projected Jacobian. |
| `"Permutation"` | Reorders the system (`"DmPerm"` or `"RowColAmd"`). |
| `"Manual"` | Uses characteristic magnitudes you provide per phase. |

Several methods can be combined by passing an array. They are applied in
the given order:

```matlab
problem.config.scaling.method = ["BoundsProjection", "RuizStatic"];
```

The methods that can be combined are `BoundsProjection`, `RuizStatic`,
`JacobianRowNormalization`, `Permutation` and `Manual`.

??? example "Method settings"
    ```matlab
    % Ruiz equilibration
    problem.config.scaling.method = "RuizStatic";
    problem.config.scaling.settings.tol = 1e-5;
    problem.config.scaling.settings.max_iter = 100;
    problem.config.scaling.settings.which_norm = Inf;   % 1, 2 or Inf

    % permutation
    problem.config.scaling.method = "Permutation";
    problem.config.scaling.settings.technique = "DmPerm";

    % manual, one entry per component (here for a phase named "ascent")
    problem.config.scaling.method = "Manual";
    problem.config.scaling.settings.ascent.time     = 100;
    problem.config.scaling.settings.ascent.states   = [1e5; 1e3; 1e4];
    problem.config.scaling.settings.ascent.controls = 1;
    problem.config.scaling.settings.ascent.cost     = 100;
    ```

    For manual scaling, `settings` has one field per phase, named after the
    phase. Each phase has the fields `time`, `states`, `controls`,
    `localParameters`, `globalParameters`, `cost`, and one field per
    constraint of the phase. Use tab completion to see them. Fields left
    empty are not scaled. When manual scaling is combined with other
    methods, the settings are in `settings.Manual`.

!!! tip "Signs of poor scaling"
    Typical signs are slow progress, oscillating constraint violation, very
    small steps, or results that change when the units change. Before
    changing the scaling method, use consistent units, check the typical
    magnitudes of the variables and constraints, avoid bounds much wider than
    the expected values, and check the derivatives.
