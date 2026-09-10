# Differential constraints

A differential constraint bounds the time derivative of a registered path quantity. Its callback returns the quantity itself; RAPTOR applies the pseudospectral differentiation operator.

For a thrust-rate limit:

```matlab
rateLimit = 100;
constraint = phase.constraints.differential.stack(...
    "thrustRate", -rateLimit, rateLimit);
term = constraint.add(@(data) data.controls(1, :));
term.functionType = "linear";
```

This expresses a bound on the derivative of control component 1, not a bound on its value. Value bounds still belong in `phase.box`.

## Callback contract

Differential-constraint functions use the same vectorized path fields and `ng x N` output convention as path constraints. The lower and upper bounds apply to the differentiated quantity.

## Choosing this constraint type

Use a differential constraint when the mathematical requirement is a derivative of an algebraic quantity already described by states, controls, or parameters. If the derivative needs its own dynamics, continuity properties, or initial value, it can be clearer to introduce the quantity as an additional state and constrain its state derivative through the dynamics.

## Numerical considerations

Derivative constraints are sensitive to grid resolution and interpolation. Inspect their returned values on both collocated and discretized grids, and check the solution on a denser grid when the limit is safety-critical. A discontinuous intended control is generally incompatible with a tight derivative limit.
