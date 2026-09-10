# Problem object

Create the top-level continuous problem with:

```matlab
ocp = raptor.api.v1.OptimalControlProblem(name, auxdata, nGlobalParameters);
```

`name` identifies the problem, `auxdata` contains fixed data passed to every user function, and `nGlobalParameters` is the number of static optimization variables shared across phases.

## Auxiliary data

Use a scalar structure to organize constants, reference data, environment models, and settings required by callbacks:

```matlab
auxdata.vehicle.mass = 1200;
auxdata.environment.g = 9.80665;
auxdata.target.position = [10; 0; 0];

ocp = raptor.api.v1.OptimalControlProblem("transfer", auxdata, 0);
```

Access it inside a callback through `inputData.auxdata`. Do not place a quantity in `auxdata` if the optimizer must vary it.

## Global parameters

Global parameters are static decision variables shared by the full problem. Declare their count in the constructor, then provide guess, bounds, and optional metadata on `ocp`:

```matlab
ocp = raptor.api.v1.OptimalControlProblem("parameterized", auxdata, 2);

ocp.initialGuess.globalParameters = [1.0; 0.2];
ocp.box.lower.globalParameters = [0.0; -1.0];
ocp.box.upper.globalParameters = [5.0;  1.0];

ocp.metadata.name.globalParameters = ["thrust scale"; "bias"];
ocp.metadata.unit.globalParameters = ["-"; "m/s^2"];
ocp.metadata.label.globalParameters = ["s_T"; "b"];
```

Callbacks access them with `inputData.globalParameters`. Use column vectors for guesses, bounds, and metadata, preserve the declared ordering, and use linear indexing in callbacks so code does not depend on the evaluation-time orientation of the parameter vector.

## Add phases

```matlab
phase = ocp.addPhase(phaseName, nStates, nControls, nLocalParameters);
```

The returned handle is the main surface used to define a phase. The phase is also stored in `ocp.phases` in creation order.

## Link phases

Multi-phase relations are attached to `ocp.linkage`. For identical state representations, use:

```matlab
ocp.linkage.continuity(phase1, phase2);
```

For a custom relation, create a named linkage with `stack` and add a boundary callback. See [Linkage Conditions](linkage-conditions.md).

## Build semantics

```matlab
problem = raptor.build(ocp);
```

The build converts the API objects into RAPTOR's internal descriptors, evaluates callbacks on the initial guess, estimates missing derivative patterns, and creates default numerical configuration. It is a snapshot: subsequent changes to `ocp` or a phase do not update `problem`.
