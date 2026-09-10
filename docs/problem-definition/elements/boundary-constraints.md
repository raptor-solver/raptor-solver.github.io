# Boundary constraints

Boundary constraints impose general equalities or inequalities on phase endpoints.

```matlab
target = [7000e3; 7500];
phase.constraints.boundary.stack("terminalTarget", target, target);
phase.constraints.boundary.terminalTarget.add(@terminalTarget);
```

```matlab
function value = terminalTarget(inputData)
    radius = norm(inputData.finalStates(1:3));
    speed = norm(inputData.finalStates(4:6));
    value = [radius; speed];
end
```

Boundary callbacks are evaluated once. They can use:

- `initialTime`, `finalTime`;
- `initialStates`, `finalStates`;
- `initialControls`, `finalControls`;
- `localParameters`, `globalParameters`;
- `auxdata`.

Their output is a column vector whose length matches the bound vectors.

## Boundary condition or boundary constraint?

Prefer a direct boundary condition when fixing a single known variable:

```matlab
phase.boundaryConditions.final.states(1) = targetX;
```

Use a boundary constraint for derived quantities, coupled components, endpoint inequalities, or relations between the beginning and end of the same phase:

```matlab
phase.constraints.boundary.stack("periodic", zeros(nx,1), zeros(nx,1));
phase.constraints.boundary.periodic.add(...
    @(data) data.finalStates - data.initialStates);
```

## Additive construction

Several terms may define one relation:

```matlab
phase.constraints.boundary.stack("netChange", 0, 0);
phase.constraints.boundary.netChange.add(@(d) d.finalStates(1));
linearTerm = phase.constraints.boundary.netChange.add(@(d) -d.initialStates(1));
linearTerm.functionType = "linear";
```

The sum is constrained. Ensure all terms return the same number of rows.
