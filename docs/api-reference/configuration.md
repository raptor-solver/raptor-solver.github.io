# Configuration API

Users normally access configuration through `problem.config`, an instance of `raptor.api.config.RaptorConfig` created by `raptor.build`.

## `raptor.api.config.RaptorConfig`

```text
problem.config.transcription   raptor.api.config.TranscriptionConfig
problem.config.scaling         raptor.api.config.ScalingConfig
problem.config.solver          raptor.api.config.SolverConfig
problem.config.postprocessing  raptor.api.config.PostProcessingConfig
```

## `raptor.api.config.TranscriptionConfig`

| Property | Supported/default | Description |
| --- | --- | --- |
| `method` | `"NLP"` (default), `"SCP"` | Transcription family; SCP currently raises not implemented |
| `numericalJacobian` | `"CentralDifferences"` (default), `"ComplexStepDifferences"`, `"DualStepDifferences"` | Numerical derivative method |
| `finiteStep` | `1e-5` | Perturbation size |
| `settings` | no settings for NLP | Method-specific object |

```matlab
problem.config.transcription.method = "NLP";
problem.config.transcription.numericalJacobian = "ComplexStepDifferences";
problem.config.transcription.finiteStep = 1e-10;
```

## `raptor.api.config.ScalingConfig`

`method` accepts:

```text
NoScaling (default)
BoundsProjection
RuizStatic
JacobianRowNormalization
Permutation
Manual
CompositeLinearScaling (selected internally for an array)
```

Composable arrays may contain `BoundsProjection`, `RuizStatic`, `JacobianRowNormalization`, and `Permutation`:

```matlab
problem.config.scaling.method = ["BoundsProjection", "RuizStatic"];
problem.config.scaling.settings.RuizStatic.tol = 1e-5;
```

For a single method, its settings are directly under `.settings`. For a composed array, `.settings` has one field per method.

### Scaling-specific settings

| Method | Fields and defaults |
| --- | --- |
| `RuizStatic` | `tol = 1e-5`, `max_iter = 100`, `which_norm = Inf` (`1`, `2`, or `Inf`) |
| `Permutation` | `technique = "DmPerm"` (`"DmPerm"` or `"RowColAmd"`) |
| `Manual` | `phase` structure array of characteristic scales |
| Others | no public method-specific fields |

## `raptor.api.config.SolverConfig`

| Property | Default | Supported/meaning |
| --- | --- | --- |
| `method` | `"Ipopt"` | `"Ipopt"`, `"Snopt"`, `"Worhp"` |
| `tol` | `1e-6` | Generic main convergence tolerance |
| `iter_limit` | `3000` | Generic integer iteration limit |
| `settings` | IPOPT settings | Replaced when `method` changes |

### IPOPT settings

| Field | Default |
| --- | --- |
| `termination_wall_time` | `1e20` seconds |
| `convergence_dual_infeasibility_tol` | `1` |
| `convergence_constraint_violation_tol` | `1e-4` |
| `convergence_complementarity_tol` | `1e-4` |
| `parameters_mu_strategy` | `"adaptive"` |
| `acceptance_rel_tol` | `1e-6` |
| `acceptance_consecutive_iters_limit` | `15` |
| `acceptance_dual_infeasibility_tol` | `1e10` |
| `acceptance_constraint_violation_tol` | `1e-2` |
| `acceptance_complementarity_tol` | `1e-2` |
| `acceptance_objective_change_tol` | `1e20` |
| `failure_diverging_iterates_threshold` | `1e20` |
| `output_print_level` | `5` |
| `output_print_options` | `"no"` |

### SNOPT settings

| Field | Default |
| --- | --- |
| `minor_iterations_limit` | `100000` |
| `iterations_limit` | `100000` |
| `feasibility_tolerance` | `1e-16` (adapter sentinel/default behavior may apply) |
| `major_print_level` | `1` |
| `minor_print_level` | `1` |

The current SNOPT adapter hard-codes both print levels to `1` when solving, so changing the two exposed print fields does not alter output in this release. `feasibility_tolerance = 1e-16` acts as a sentinel: the adapter passes twice the generic `tol` to SNOPT.

### WORHP settings

| Field | Default/values |
| --- | --- |
| `license_file` | discovered/default temporary path |
| `parameters_file` | discovered/default temporary path |
| `algorithm` | `"SQP"`; also `"IP"` |
| `Timeout` | 7 days |
| `TolFeas` | `1e-16` (uses generic `tol` at sentinel value) |
| `AcceptTolOpti`, `AcceptTolFeas` | `1e-3` |
| `KeepAcceptableSol` | `true` |
| `ProvideHessian` | `false` |
| `InternalHessianApproximation` | `"BFGS"`; also `"FiniteDifference"` |
| `WhichFiniteDiff` | `"Central"`; also `"Forward"` |
| `FiniteDiffEps` | `1e-5` |
| `NLPprint` | `1` |

## `raptor.api.config.PostProcessingConfig`

Contains `validation` and `plotting`.

### `raptor.api.config.ValidationConfig`

| Property | Default | Description |
| --- | --- | --- |
| `method` | `"RungeKutta45"` | Current validation integrator |
| `relTol` | `1e-8` | Positive relative integration tolerance |

### `raptor.api.config.PlottingConfig`

| Property | Default | Description |
| --- | --- | --- |
| `primal` | `true` | Plot states, controls, and constraints |
| `dual` | `true` | Plot reconstructed costates and Hamiltonian |
| `validation` | `true` | Plot propagation comparison and errors |
| `auxiliaryFunction` | no-op/message callback | One-input custom function receiving `solution` |

## `raptor.api.config.CollocationConfig`

This object is accessed as `phase.collocation` before building.

| Property | Default | Supported values |
| --- | --- | --- |
| `interpolant` | `"Lagrange"` | `"Lagrange"`, `"Birkhoff_a"`, `"Birkhoff_b"` |
| `polynomials` | `"Legendre"` | `"Legendre"`, `"Chebyshev"` |
| `nodes` | `"Gauss-Lobatto"` | `"Gauss"`, `"Gauss-Radau"`, `"Gauss-Lobatto"`, `"flipped-Gauss-Radau"` |
| `nNodes` | `10` | integer |
| `timeDilation` | `"affine"` | `"affine"` |
| `dynamicsTolerance` | `0` | scalar |
| `interpolationMethod` | `"linear"` | `"linear"`, `"nearest"`, `"next"`, `"previous"`, `"spline"`, `"pchip"`, `"cubic"`, `"makima"` |

The internal method identifier is rebuilt when `interpolant`, `polynomials`, or `nodes` changes. Use exact spelling and case. Supported property values can exceed the set of combinations implemented by core collocation classes; prefer combinations exercised by supplied examples.
