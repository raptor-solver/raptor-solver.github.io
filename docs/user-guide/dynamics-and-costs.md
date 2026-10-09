# Dynamics and Costs

## Dynamics

Register the state derivative of a phase with `add`:

```matlab
term = phase.dynamics.add(@myDynamics);
```

```matlab
function xdot = myDynamics(inputData)
x = inputData.states;
u = inputData.controls;
% state order: [position; velocity]
xdot = [x(2, :);
        u(1, :)];
end
```

For `nx` states evaluated at `N` points the function returns an `nx x N`
array in the declared state order. Use `.*`, `./` and `.^` so it works for
any number of columns.

!!! tip
    For norms, dot and cross products, matrix products and other common
    operations, see [Vectorized Functions](../getting-started/vectorized-functions.md).

### Additive models

Calling `add` more than once builds the dynamics as a sum:

```matlab
phase.dynamics.add(@gravity);
phase.dynamics.add(@thrust);
phase.dynamics.add(@drag);
```

Each term returns a full `nx x N` array, and RAPTOR adds them. This allows
you to keep different effects in separate functions and to mark linear terms
separately.

### Function type

Every term returned by `add` has a `functionType`, which is `"nonlinear"` by
default. Set it to `"linear"` when the term is linear in all decision
variables. RAPTOR then computes its derivatives only once:

```matlab
term = phase.dynamics.add(@doubleIntegrator);
term.functionType = "linear";
```

!!! warning
    Marking a nonlinear term as linear gives wrong derivatives, and no error
    is reported.

??? tip "Testing a function before building"
    Evaluating a function on test data before the build helps to separate
    errors in the model from other errors:

    ```matlab
    data = raptor.inputData([], auxdata);
    data.time     = [0, 0.5, 1];
    data.states   = repmat(x0, 1, 3);
    data.controls = repmat(u0, 1, 3);
    data.localParameters = zeros(0, 1);

    xdot = myDynamics(data);
    assert(isequal(size(xdot), [numel(x0), 3]))
    assert(all(isfinite(xdot), "all"))
    ```

## Costs

RAPTOR minimizes the sum of every Mayer and Lagrange term in every phase.

=== "Mayer (endpoint)"

    A Mayer term is a boundary function that returns a scalar, for example
    the final time:

    ```matlab
    term = phase.costs.mayer.add(@(data) data.finalTime);
    term.functionType = "linear";
    ```

    To maximize a quantity, minimize its negative:

    ```matlab
    phase.costs.mayer.add(@(data) -data.finalStates(7));   % maximize final mass
    ```

=== "Lagrange (running)"

    A Lagrange term is a path function returning a `1 x N` row; RAPTOR
    integrates it over the phase:

    ```matlab
    phase.costs.lagrange.add(@controlEffort);
    ```

    ```matlab
    function L = controlEffort(inputData)
    u = inputData.controls;
    L = inputData.auxdata.controlWeight .* sum(u.^2, 1);
    end
    ```

The terms from several calls to `add` are summed, for example to combine an
objective with penalty terms:

```matlab
phase.costs.lagrange.add(@fuelRate);
phase.costs.lagrange.add(@trackingPenalty);
phase.costs.mayer.add(@terminalPenalty);
```

Choose the weights so that each term has the intended relative importance.
[Scaling](numerical-setup.md#scaling) improves the numerical conditioning but
does not change the weighting between terms.

??? failure "Common mistakes"
    - Returning a column instead of a `1 x N` row from a Lagrange term, or a
      scalar for a constant term (see [Vectorized Functions](../getting-started/vectorized-functions.md)).
    - Missing minus sign when maximizing.
    - Marking a quadratic term as `"linear"`.
    - Using `abs`, `norm` or branches with complex-step differentiation, see
      [Numerical Setup](numerical-setup.md#complex-step-differences).
