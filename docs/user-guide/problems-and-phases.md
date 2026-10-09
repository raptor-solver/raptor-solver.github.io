# Problems and Phases

## The problem object

```matlab
ocp = raptor.api.v1.OptimalControlProblem(name, auxdata, nGlobalParameters);
```

- `name` identifies the problem.
- `auxdata` is a structure of fixed data passed to every function as
  `inputData.auxdata`.
- `nGlobalParameters` is the number of static decision variables shared by
  all phases (often `0`).

### Auxiliary data

Use `auxdata` for constants, vehicle and environment data, and reference
values:

```matlab
auxdata.vehicle.mass     = 1200;
auxdata.environment.g    = 9.80665;
auxdata.target.position  = [10; 0; 0];

ocp = raptor.api.v1.OptimalControlProblem("transfer", auxdata, 0);
```

Quantities that the optimizer can change must be states, controls or
parameters, not `auxdata`.

### Global parameters

Global parameters are constant in time and shared by every phase. Declare how
many there are in the constructor, then give them a guess, bounds and,
optionally, metadata:

```matlab
ocp = raptor.api.v1.OptimalControlProblem("parameterized", auxdata, 2);

ocp.initialGuess.globalParameters = [1.0; 0.2];
ocp.box.lower.globalParameters    = [0.0; -1.0];
ocp.box.upper.globalParameters    = [5.0;  1.0];
```

Read them in your functions with `inputData.globalParameters`, using linear
indexing (`inputData.globalParameters(2)`) so the code does not depend on the
vector's orientation.

## Phases

```matlab
phase = ocp.addPhase(phaseName, nStates, nControls, nLocalParameters);
```

All properties of the phase are set through the returned object. Phases are
stored in `ocp.phases` in the order they are created.

| Property | What it holds | Page |
| --- | --- | --- |
| `dynamics` | state derivative terms | [Dynamics and Costs](dynamics-and-costs.md) |
| `costs.mayer`, `costs.lagrange` | endpoint and running cost terms | [Dynamics and Costs](dynamics-and-costs.md) |
| `boundaryConditions` | fixed endpoint values | [Bounds and Boundary Conditions](bounds-and-boundary-conditions.md) |
| `box` | lower and upper variable bounds | [Bounds and Boundary Conditions](bounds-and-boundary-conditions.md) |
| `constraints.path` / `.differential` / `.boundary` | general constraints | [Constraints](constraints.md) |
| `initialGuess` | starting trajectory | [Initial Guess](initial-guess.md) |
| `collocation` | pseudospectral method and grid | [Collocation](collocation.md) |
| `metadata` | names, labels and units for plots | below |

!!! tip "When to use more than one phase"
    Use a new phase at a known event where the dynamics, the number of
    variables, the active constraints or the coordinates change, or where a
    discontinuity such as staging occurs. To increase the resolution of a
    smooth trajectory, increase `nNodes` or use an
    [hp grid](collocation.md#hp-collocation) instead.

### Local parameters

Local parameters are optimization variables that are constant within one
phase, for example a constant bias. They are available in the functions as
`inputData.localParameters`. Set their guess and bounds as follows:

```matlab
phase.initialGuess.continuous.localParameters = 70;
phase.box.lower.localParameters = 0;
phase.box.upper.localParameters = 100;
```

### Metadata

Metadata does not affect the optimization. It sets the names, labels and
units used in the automatic plots. Give one entry per component:

```matlab
phase.metadata.name.time  = "time";
phase.metadata.label.time = "t";
phase.metadata.unit.time  = "s";

phase.metadata.name.states  = ["position"; "velocity"];
phase.metadata.label.states = ["x"; "v"];
phase.metadata.unit.states  = ["m"; "m/s"];

phase.metadata.name.controls  = "acceleration";
phase.metadata.label.controls = "u";
phase.metadata.unit.controls  = "m/s^2";
```

Global parameters have the same fields on `ocp.metadata`. Without metadata,
RAPTOR falls back to generic names.

## Building

```matlab
problem = raptor.build(ocp);
```

The build checks the problem definition, evaluates every function on the
initial guess, detects which inputs each function depends on, and creates the
default numerical settings. Later changes to `ocp` do not affect `problem`;
call `raptor.build` again after changing the problem definition.

??? info "Pre-build checklist"
    - Phase names are unique, valid MATLAB identifiers.
    - Every function takes exactly one `inputData` argument.
    - Path functions accept several time columns and return the right number
      of rows.
    - Constraint bounds and function outputs have the same length and order.
    - Fixed endpoint values sit inside their box bounds.
    - Every phase has dynamics, a built initial guess and a collocation grid.
    - Parameter guesses and bounds are set whenever the counts are non-zero.
