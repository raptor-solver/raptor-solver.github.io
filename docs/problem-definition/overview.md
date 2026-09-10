# Defining an optimal-control problem

RAPTOR represents a problem as a top-level `raptor.api.v1.OptimalControlProblem` containing one or more phase objects. A phase owns its variables, dynamics, constraints, objective terms, endpoint data, initial guess, metadata, and collocation grid.

## Recommended definition order

1. Write the mathematical formulation and fix the component ordering.
2. Put constants and non-optimized data in `auxdata`.
3. Create the problem and phases.
4. Add metadata so plots and result inspection remain readable.
5. Register dynamics, constraints, and costs.
6. Set fixed endpoint values and box bounds.
7. Provide and build an initial guess.
8. Configure collocation for every phase.
9. Add linkage conditions after the upstream phase guess has been built.
10. Call `raptor.build`.

The examples sometimes vary this ordering where convenient, but bounds and endpoint values should normally be settled before calling an initial-guess builder.

## Minimal structure

```matlab
auxdata.g = 9.80665;
ocp = raptor.api.v1.OptimalControlProblem("example", auxdata, 0);
phase = ocp.addPhase("flight", 3, 1, 0);

phase.dynamics.add(@flightDynamics);
phase.costs.mayer.add(@(data) data.finalTime);

phase.boundaryConditions.initial.time = 0;
phase.boundaryConditions.initial.states = [0; 0; 0];
phase.boundaryConditions.final.states(1:2) = [10; 10];

phase.box.lower.finalTime = 0.1;
phase.box.upper.finalTime = 10;
phase.box.lower.controls = 0;
phase.box.upper.controls = pi/2;

phase.initialGuess.final.time = 2;
phase.initialGuess.final.states = [10; 10; 20];
phase.initialGuess.continuous.controls = 0.5;
phase.initialGuess.linear();

phase.collocation.nodes = "Gauss-Radau";
phase.collocation.nNodes = 40;

problem = raptor.build(ocp);
```

## Formulation checklist

Before building, verify:

- every phase has a unique valid MATLAB identifier as its name;
- every callback accepts exactly one `inputData` argument;
- path callbacks support multiple columns and return the correct row count;
- lower and upper constraint vectors have the same component order as the callback output;
- fixed boundary values lie inside their box bounds;
- all state and control rows in the guess have the same time-grid length;
- every phase has dynamics and a built initial guess;
- local and global parameter guesses and bounds are populated when their counts are nonzero;
- every phase has a supported collocation combination.

The following pages describe each element. Exact method contracts are collected in [Problem and Phase API](../api-reference/problem-and-phase.md) and [Functions and Constraints API](../api-reference/functions-and-constraints.md).
