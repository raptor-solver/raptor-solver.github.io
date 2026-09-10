# API reference

This reference covers the user-facing surface needed to define and solve RAPTOR problems. It does not catalogue internal builders, core descriptors, logging utilities, or validation helpers.

## Main entry points

| Name | Purpose |
| --- | --- |
| `raptor.api.v1.OptimalControlProblem` | Create a continuous optimal-control problem |
| `ocp.addPhase` | Add and dimension a phase |
| `phase.dynamics.add` | Register an additive dynamics term |
| `*.stack` | Declare a named constraint group and its bounds |
| `constraint.add` | Register an additive constraint term |
| `phase.costs.mayer.add` | Register an endpoint objective term |
| `phase.costs.lagrange.add` | Register a running objective term |
| `phase.initialGuess.linear` | Build a linearly interpolated guess |
| `phase.initialGuess.fromControl` | Propagate a guess from controls |
| `ocp.linkage.continuity` | Link compatible phases continuously |
| `raptor.build` | Convert the API model into a solver object |
| `problem.solve` | Transcribe, scale, solve, and postprocess |

RAPTOR uses MATLAB package qualification. Do not shorten the constructor to `OptimalControlProblem` unless you have explicitly imported it:

```matlab
ocp = raptor.api.v1.OptimalControlProblem("name", auxdata, 0);
```

Configuration types are under `raptor.api.config`, for example `raptor.api.config.SolverConfig`. Users normally receive them through `problem.config` rather than constructing them directly.

## Object hierarchy

```text
raptor.api.v1.OptimalControlProblem (ocp)
├── phases
├── initialGuess / box / metadata       global parameters
├── linkage                            relations between phases
└── raptor.api.v1.Phase (from addPhase)
    ├── boundaryConditions
    ├── initialGuess / box / metadata
    ├── dynamics
    ├── costs.mayer / costs.lagrange
    ├── constraints.path
    ├── constraints.differential
    ├── constraints.boundary
    └── collocation

raptor.build(ocp) -> raptor.RAPTOR (problem)
├── config
│   ├── transcription
│   ├── scaling
│   ├── solver
│   └── postprocessing
└── solve() -> solution struct
```

## Mutation and lifecycle

The API model is composed largely of handle objects. Assignments modify the object in place:

```matlab
phase.box.lower.controls = -1;
```

`raptor.build(ocp)` creates a new internal representation. Changes to `ocp` afterward are not reflected in the existing `problem`. Rebuild after any continuous-model change.

Method selection in configuration is also stateful: assigning a `method` replaces its method-specific `settings`. Select first, customize second.

## Naming rules

Phase and constraint names become fields or dynamic properties. Use unique valid MATLAB identifiers. Prefer strings such as `"dynamicPressure"`; avoid spaces, hyphens, or names that collide with existing properties.

## Version scope

The API is explicitly versioned under `raptor.api.v1`. This reference describes the source supplied alongside the June 2026 version 0.1.0 manual. Fully qualified names are shown so version changes remain visible in user code.
