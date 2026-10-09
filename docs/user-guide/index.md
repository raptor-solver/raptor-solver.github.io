# User Guide

This guide explains how to define a problem in RAPTOR, solve it, and check
the result. Each page covers one part of the problem definition or solution
process. The pages assume you have read [Core Concepts](../getting-started/concepts.md).

## Anatomy of a RAPTOR script

The examples in the repository follow the order below. Click a numbered
marker to see which page describes that step.

```matlab
auxdata.g = 9.80665;                                          % (1)!
ocp   = raptor.api.v1.OptimalControlProblem("glide", auxdata, 0);
phase = ocp.addPhase("flight", 3, 1, 0);                      % (2)!

phase.dynamics.add(@flightDynamics);                          % (3)!
phase.costs.mayer.add(@(d) d.finalTime);

phase.boundaryConditions.initial.time   = 0;                  % (4)!
phase.boundaryConditions.initial.states = [0; 0; 0];
phase.box.lower.finalTime = 0.1;
phase.box.upper.finalTime = 10;

phase.constraints.path.stack("slope", -Inf, 0.5);             % (5)!
phase.constraints.path.slope.add(@slopeConstraint);

phase.initialGuess.final.time = 2;                            % (6)!
phase.initialGuess.final.states = [10; 10; 20];
phase.initialGuess.continuous.controls = 0.5;
phase.initialGuess.linear();

phase.collocation.nodes  = "Gauss-Radau";                     % (7)!
phase.collocation.nNodes = 40;

problem = raptor.build(ocp);                                  % (8)!
problem.config.scaling.method = "BoundsProjection";
sol = problem.solve();                                        % (9)!
```

1.  Constants used by the functions: [Problems and Phases](problems-and-phases.md).
2.  Name, number of states, controls and local parameters:
    [Problems and Phases](problems-and-phases.md).
3.  [Dynamics and Costs](dynamics-and-costs.md); the functions are
    [vectorized](../getting-started/vectorized-functions.md).
4.  [Bounds and Boundary Conditions](bounds-and-boundary-conditions.md).
5.  [Constraints](constraints.md).
6.  [Initial Guess](initial-guess.md).
7.  [Collocation](collocation.md).
8.  [Numerical Setup](numerical-setup.md) and [NLP Solvers](nlp-solvers.md).
9.  [Solution and Validation](results.md).

## Contents

<div class="rp-cards" markdown>

<div class="rp-card rp-card--link" markdown>
[:material-vector-polyline: Problems and Phases](problems-and-phases.md)
{ .rp-card__title }

The top-level problem, auxiliary data, parameters, phases and metadata.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-function-variant: Dynamics and Costs](dynamics-and-costs.md)
{ .rp-card__title }

State derivatives, Mayer and Lagrange terms, additive models.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-matrix: Vectorized Functions](../getting-started/vectorized-functions.md)
{ .rp-card__title }

How to write model functions for many time instants at once.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-arrow-collapse-horizontal: Bounds and Boundary Conditions](bounds-and-boundary-conditions.md)
{ .rp-card__title }

Fixed endpoints, free final time and box bounds.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-vector-curve: Constraints](constraints.md)
{ .rp-card__title }

Path, differential and boundary constraints.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-chart-timeline-variant: Initial Guess](initial-guess.md)
{ .rp-card__title }

Linear interpolation, integration of the dynamics, or a full profile.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-chart-bell-curve-cumulative: Collocation](collocation.md)
{ .rp-card__title }

Pseudospectral method, number of nodes and hp grids.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-source-branch: Multi-Phase Problems](multi-phase.md)
{ .rp-card__title }

Linkage constraints between phases.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-tune-variant: Numerical Setup](numerical-setup.md)
{ .rp-card__title }

Derivatives and scaling.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-swap-horizontal: NLP Solvers](nlp-solvers.md)
{ .rp-card__title }

IPOPT, SNOPT and WORHP.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-check-decagram: Solution and Validation](results.md)
{ .rp-card__title }

Solution structure, plots and accuracy checks.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-bug-outline: Troubleshooting](troubleshooting.md)
{ .rp-card__title }

Common errors and how to find their cause.
</div>

</div>
