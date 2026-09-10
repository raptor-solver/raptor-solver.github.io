# Functions and constraints API

## User callback input: `raptor.inputData`

Although it sits at the top-level `raptor` package rather than under `raptor.api`, `raptor.inputData` is the public data contract for user callbacks.

### Path fields

| Field | Shape at `N` points |
| --- | --- |
| `time` | `1 x N` |
| `states` | `nStates x N` |
| `controls` | `nControls x N` |
| `localParameters` | vector with `nLocalParameters` entries |
| `globalParameters` | vector with `nGlobalParameters` entries |
| `auxdata` | fixed problem data |

### Boundary fields

```text
initialTime, finalTime
initialStates, finalStates
initialControls, finalControls
localParameters, globalParameters, auxdata
```

A linkage additionally uses `upstreamParameters` for the first linked phase's local parameters. For linkages, `final*` and `upstreamParameters` belong to the first phase; `initial*` and `localParameters` belong to the second.

## `phase.dynamics.add`

```matlab
term = phase.dynamics.add(functionHandle)
```

Registers a path callback returning `nStates x N`. Multiple terms are summed. The returned function-term object lets you identify linearity and provide advanced derivative metadata.

```matlab
term.functionType = "linear";    % default is "nonlinear"
```

Allowed types are `"linear"`, `"nonlinear"`, and `"conic"`.

## Constraint `stack`

Declares a named group. The length of the bound vectors determines its output size.

### Path

```matlab
constraint = phase.constraints.path.stack(name, lowerBound, upperBound)
```

The later callback returns `nConstraint x N`; the bound applies along the path.

### Differential

```matlab
constraint = phase.constraints.differential.stack(name, lowerBound, upperBound)
```

The callback returns a path quantity `nConstraint x N`; RAPTOR bounds its pseudospectral time derivative.

### Boundary

```matlab
constraint = phase.constraints.boundary.stack(name, lowerBound, upperBound)
```

The callback returns an `nConstraint x 1` endpoint quantity.

### Linkage

```matlab
constraint = ocp.linkage.stack(...
    name, phase1, phase2, lowerBound, upperBound)
```

The callback is evaluated on the endpoints of `phase1` and `phase2`.

For every family, `name` becomes a dynamic property. Lower and upper bounds must have matching lengths and ordering. Use `-Inf` or `Inf` for one-sided constraints.

## `constraint.add`

```matlab
term = constraint.add(functionHandle)
```

Registers one contribution to the named group. Contributions are summed before bounds are applied. Every term must return the group's declared number of rows.

Constraint objects also expose:

```matlab
constraint.label = "q";
constraint.unit = "Pa";
```

These values control display and automatic plots; they do not affect the NLP.

## Cost `add`

### Mayer

```matlab
term = phase.costs.mayer.add(functionHandle)
```

Registers a scalar boundary term. The callback returns one value.

### Lagrange

```matlab
term = phase.costs.lagrange.add(functionHandle)
```

Registers a scalar path integrand. For `N` input points, the callback returns `1 x N`.

All cost terms in all phases are added to the minimized objective.

## Function-term properties

Every `add` returns a function-term object with:

| Property | Purpose |
| --- | --- |
| `functionHandle` | Registered callback |
| `functionType` | `"linear"`, `"nonlinear"`, or `"conic"` |
| `jacobian.pattern` | Optional logical dependency matrices |
| `jacobian.value` | Optional derivative values or handles, depending on the field |

Path Jacobian fields are `time`, `states`, `controls`, `localParameters`, and `globalParameters`. Boundary fields are `initialTime`, `finalTime`, `initialStates`, `finalStates`, `initialControls`, `finalControls`, `localParameters`, `globalParameters`, and, for linkages, `upstreamParameters`.

Each pattern/value matrix uses output-by-input orientation. For example, a three-output path constraint in a phase with five states has a state Jacobian of size `3 x 5`. Assigning a complete numeric value of the correct shape also updates its logical dependency pattern.

Manual derivatives are advanced. Incorrect values can silently corrupt convergence; compare them to numerical derivatives before use.

## `ocp.linkage.continuity`

```matlab
constraint = ocp.linkage.continuity(phase1, phase2)
constraint = ocp.linkage.continuity(phase1, phase2, coordinateChange)
```

Creates equality constraints on downstream initial time/state versus upstream final time/state. Without a mapping, states pass through unchanged and the term is marked linear. With a mapping:

```matlab
x2Initial = coordinateChange(inputData)
```

the returned vector is compared with `inputData.initialStates`, and the term is treated as nonlinear.

The method requires equal state, control, and local-parameter counts. It also copies phase-1 metadata and box bounds into phase 2 and initializes phase-2 guess endpoints from phase 1, so call it only after building phase 1's initial guess. See [Linkage Conditions](../problem-definition/elements/linkage-conditions.md) before using it.
