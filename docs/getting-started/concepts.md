# Concepts and conventions

## Continuous model and transcribed NLP

You define a continuous-time optimal-control problem. RAPTOR applies a pseudospectral transcription and sends the resulting finite-dimensional nonlinear program (NLP) to IPOPT, SNOPT, or WORHP.

The stages are deliberately separate:

- `raptor.api.v1.OptimalControlProblem` and its phases describe the continuous formulation.
- `raptor.build(ocp)` checks and freezes that formulation into a `raptor.RAPTOR` solver object.
- `problem.config` controls transcription, scaling, numerical derivatives, the NLP backend, and postprocessing.
- `problem.solve()` returns solver information and phase-indexed trajectories.

Changing `ocp` after `raptor.build` does not change the already built `problem`; rebuild whenever the continuous formulation changes.

## Phases

A phase is one time interval with a fixed number and ordering of states, controls, and local parameters. Use multiple phases when a known event changes the equations, dimensions, active constraints, or operating regime. Link phases explicitly with continuity or a custom endpoint relation.

Phase names must be unique and valid MATLAB property names because RAPTOR uses them as fields in the returned solution:

```matlab
ascent = ocp.addPhase("ascent", 7, 4, 0);
% Later: solution.ascent.discretized.states
```

## Variable families

| Quantity | Varies with time | Scope | Typical access in a path function |
| --- | --- | --- | --- |
| Time | yes | phase | `inputData.time` |
| States | yes | phase | `inputData.states` |
| Controls | yes | phase | `inputData.controls` |
| Local parameters | no | one phase | `inputData.localParameters` |
| Global parameters | no | all phases | `inputData.globalParameters` |
| Auxiliary data | no, never optimized | problem | `inputData.auxdata` |

Optimization variables belong in a state, control, local parameter, or global parameter—not in `auxdata`. RAPTOR treats auxiliary data as constant and does not differentiate with respect to it.

Define parameter guesses and bounds as vectors with one entry per declared parameter. Current transcribed callback evaluations expose local and global parameters as row vectors; use linear indexing unless your function deliberately depends on orientation.

## Component-by-time array convention

Time-dependent quantities use one row per component and one column per evaluation time. If a phase has `nx` states, `nu` controls, and a path function is evaluated at `N` points:

- `inputData.time` is `1 x N`;
- `inputData.states` is `nx x N`;
- `inputData.controls` is `nu x N`;
- dynamics must return `nx x N`;
- a path constraint with `ng` components must return `ng x N`;
- a scalar Lagrange term must return `1 x N`.

Use element-wise operators in path functions:

```matlab
speed = sqrt(sum(inputData.states(4:6, :).^2, 1));
```

Avoid code that happens to work only for `N == 1`. RAPTOR evaluates functions both on individual points and batches of points during building, differentiation, transcription, and postprocessing.

## Path and boundary callbacks

Path callbacks—dynamics, Lagrange terms, path constraints, and differential constraints—use `time`, `states`, `controls`, `localParameters`, `globalParameters`, and `auxdata`.

Boundary callbacks—Mayer terms, boundary constraints, and linkage constraints—use endpoint fields:

```text
initialTime       finalTime
initialStates     finalStates
initialControls   finalControls
localParameters   globalParameters
upstreamParameters (linkages)
auxdata
```

For a custom linkage, `final*` describes the upstream/first phase and `initial*` describes the downstream/second phase. `upstreamParameters` belongs to the first phase, while `localParameters` belongs to the second phase.

## Bounds, fixed values, and general constraints

These mechanisms are related but not interchangeable:

- `phase.box.lower` and `.upper` bound variables throughout their domain.
- `phase.boundaryConditions.initial` and `.final` fix selected endpoint values.
- `phase.constraints.boundary` represents general endpoint equations and inequalities.

Unspecified fixed boundary components remain `NaN` internally and are free. Unspecified box bounds default to `-Inf` and `Inf`.

## Names and indexing

RAPTOR preserves the component order declared by your model. Keep a short table in the model script or metadata, and use the same order in:

- functions;
- bounds and boundary values;
- initial guesses;
- Jacobian patterns or values;
- solution postprocessing.

Named constraint groups become dynamic properties and solution fields. Use concise valid MATLAB identifiers such as `dynamicPressure`, not labels containing spaces or punctuation.

## Build success, solver success, and validation

These are three different claims:

1. **Build success** means the formulation passed RAPTOR's construction and dimension checks.
2. **Solver success** means the selected NLP adapter recognized a successful termination.
3. **Validation success** means independent numerical propagation agrees sufficiently with the collocation solution for your application.

Accept a result only after checking all three, plus the original physical constraints and units.
