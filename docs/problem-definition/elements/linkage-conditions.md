# Linkage conditions

Linkages relate the final boundary of one phase to the initial boundary of another.

## Automatic continuity

For phases with matching state, control, and local-parameter dimensions:

```matlab
ocp.linkage.continuity(boostback, freefall);
```

The current API:

- enforces equality of time and states across the phase boundary;
- copies metadata and variable bounds from the first phase to the second;
- seeds the second phase's initial time and states from the already built continuous guess of the first;
- records the phase relation for numerical propagation.

Build the upstream phase guess before calling `continuity`, then build the downstream guess afterward:

```matlab
phase1.initialGuess.fromControl();
ocp.linkage.continuity(phase1, phase2);
phase2.initialGuess.final.time = tf2Guess;
phase2.initialGuess.continuous.controls = u2Guess;
phase2.initialGuess.fromControl();
```

## Coordinate changes

Pass a mapping when the downstream state uses a different coordinate representation:

```matlab
ocp.linkage.continuity(phase1, phase2, @mapFinalState);
```

```matlab
function x2 = mapFinalState(inputData)
    x1 = inputData.finalStates;
    % Illustrative coordinate reordering for the downstream phase
    x2 = [x1(2); x1(1); x1(3:end)];
end
```

The mapping returns the downstream initial state. It is used both in the linkage equation and during numerical propagation. A custom mapping is treated as nonlinear.

## Custom linkage

Declare a named vector relation and add a boundary callback:

```matlab
lower = zeros(nLink, 1);
upper = zeros(nLink, 1);
ocp.linkage.stack("stageSeparation", phase1, phase2, lower, upper);
term = ocp.linkage.stageSeparation.add(@separationMap);
```

In a linkage callback:

- `finalTime`, `finalStates`, and `finalControls` refer to the first phase;
- `initialTime`, `initialStates`, and `initialControls` refer to the second phase;
- `upstreamParameters` refers to the first (upstream) phase's local parameters;
- `localParameters` refers to the second (downstream) phase's local parameters;
- `globalParameters` and `auxdata` remain problem-wide.

Verify direction, component order, units, and signs explicitly. Use `continuity` when its side effects and equal-dimension requirement match the model; use `stack` when you need full control over the relation.
