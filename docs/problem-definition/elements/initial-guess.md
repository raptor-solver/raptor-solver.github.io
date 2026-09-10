# Initial guess

The initial guess supplies the trajectory from which the NLP solver starts. RAPTOR stores preliminary values under `initial`, `final`, and `continuous`, then builds a complete continuous guess using `linear()` or `fromControl()`.

## Linear interpolation

```matlab
phase.initialGuess.final.time = 2;
phase.initialGuess.final.states(3) = 50;
phase.initialGuess.continuous.controls = 0.5;
phase.initialGuess.linear();
```

For each endpoint, `linear()` searches in this order:

1. a fixed `boundaryConditions` value;
2. the matching `initialGuess.initial` or `.final` value;
3. the first or last value already present in `initialGuess.continuous`.

It then creates a two-point time grid and linear state/control profiles. Every state, control, time endpoint, and local parameter must be obtainable from one of these sources.

## Propagation from a control history

`fromControl()` integrates the registered dynamics with `ode45` from the supplied initial state while interpolating the continuous control guess:

```matlab
phase.initialGuess.final.time = 20;
phase.initialGuess.continuous.time = linspace(0, 20, 21);
phase.initialGuess.continuous.controls = controlProfile;
phase.initialGuess.fromControl();
```

It requires:

- initial and final time from boundary conditions or guess endpoints;
- all initial states;
- all continuous controls;
- dynamics already registered;
- values for all local parameters.

A one-column control is treated as constant. If a two-column control is paired with a longer time grid, RAPTOR interpolates between the endpoints. If a longer control history is paired with only two time values, it is treated as equally spaced across that interval.

`fromControl()` can produce a dynamically plausible guess, but it need not satisfy final conditions or path constraints.

## Supplying a complete profile

You may assign continuous arrays directly before building the problem:

```matlab
phase.initialGuess.continuous.time = tGuess;
phase.initialGuess.continuous.states = xGuess;
phase.initialGuess.continuous.controls = uGuess;
phase.initialGuess.continuous.localParameters = pGuess;
```

The state and control matrices must have the declared number of rows and the same number of columns. RAPTOR interpolates this profile onto the selected collocation grid during `raptor.build`.

## Global parameters

Global-parameter guesses belong to the problem:

```matlab
ocp.initialGuess.globalParameters = [1.0; 0.2];
```

## Important behavior

An initial-guess builder may only be called once for a phase. Define all endpoints, controls, parameters, and relevant dynamics first. For local parameters, assigning `phase.initialGuess.continuous.localParameters` directly is the clearest and most reliable approach.

Before solving, plot or inspect the guess and check dimensions, units, bounds, discontinuities, and rough dynamic plausibility. Refining the grid does not compensate for a fundamentally poor starting point.
