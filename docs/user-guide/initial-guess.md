# Initial Guess

The NLP solver starts from the initial guess. You set the known values in
`initialGuess.initial`, `initialGuess.final` and `initialGuess.continuous`,
then call **one** of the builder functions to complete the guess.

<div class="rp-cards" markdown>

<div class="rp-card" markdown>
`linear()`
{ .rp-card__title }

Linear interpolation between the endpoint values. Sufficient for many
simple problems.
</div>

<div class="rp-card" markdown>
`fromControl()`
{ .rp-card__title }

Integrates the dynamics from the initial state with a guessed control
history. The guess satisfies the dynamics.
</div>

<div class="rp-card" markdown>
Full profile
{ .rp-card__title }

Complete time, state and control histories, for example from a previous
solution.
</div>

</div>

=== "linear()"

    ```matlab
    phase.initialGuess.final.time = 2;
    phase.initialGuess.final.states(3) = 50;
    phase.initialGuess.continuous.controls = 0.5;
    phase.initialGuess.linear();
    ```

    For each endpoint value, RAPTOR uses the first available source:

    1. a fixed [boundary condition](bounds-and-boundary-conditions.md);
    2. the matching `initialGuess.initial` or `.final` value;
    3. the first or last column of `initialGuess.continuous`.

    States and controls are then interpolated linearly between the two
    endpoints. Every time, state, control and local parameter value must be
    available from one of these sources.

=== "fromControl()"

    ```matlab
    phase.initialGuess.final.time = 20;
    phase.initialGuess.continuous.time = linspace(0, 20, 21);
    phase.initialGuess.continuous.controls = controlProfile;
    phase.initialGuess.fromControl();
    ```

    RAPTOR integrates the registered dynamics with `ode45` from the initial
    state, interpolating your control guess. It needs the initial and final
    time, all initial states, the control history, any local parameters, and
    the dynamics already added.

    A single control column is treated as a constant control. The result
    satisfies the dynamics but in general does not satisfy the final
    conditions or the path constraints.

=== "Full profile"

    ```matlab
    phase.initialGuess.continuous.time     = tGuess;
    phase.initialGuess.continuous.states   = xGuess;
    phase.initialGuess.continuous.controls = uGuess;
    phase.initialGuess.continuous.localParameters = pGuess;
    ```

    State and control arrays need the declared number of rows and the same
    number of columns as `time`. RAPTOR interpolates the profile onto the
    collocation grid during `raptor.build`.

Global-parameter guesses belong to the problem:

```matlab
ocp.initialGuess.globalParameters = [1.0; 0.2];
```

!!! warning "Call a builder only once"
    `linear()` and `fromControl()` can be called once per phase. Set the
    boundary conditions, bounds, dynamics and parameter guesses before
    calling them.

!!! tip "Check the guess"
    Plot the guess and check its dimensions, units and values before
    solving. The initial guess often has more effect on convergence than the
    solver settings, and increasing the number of nodes does not compensate
    for a poor guess.
