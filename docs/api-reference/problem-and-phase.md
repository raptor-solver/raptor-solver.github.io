# Problem and phase API

## `raptor.api.v1.OptimalControlProblem`

Creates the user-facing representation of a continuous problem.

```matlab
ocp = raptor.api.v1.OptimalControlProblem(name, auxdata, nGlobalParameters)
```

### Inputs

| Input | Expected value | Description |
| --- | --- | --- |
| `name` | text scalar | Descriptive problem name |
| `auxdata` | any fixed data, normally a scalar struct | Passed unchanged to user callbacks |
| `nGlobalParameters` | nonnegative integer | Number of problem-wide static decision variables |

### Relevant properties

| Property | Description |
| --- | --- |
| `name` | Problem name |
| `auxdata` | Fixed callback data |
| `phases` | Phase handles in creation order |
| `nGlobalParameters` | Declared global-parameter count |
| `initialGuess.globalParameters` | Global-parameter starting values |
| `box.lower.globalParameters` | Lower global-parameter bounds; defaults to `-Inf` |
| `box.upper.globalParameters` | Upper global-parameter bounds; defaults to `Inf` |
| `metadata.name/unit/label.globalParameters` | Plot and display metadata |
| `linkage` | Multi-phase constraint collection |

`auxdata` is not an optimization variable. If its value should change during the solve, declare a local or global parameter instead.

### Example

```matlab
auxdata.mu = 3.986004418e14;
ocp = raptor.api.v1.OptimalControlProblem("orbitTransfer", auxdata, 1);
ocp.initialGuess.globalParameters = 1;
ocp.box.lower.globalParameters = 0.5;
ocp.box.upper.globalParameters = 2;
```

## `addPhase`

Creates a phase, appends it to the problem, and returns its handle.

```matlab
phase = ocp.addPhase(phaseName, nStates, nControls, nLocalParameters)
```

| Input | Description |
| --- | --- |
| `phaseName` | Unique valid MATLAB identifier; becomes a solution field |
| `nStates` | Number of state components |
| `nControls` | Number of control components |
| `nLocalParameters` | Number of static parameters owned by this phase |

The method also gives the phase the problem's global-parameter dimension. Define phases through `addPhase`; do not normally call `raptor.api.v1.Phase` directly because the problem reference and phase index are established by this method.

## `raptor.api.v1.Phase`

The phase object returned by `addPhase` exposes the following user-facing properties.

### Dimensions and identity

```text
name, idx, nStates, nControls, nLocalParameters, nGlobalParameters
```

Treat these as descriptive values after construction. Recreate the phase if dimensions change.

### Boundary conditions

```text
phase.boundaryConditions.initial.time
phase.boundaryConditions.initial.states
phase.boundaryConditions.initial.controls
phase.boundaryConditions.final.time
phase.boundaryConditions.final.states
phase.boundaryConditions.final.controls
```

Time is scalar; state/control data is one value per component. Defaults are `NaN`, meaning not fixed.

### Box bounds

```text
phase.box.lower.initialTime / finalTime
phase.box.lower.states / controls / localParameters
phase.box.upper.initialTime / finalTime
phase.box.upper.states / controls / localParameters
```

Defaults are infinite. Bounds use the declared component order.

### Initial guess data

The `initial`, `final`, and `continuous` members each expose:

```text
time, states, controls, localParameters
```

`initial` and `final` provide endpoint fallbacks. `continuous` stores the complete guess used by `raptor.build` after a builder has run.

## `initialGuess.linear`

```matlab
phase.initialGuess.linear()
```

Builds two-point, linearly varying state and control profiles. For each endpoint it prefers a fixed boundary condition, then the matching endpoint guess, then an existing continuous endpoint. Time, every state, every control, and every local parameter must be defined through those sources.

The method mutates `phase.initialGuess.continuous` and may only be used once on the same phase.

## `initialGuess.fromControl`

```matlab
phase.initialGuess.fromControl()
```

Builds a dynamically propagated state guess with `ode45` using the registered dynamics and continuous control guess.

Required before the call:

- initial time and states;
- final time;
- one or more dynamics terms;
- complete control data;
- all local parameters when present.

The control history is interpolated with `pchip`. A one-column control is constant. A two-column time grid can be expanded to match longer control data, and a two-column control can be interpolated over a longer time grid. The result is a guess, not a feasibility certificate.

## Metadata

```text
phase.metadata.name.time/states/controls/localParameters
phase.metadata.unit.time/states/controls/localParameters
phase.metadata.label.time/states/controls/localParameters
```

RAPTOR supplies generic names such as `state 1` and dimensionless units. Assign one string per component for useful plots.

## Collocation properties

The `phase.collocation` object is a `raptor.api.config.CollocationConfig`. Its properties and defaults are listed in the [Configuration API](configuration.md#raptorapiconfigcollocationconfig).
