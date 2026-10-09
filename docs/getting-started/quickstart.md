# Quickstart

This page builds the example `examples/00-doubleIntegrator` step by step. The
example covers each step of a typical RAPTOR script.

## The problem

A point mass moves in three dimensions. The state contains position \(r\)
and velocity \(v\), \(x = [r;\, v] \in \mathbb{R}^6\), and the control is
the applied force \(u \in \mathbb{R}^3\). The initial and final states are
fixed, the final time is \(t_f = 11\), and the control effort is minimized:

\[
\begin{aligned}
\min_{u} \quad & \int_{0}^{11} w\, \lVert u(t) \rVert^2 \,\mathrm{d}t \\
\text{subject to} \quad & \dot{r} = v, \quad \dot{v} = u / m, \\
& x(0) = x_0, \quad x(11) = x_f,
\end{aligned}
\]

where \(m\) is the mass and \(w\) is a weight on the control effort.

## 1. Write the model functions

Each function passed to RAPTOR receives one input, `inputData`. Functions
evaluated along the trajectory are **vectorized**: each row is a component
and each column is a time instant (see [Vectorized Functions](vectorized-functions.md)
for how to write them).

=== "double_integrator.m"

    ```matlab
    function xdot = double_integrator(inputData)
    m = inputData.auxdata.mass;
    xdot = [inputData.states(4:6, :);              % dr/dt = v
            inputData.controls(1:3, :) ./ m];      % dv/dt = u/m
    end
    ```

=== "control_effort_cost.m"

    ```matlab
    function L = control_effort_cost(inputData)
    w = inputData.auxdata.control_weight;
    L = w * sum(inputData.controls(1:3, :).^2, 1);   % 1-by-N
    end
    ```

For `N` time instants, the dynamics return a `6 x N` array and the cost
returns a `1 x N` row.

## 2. Define the problem

Create `main.m` in the same folder as the two functions:

```matlab
% constants, available in every function as inputData.auxdata
auxdata.r0 = [1; 1; 1];   auxdata.v0 = [1; 1; 1];
auxdata.rf = [1; -1; 0];  auxdata.vf = [0; 0; 0];
auxdata.mass = 1;         auxdata.control_weight = 1;
auxdata.t0 = 0;           auxdata.tf = 11;

% one problem with one phase: 6 states, 3 controls, no parameters
ocp = raptor.api.v1.OptimalControlProblem("doubleIntegrator", auxdata, 0);
phase = ocp.addPhase("single", 6, 3, 0);

% dynamics and cost
f = phase.dynamics.add(@double_integrator);
f.functionType = "linear";                   % (1)!
phase.costs.lagrange.add(@control_effort_cost);

% fixed initial and final time and state
phase.boundaryConditions.initial.time   = auxdata.t0;
phase.boundaryConditions.final.time     = auxdata.tf;
phase.boundaryConditions.initial.states = [auxdata.r0; auxdata.v0];
phase.boundaryConditions.final.states   = [auxdata.rf; auxdata.vf];

% initial guess: zero control, states interpolated linearly between the endpoints
phase.initialGuess.continuous.controls = [0 0 0]';
phase.initialGuess.linear();

% discretization
phase.collocation.interpolant = "Lagrange";
phase.collocation.nodes       = "Gauss-Radau";
phase.collocation.nNodes      = 24;
```

1.  A term marked as `"linear"` has constant derivatives, which RAPTOR
    computes only once. Use it only if the term is linear in all decision
    variables.

## 3. Build and solve

```matlab
problem = raptor.build(ocp);

problem.config.solver.method = "Ipopt";
problem.config.solver.tol    = 1e-8;

sol = problem.solve();
```

`raptor.build` checks the problem definition and creates a solver object.
`problem.config` contains the numerical settings: derivatives, scaling, NLP
solver and post-processing. The default values work for this example.

## 4. Inspect the result

By default, RAPTOR plots the states and controls, the costates and
Hamiltonian, and the comparison with the integrated dynamics. The solution
arrays can also be used directly:

```matlab
assert(sol.exitStatus, "IPOPT did not report success")

t = sol.single.discretized.time;
r = sol.single.discretized.states(1:3, :);
u = sol.single.discretized.controls;

tiledlayout(2, 1)
nexttile; plot(t, r); ylabel("position")
nexttile; plot(t, u); ylabel("control"); xlabel("time")
```

The field name `single` is the phase name given to `addPhase`.

!!! tip "Check the accuracy of the solution"
    A successful solver exit does not guarantee that the trajectory is
    accurate between the nodes. `sol.single.propagated` contains the
    trajectory obtained by integrating the dynamics with the optimal
    controls. Compare it with the discretized solution, as described in
    [Solution and Validation](../user-guide/results.md).

## Next steps

<div class="rp-cards" markdown>

<div class="rp-card rp-card--link" markdown>
[:material-lightbulb-on-outline: Core Concepts](concepts.md)
{ .rp-card__title }

Problem formulation and the conventions used by all functions.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-book-open-page-variant-outline: User Guide](../user-guide/index.md)
{ .rp-card__title }

Bounds, constraints, free final time, multiple phases and solver settings.
</div>

<div class="rp-card rp-card--link" markdown>
[:material-rocket-launch-outline: Examples](../examples.md)
{ .rp-card__title }

16 example problems, ordered by difficulty.
</div>

</div>
