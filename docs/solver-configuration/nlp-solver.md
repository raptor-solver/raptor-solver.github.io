# NLP solver

Select a backend after building the problem:

```matlab
problem.config.solver.method = "Ipopt";
problem.config.solver.tol = 1e-8;
problem.config.solver.iter_limit = 3000;
```

Supported method strings are `"Ipopt"`, `"Snopt"`, and `"Worhp"`. External setup is described in [Third-Party Integrations](../getting-started/third-party-integrations.md).

## Generic options

| Property | Default | Meaning |
| --- | --- | --- |
| `method` | `"Ipopt"` | NLP backend |
| `tol` | `1e-6` | Main optimality/convergence tolerance passed by the adapter |
| `iter_limit` | `3000` | Generic maximum iteration count |
| `settings` | backend-specific | Additional solver controls |

Choose `tol` together with derivative accuracy, scaling, collocation resolution, and validation requirements. A tolerance far below the noise in numerical derivatives rarely improves the trajectory.

## IPOPT settings

Frequently useful fields include:

```matlab
problem.config.solver.method = "Ipopt";
problem.config.solver.settings.termination_wall_time = 3600;
problem.config.solver.settings.parameters_mu_strategy = "adaptive";
problem.config.solver.settings.output_print_level = 5;
problem.config.solver.settings.output_print_options = "no";
```

The settings object also exposes primary and acceptable tolerances for dual infeasibility, constraint violation, complementarity, and objective change. Change these only with reference to IPOPT's termination semantics.

## SNOPT settings

```matlab
problem.config.solver.method = "Snopt";
problem.config.solver.settings.minor_iterations_limit = 100000;
problem.config.solver.settings.iterations_limit = 100000;
problem.config.solver.settings.feasibility_tolerance = 1e-8;
problem.config.solver.settings.major_print_level = 1;
problem.config.solver.settings.minor_print_level = 1;
```

In the current release, the SNOPT adapter hard-codes both print levels to `1`; the exposed print fields are retained in the settings class but do not yet affect the solve. Leaving `feasibility_tolerance` at its `1e-16` sentinel makes the adapter use twice the generic `problem.config.solver.tol`.

## WORHP settings

```matlab
problem.config.solver.method = "Worhp";
problem.config.solver.settings.algorithm = "SQP"; % or "IP"
problem.config.solver.settings.Timeout = 3600;
problem.config.solver.settings.TolFeas = 1e-8;
problem.config.solver.settings.NLPprint = 1;
```

WORHP also exposes acceptable tolerances, Hessian-approximation choices, finite-difference settings, and license/parameter file paths.

## Read the termination output

Do not treat a returned structure as proof of convergence. Inspect:

```matlab
solution.exitStatus
solution.objective
solution.nIterations
solution.solveTime
```

Then read the backend's command-window termination message. Some adapter fields are not equally informative for every backend—for example, unavailable iteration or timing data may be represented by `Inf` or `NaN` in the current release.

After successful NLP termination, validate the continuous trajectory independently. A tightly converged discretized NLP may still have significant collocation error.
