# Boundary conditions

Boundary conditions directly fix selected time, state, or control components at the beginning or end of a phase.

```matlab
phase.boundaryConditions.initial.time = 0;
phase.boundaryConditions.initial.states = [0; 0; 0];
phase.boundaryConditions.final.states(1:2) = [10; 10];
```

Fields that are not assigned remain `NaN` and are free. In the example, final state component 3 is not fixed.

## Available fields

```text
phase.boundaryConditions.initial.time
phase.boundaryConditions.initial.states
phase.boundaryConditions.initial.controls

phase.boundaryConditions.final.time
phase.boundaryConditions.final.states
phase.boundaryConditions.final.controls
```

Time is scalar. State and control values contain one entry per declared component.

## Fixed time and free time

For a fixed-time phase, assign its endpoint time directly:

```matlab
phase.boundaryConditions.initial.time = 0;
phase.boundaryConditions.final.time = 11;
```

For a free final time, leave the final boundary value unset, bound it, and provide a guess:

```matlab
phase.box.lower.finalTime = 0.1;
phase.box.upper.finalTime = 5;
phase.initialGuess.final.time = 2;
```

## When to use a boundary constraint

Use `boundaryConditions` for a direct equality on one variable component. Use a [boundary constraint](boundary-constraints.md) when the endpoint condition:

- combines multiple components;
- relates initial and final values;
- is an inequality or interval;
- is most naturally expressed by a user function.

## Consistency

A fixed value must be compatible with its box bounds and with every general boundary or linkage constraint. Boundary conditions also provide endpoint data to `initialGuess.linear()` and `initialGuess.fromControl()`, so set them before constructing the guess.
