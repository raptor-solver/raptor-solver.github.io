# Dynamics

Dynamics define the state derivative throughout a phase. Register a function handle with:

```matlab
term = phase.dynamics.add(@myDynamics);
```

For `nx` states evaluated at `N` points, the function must return an `nx x N` matrix in the declared state order.

## Callback form

```matlab
function stateDot = myDynamics(inputData)
    x = inputData.states;
    u = inputData.controls;

    % Example state order: [position; velocity]
    stateDot = [x(2, :); u(1, :)];
end
```

The fields have the shapes described in [Concepts and Conventions](../../getting-started/concepts.md). Use `.*`, `./`, and `.^` for pointwise operations over the time columns.

## Additive terms

Multiple calls to `add` create an additive dynamics model:

```matlab
base = phase.dynamics.add(@baseDynamics);
disturbance = phase.dynamics.add(@disturbanceDynamics);
```

Each term must return the full `nx x N` derivative contribution. RAPTOR sums them before applying the collocation equations. This is useful for separating linear and nonlinear parts.

## Function type

The returned term defaults to nonlinear. Mark it only when the contribution is genuinely linear in the optimization variables:

```matlab
term = phase.dynamics.add(@doubleIntegratorDynamics);
term.functionType = "linear";
```

Allowed values are `"linear"`, `"nonlinear"`, and `"conic"`. Incorrectly marking a nonlinear term as linear produces incorrect derivatives and can invalidate the solve.

## Differentiation compatibility

If you select complex-step differentiation, every operation in the callback must preserve the imaginary perturbation. Common pitfalls include `norm`, `abs`, comparisons, branches based on perturbed values, and explicit conversion to `real`. Express compatible norms algebraically where valid, for example `sqrt(sum(v.^2,1))`, or use central differences.

## Debugging a dynamics function

Evaluate it independently on representative batched data before building:

```matlab
data = raptor.inputData([], auxdata);
data.time = [0, 0.5, 1];
data.states = repmat(x0, 1, 3);
data.controls = repmat(u0, 1, 3);
data.localParameters = zeros(0, 1);

dx = myDynamics(data);
assert(isequal(size(dx), [phase.nStates, 3]))
assert(all(isfinite(dx), "all"))
```

This isolates callback errors from transcription and solver behavior.
