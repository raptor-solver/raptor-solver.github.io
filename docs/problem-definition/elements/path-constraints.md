# Path constraints

A path constraint bounds an algebraic function throughout a phase.

```matlab
phase.constraints.path.stack("slope", -Inf, auxdata.maxSlope);
phase.constraints.path.slope.label = "dy/dx";
phase.constraints.path.slope.unit = "-";

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

The output is `ng x N`, where `ng` is the number of entries in the lower/upper bounds and `N` is the number of input columns.

## Vector-valued group

```matlab
lower = [-Inf; 0];
upper = [qMax; heatMax];
phase.constraints.path.stack("environment", lower, upper);
phase.constraints.path.environment.add(@environmentConstraints);
```

```matlab
function g = environmentConstraints(inputData)
    q = dynamicPressure(inputData);
    heat = heatFlux(inputData);
    g = [q; heat];
end
```

Grouping related values is convenient, but separate named groups produce clearer automatic plots and covector fields.

## Equality constraints

A unit-vector control can be enforced as:

```matlab
phase.constraints.path.stack("unitControl", 1, 1);
phase.constraints.path.unitControl.add(...
    @(data) sum(data.controls.^2, 1));
```

For complex-step compatibility, the squared norm expression is preferable to `vecnorm` or `norm` when the mathematical constraint permits it.

## Enforcement and validation

Path constraints are enforced on the transcription's relevant grid, not at every real time. After convergence, evaluate safety-critical constraints on a denser interpolated or propagated trajectory. Increasing nodes may reveal between-node violations that were invisible on a coarse grid.
