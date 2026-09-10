# Cost function

RAPTOR minimizes the sum of all registered Mayer and Lagrange terms across all phases.

## Mayer terms

A Mayer term is evaluated at phase endpoints and returns a scalar. Use it for final time, terminal mass, endpoint error, or another boundary quantity.

```matlab
term = phase.costs.mayer.add(@(data) data.finalTime);
term.functionType = "linear";
```

To maximize a quantity, minimize its negative:

```matlab
phase.costs.mayer.add(@(data) -data.finalStates(7));
```

The callback has the same endpoint fields as a boundary constraint.

## Lagrange terms

A Lagrange term is a scalar vectorized path function. RAPTOR integrates it over the phase:

```matlab
phase.costs.lagrange.add(@controlEffort);
```

```matlab
function L = controlEffort(inputData)
    u = inputData.controls;
    L = inputData.auxdata.controlWeight .* sum(u.^2, 1);
end
```

For `N` input columns it must return `1 x N`.

## Multiple terms and scaling

Calls to `add` are additive:

```matlab
phase.costs.lagrange.add(@fuelRate);
phase.costs.lagrange.add(@trackingPenalty);
phase.costs.mayer.add(@terminalPenalty);
```

Choose explicit weights so contributions represent the intended tradeoff and have reasonable magnitudes. Numerical scaling can improve conditioning, but it cannot decide the correct physical weighting.

## Common mistakes

- Returning a column vector from a vectorized Lagrange callback. The output should be `1 x N`.
- Forgetting a minus sign when maximizing terminal mass or energy.
- Using non-smooth expressions with a derivative method that assumes smoothness.
- Marking a quadratic or otherwise nonlinear term as `"linear"`.
- Putting a terminal objective in a Lagrange callback or a running cost in a Mayer callback.
