# Constraints

## Defining a constraint

All constraints are defined in two steps: `stack` creates a named
constraint with its bounds, and `add` adds the function that computes it.

```matlab
phase.constraints.path.stack("dynamicPressure", 0, qMax);
term = phase.constraints.path.dynamicPressure.add(@dynamicPressure);
```

- The bounds set the number of components: scalars for one component,
  column vectors for several. The function must return the components in
  the same order.
- If `add` is called more than once for the same constraint, the terms are
  summed before the bounds are applied.
- The name is used as a property, a field of the solution and a plot title,
  so it must be a valid MATLAB identifier such as `dynamicPressure`. A plot
  `label` and `unit` can also be set.
- Each term has a `functionType` (`"nonlinear"` by default) exactly as for
  [dynamics](dynamics-and-costs.md#function-type).

| Form | Bounds |
| --- | --- |
| \(g = 0\) | `stack(name, 0, 0)` |
| \(g \le g_{\max}\) | `stack(name, -Inf, gMax)` |
| \(g \ge g_{\min}\) | `stack(name, gMin, Inf)` |
| \(g_{\min} \le g \le g_{\max}\) | `stack(name, gMin, gMax)` |

## Constraint types

=== "Path"

    A path constraint bounds a function of the time, states, controls and
    parameters over the whole phase. The function returns an `ng x N`
    array (see [Vectorized Functions](../getting-started/vectorized-functions.md)).

    ```matlab
    phase.constraints.path.stack("slope", -Inf, auxdata.maxSlope);
    phase.constraints.path.slope.label = "dy/dx";
    phase.constraints.path.slope.unit  = "-";
    term = phase.constraints.path.slope.add(@slopeConstraint);
    term.functionType = "linear";
    ```

    ```matlab
    function value = slopeConstraint(inputData)
    x = inputData.states(1, :);
    y = inputData.states(2, :);
    value = y - inputData.auxdata.slope .* x;
    end
    ```

    Unit-norm control vector (written without `norm` so that it can be used
    with complex-step differentiation):

    ```matlab
    phase.constraints.path.stack("unitControl", 1, 1);
    phase.constraints.path.unitControl.add(@(d) sum(d.controls.^2, 1));
    ```

=== "Differential"

    A differential constraint bounds the **time derivative** of a quantity.
    The function returns the quantity itself, as a vectorized `ng x N`
    array (see [Vectorized Functions](../getting-started/vectorized-functions.md)), and RAPTOR computes its
    derivative with the pseudospectral differentiation matrix. Example of a
    thrust-rate limit:

    ```matlab
    rateLimit = 100;
    c = phase.constraints.differential.stack("thrustRate", -rateLimit, rateLimit);
    term = c.add(@(d) d.controls(1, :));
    term.functionType = "linear";
    ```

    This bounds the rate of change of control 1, not its value; bounds on
    the value are set in `phase.box`. If the derivative needs its own
    dynamics or initial value, add it as a state instead.

=== "Boundary"

    A boundary constraint bounds a function of the endpoint values of a
    phase. The function returns a column vector.

    ```matlab
    target = [7000e3; 7500];
    phase.constraints.boundary.stack("terminalTarget", target, target);
    phase.constraints.boundary.terminalTarget.add(@terminalTarget);
    ```

    ```matlab
    function value = terminalTarget(inputData)
    radius = sqrt(sum(inputData.finalStates(1:3).^2));
    speed  = sqrt(sum(inputData.finalStates(4:6).^2));
    value  = [radius; speed];
    end
    ```

    Periodicity condition between the start and the end of the phase:

    ```matlab
    phase.constraints.boundary.stack("periodic", zeros(nx, 1), zeros(nx, 1));
    phase.constraints.boundary.periodic.add(@(d) d.finalStates - d.initialStates);
    ```

    To fix a single endpoint value, use a
    [boundary condition](bounds-and-boundary-conditions.md) instead.

Constraints between two phases (linkages) are described in
[Multi-Phase Problems](multi-phase.md).

!!! note "Constraints are enforced at the nodes only"
    Path and differential constraints are enforced at the collocation nodes,
    not between them. For critical limits, check the constraint on the
    propagated trajectory or on a finer grid.
