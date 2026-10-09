# Bounds and Boundary Conditions

RAPTOR provides three ways to restrict variables:

| Mechanism | Restricts | Use it for |
| --- | --- | --- |
| `boundaryConditions` | one endpoint value, fixed exactly | known initial or final time, state or control |
| `box` | a variable everywhere it appears | physical limits, search region |
| `constraints.boundary` | a function of the endpoints | derived, coupled or inequality endpoint conditions, see [Constraints](constraints.md) |

## Boundary conditions

Fix selected endpoint components directly:

```matlab
phase.boundaryConditions.initial.time   = 0;
phase.boundaryConditions.initial.states = [0; 0; 0];
phase.boundaryConditions.final.states(1:2) = [10; 10];
```

Components you do not assign stay free (they are stored as `NaN`). Above,
the third final state is free. The available fields are `time`, `states` and
`controls` under both `initial` and `final`.

### Fixed or free final time

=== "Fixed time"

    ```matlab
    phase.boundaryConditions.initial.time = 0;
    phase.boundaryConditions.final.time   = 11;
    ```

=== "Free final time"

    Leave the final time unset, and set bounds and a guess for it:

    ```matlab
    phase.boundaryConditions.initial.time = 0;
    phase.box.lower.finalTime = 0.1;
    phase.box.upper.finalTime = 5;
    phase.initialGuess.final.time = 2;
    ```

The [initial guess](initial-guess.md) builders use the boundary conditions,
so set the boundary conditions first.

## Box bounds

Lower and upper bounds per component. Unset bounds default to `-Inf` and
`Inf`.

```matlab
phase.box.lower.initialTime = 0;     phase.box.upper.initialTime = 10;
phase.box.lower.finalTime   = 20;    phase.box.upper.finalTime   = 100;

phase.box.lower.states   = [-100; -50];
phase.box.upper.states   = [ 100;  50];
phase.box.lower.controls = -5;
phase.box.upper.controls =  5;

phase.box.lower.localParameters = 0;
phase.box.upper.localParameters = 1;
```

Global-parameter bounds live on the problem: `ocp.box.lower.globalParameters`
and `ocp.box.upper.globalParameters`.

!!! tip "Fixing a value over the whole phase"
    To fix an endpoint value, use `boundaryConditions`. Equal lower and upper
    box bounds fix a variable over the whole phase, for example a zero
    control during a coast phase:

    ```matlab
    coast.box.lower.controls = [0; 0];
    coast.box.upper.controls = [0; 0];
    ```

### Choosing good bounds

- Use finite, physically meaningful bounds when they are known. They reduce
  the search space and are needed for bounds-based
  [scaling](numerical-setup.md#scaling).
- Do not tighten bounds only to obtain convergence. This can hide modelling
  errors or exclude the optimal solution.
- Keep fixed endpoint values and the initial guess inside the bounds.
- Use [path constraints](constraints.md) for nonlinear limits such as norms
  or dynamic pressure.
