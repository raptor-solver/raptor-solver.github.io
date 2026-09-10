# Third-party NLP solvers

RAPTOR transcribes the continuous problem but delegates the NLP solve to an external backend. The public selection point is:

```matlab
problem.config.solver.method = "Ipopt";  % or "Snopt", "Worhp"
```

Assign the method before changing `problem.config.solver.settings`, because selecting a method creates a new settings object for that backend.

## IPOPT

IPOPT is the default and is bundled in the RAPTOR repository through the `mexIPOPT` MATLAB interface. It is the recommended first installation check because it does not require a commercial license.

```matlab
problem.config.solver.method = "Ipopt";
problem.config.solver.tol = 1e-8;
problem.config.solver.iter_limit = 3000;

problem.config.solver.settings.parameters_mu_strategy = "adaptive";
problem.config.solver.settings.output_print_level = 5;
```

If MATLAB reports that the MEX-file is invalid or cannot load a dependent library, verify the platform and architecture of the bundled binary and preserve the entire loader message.

## SNOPT

SNOPT requires a separate installation, a valid license, and a MATLAB interface visible on the MATLAB path. Confirm the vendor interface independently before selecting it in RAPTOR.

```matlab
problem.config.solver.method = "Snopt";
problem.config.solver.tol = 1e-8;
problem.config.solver.settings.iterations_limit = 100000;
problem.config.solver.settings.major_print_level = 1;
```

The generic `iter_limit` and `tol` are translated by the RAPTOR adapter. The settings object also exposes SNOPT-specific limits and print controls.

## WORHP

WORHP requires a separate installation and license. The RAPTOR adapter also needs a WORHP parameter XML file:

```matlab
problem.config.solver.method = "Worhp";
problem.config.solver.tol = 1e-8;
problem.config.solver.settings.license_file = "C:\path\to\worhp.lic";
problem.config.solver.settings.parameters_file = "C:\path\to\worhp_raptor.xml";
problem.config.solver.settings.algorithm = "SQP";  % or "IP"
```

At solve time the current adapter copies the selected license and parameter files into MATLAB's current directory, updates the parameter file, and later attempts to remove the copies. Run from a directory where you have write permission and avoid naming unrelated files identically.

## Choosing a backend

Start with IPOPT to verify the model and installation. A different backend can be useful for comparison or because its algorithm and licensing fit a particular project, but changing solvers does not repair an inconsistent model, bad derivatives, or a poor initial guess.

When comparing solvers, keep the continuous formulation, collocation grid, scaling, and derivative method fixed. Record at least:

- termination status;
- objective value;
- constraint violation and optimality measures reported by the solver;
- iteration and solve time where the adapter provides them;
- independent trajectory-validation error.

Solver-specific options and defaults are summarized in the [Configuration API](../api-reference/configuration.md).
