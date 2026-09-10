# Phase

A phase models one continuous time interval with fixed state, control, and local-parameter dimensions.

```matlab
phase = ocp.addPhase("ascent", 7, 4, 1);
```

This creates seven states, four controls, and one local parameter. The name `ascent` later becomes the field `solution.ascent`.

## What a phase contains

| Property | Purpose |
| --- | --- |
| `metadata` | Names, labels, and units for variables and plots |
| `dynamics` | Additive state-derivative terms |
| `costs.mayer` | Additive endpoint objective terms |
| `costs.lagrange` | Additive integral objective terms |
| `constraints.path` | Algebraic constraints along the phase |
| `constraints.differential` | Bounds on derivatives of registered quantities |
| `constraints.boundary` | General endpoint constraints |
| `boundaryConditions` | Directly fixed endpoint variables |
| `box` | Component-wise variable bounds |
| `initialGuess` | Initial, final, and continuous guess data |
| `collocation` | Pseudospectral discretization settings |

## When to create another phase

Use a new phase at a known event where one or more of the following changes:

- state or control dimension;
- dynamics or active constraints;
- control authority or physical regime;
- coordinate representation;
- a discrete jump, separation, or staging condition.

Do not split a smooth trajectory merely to add grid points; increase `nNodes` instead. Every phase adds endpoint variables and usually needs an explicit linkage to adjacent phases.

## Metadata

Metadata does not change the optimization problem, but it controls automatic plot readability:

```matlab
phase.metadata.name.time = "time";
phase.metadata.label.time = "t";
phase.metadata.unit.time = "s";

phase.metadata.name.states = ["position"; "velocity"];
phase.metadata.label.states = ["x"; "v"];
phase.metadata.unit.states = ["m"; "m/s"];

phase.metadata.name.controls = "acceleration";
phase.metadata.label.controls = "u";
phase.metadata.unit.controls = "m/s^2";
```

Provide exactly one entry per component. RAPTOR supplies generic defaults if metadata is omitted.

## Local parameters

Local parameters are static within one phase and accessed as `inputData.localParameters`. They are useful for phase-specific optimized quantities such as a peak value or constant bias:

```matlab
phase.initialGuess.continuous.localParameters = 70;
phase.box.lower.localParameters = 0;
phase.box.upper.localParameters = 100;
```

They are not time histories; use states or controls for time-varying decision variables.
