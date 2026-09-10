# RAPTOR

**R**apid **A**lgorithm for **P**seudospectral **T**rajectory **O**ptimization and **R**obustification is an object-oriented MATLAB toolbox for transcribing and solving continuous-time optimal-control problems with pseudospectral methods.

RAPTOR separates the continuous problem definition from the numerical choices used to solve it. You describe phases, variables, dynamics, constraints, objectives, bounds, and an initial guess; RAPTOR then builds a nonlinear program, calls a supported NLP solver, and reconstructs primal, dual, and validation results.

!!! warning "Version and stability"
    This documentation describes the MATLAB interface distributed with RAPTOR user manual **0.1.0 (June 2026)**. RAPTOR is under active development, so check the release you are using before reusing a formulation created for another version.

## Where to begin

- New users should complete [Installation](getting-started/installation.md) and then follow the [Quickstart](getting-started/quickstart.md).
- To translate a mathematical problem into RAPTOR objects, start with [Defining Your Problem](problem-definition/overview.md).
- To tune differentiation, scaling, transcription, and the NLP backend, see [Configuring Your Solver](solver-configuration/configuring-your-solver.md).
- To inspect convergence and continuous-time accuracy, see [Analyzing Results](analyzing-results/solution.md).
- When you know the operation you need and want its exact contract, use the [API Reference](api-reference/overview.md).

## The RAPTOR workflow

1. Write the continuous formulation and choose the state, control, and parameter ordering.
2. Create a `raptor.api.v1.OptimalControlProblem` and add one or more phases.
3. Define functions, bounds, boundary values, an initial guess, and a collocation grid.
4. Call `raptor.build` to validate and freeze the formulation into a solver object.
5. Configure transcription, scaling, differentiation, the NLP solver, validation, and plotting.
6. Call `problem.solve()` and check both the solver status and the independently propagated trajectory.

```matlab
ocp = raptor.api.v1.OptimalControlProblem("myProblem", auxdata, 0);
phase = ocp.addPhase("flight", nStates, nControls, 0);

% Define the phase here.

problem = raptor.build(ocp);
problem.config.solver.method = "Ipopt";
solution = problem.solve();
```

## What RAPTOR provides

- A phase-based problem-definition API suitable for single- and multi-phase problems.
- Mayer and Lagrange objective terms.
- Path, boundary, differential, and linkage constraints.
- Lagrange and Birkhoff pseudospectral formulations with several node families.
- Numerical Jacobians using central, complex-step, or dual-step differences.
- Composable scaling methods.
- Interfaces for IPOPT, SNOPT, and WORHP.
- Automatic primal, dual, and numerical-validation postprocessing.

RAPTOR is released under the MIT License. The toolbox assumes familiarity with MATLAB and basic optimal-control terminology; the documentation focuses on using the software rather than deriving the numerical methods.
