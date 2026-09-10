# Visualization

RAPTOR can automatically plot primal, dual, and validation data after every solve.

```matlab
problem.config.postprocessing.plotting.primal = true;
problem.config.postprocessing.plotting.dual = true;
problem.config.postprocessing.plotting.validation = true;
solution = problem.solve();
```

## Make automatic plots readable

Define metadata before building:

```matlab
phase.metadata.name.time = "time";
phase.metadata.label.time = "t";
phase.metadata.unit.time = "s";

phase.metadata.name.states = ["horizontal position"; "vertical position"; "speed"];
phase.metadata.label.states = ["x"; "y"; "v"];
phase.metadata.unit.states = ["m"; "m"; "m/s"];

phase.metadata.name.controls = "inclination";
phase.metadata.label.controls = "u";
phase.metadata.unit.controls = "rad";
```

Named constraints support their own `label` and `unit`:

```matlab
phase.constraints.path.slope.label = "dy/dx";
phase.constraints.path.slope.unit = "-";
```

## Custom plots

A problem-specific plot often communicates more than generic time histories. Register a one-input callback:

```matlab
problem.config.postprocessing.plotting.auxiliaryFunction = @plotTrajectory;
```

```matlab
function plotTrajectory(solution)
    state = solution.descent.discretized.states;
    figure
    plot(state(1, :), state(2, :), "LineWidth", 1.5)
    xlabel("x [m]")
    ylabel("y [m]")
    axis equal
    grid on
end
```

The callback is executed after postprocessing. RAPTOR converts callback failures into warnings so the returned solution remains available.

## Plotting grid comparisons

Validation should show both the collocation reconstruction and independent propagation:

```matlab
disc = solution.descent.discretized;
prop = solution.descent.propagated;

figure
plot(disc.time, disc.states(1, :), "o-", ...
    "DisplayName", "discretized")
hold on
plot(prop.time, prop.states(1, :), "--", ...
    "DisplayName", "propagated")
legend
```

For error histories:

```matlab
semilogy(prop.time, abs(prop.errors.states') + eps)
xlabel("time")
ylabel("absolute state error")
```

Plot state components separately when they have different units or scales.

## Replot an existing solution

```matlab
problem.rePlot(solution);
```

This is useful after closing figures or when a custom plot function uses an unchanged solution. For durable analysis and publications, prefer explicit plotting scripts that record the exact fields, units, and transformations used.
