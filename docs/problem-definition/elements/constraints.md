# Constraints

RAPTOR provides three phase-level constraint families and problem-level linkages.

| Family | Enforced on | Callback data | Typical use |
| --- | --- | --- | --- |
| Path | trajectory grid | path fields | dynamic pressure, control norm, obstacle limit |
| Differential | derivative of a path quantity | path fields | slew or rate limits |
| Boundary | phase endpoints | boundary fields | terminal orbit, endpoint relation |
| Linkage | endpoints of two phases | boundary fields from both phases | continuity, staging, coordinate change |

All general constraints use a two-step pattern:

```matlab
phase.constraints.path.stack("constraintName", lowerBound, upperBound);
term = phase.constraints.path.constraintName.add(@constraintFunction);
```

`stack` declares the output dimension and bounds. `add` registers an additive function term. If several terms are added to one named constraint, RAPTOR sums their outputs before enforcing the bounds.

## Equality and inequality forms

For a callback output `g`:

```matlab
% g == 0
stack("equality", 0, 0)

% g <= upper
stack("upperLimit", -Inf, upper)

% lower <= g
stack("lowerLimit", lower, Inf)

% lower <= g <= upper
stack("interval", lower, upper)
```

Vector bounds define a multi-component group. The callback must return rows in the same order and count.

## Names and metadata

The group name becomes a dynamic MATLAB property and a solution field, so use a unique valid identifier:

```matlab
phase.constraints.path.stack("dynamicPressure", 0, qMax);
phase.constraints.path.dynamicPressure.label = "q";
phase.constraints.path.dynamicPressure.unit = "Pa";
```

## Function terms and derivatives

The object returned by `add` supports `functionType` and optional `jacobian.pattern` / `jacobian.value` data. RAPTOR otherwise estimates dependency patterns at build time and numerical derivatives during transcription. See [Numerical Differentiation](../../solver-configuration/numerical-differentiation.md).
