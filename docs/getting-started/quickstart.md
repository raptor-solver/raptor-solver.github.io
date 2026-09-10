# Quickstart: double integrator

This walkthrough defines a fixed-time, three-dimensional double integrator. The six states are position and velocity, the three controls are accelerations, and the objective minimizes integrated control effort.

## 1. Create the model functions

RAPTOR passes one `raptor.inputData` object to every user function. Path functions are vectorized: rows are components and columns are evaluation times.

Create `doubleIntegratorDynamics.m`:

```matlab
function stateDot = doubleIntegratorDynamics(inputData)
    velocity = inputData.states(4:6, :);
    acceleration = inputData.controls(1:3, :) ./ inputData.auxdata.mass;
    stateDot = [velocity; acceleration];
end
```

Create `controlEffort.m`:

```matlab
function integrand = controlEffort(inputData)
    u = inputData.controls;
    integrand = inputData.auxdata.controlWeight .* sum(u.^2, 1);
end
```

The dynamics return `6 x N`; the scalar Lagrange integrand returns `1 x N`.

## 2. Define the continuous problem

Create `main.m`:

```matlab
clearvars
close all

auxdata.mass = 1;
auxdata.controlWeight = 1;
auxdata.r0 = [1; 1; 1];
auxdata.v0 = [1; 1; 1];
auxdata.rf = [1; -1; 0];
auxdata.vf = [0; 0; 0];
auxdata.t0 = 0;
auxdata.tf = 11;

ocp = raptor.api.v1.OptimalControlProblem(...
    "doubleIntegrator", auxdata, 0);
phase = ocp.addPhase("transfer", 6, 3, 0);

dynamicsTerm = phase.dynamics.add(@doubleIntegratorDynamics);
dynamicsTerm.functionType = "linear";
phase.costs.lagrange.add(@controlEffort);

phase.boundaryConditions.initial.time = auxdata.t0;
phase.boundaryConditions.final.time = auxdata.tf;
phase.boundaryConditions.initial.states = [auxdata.r0; auxdata.v0];
phase.boundaryConditions.final.states = [auxdata.rf; auxdata.vf];

phase.initialGuess.continuous.controls = zeros(3, 1);
phase.initialGuess.linear();

phase.collocation.interpolant = "Lagrange";
phase.collocation.polynomials = "Legendre";
phase.collocation.nodes = "Gauss-Radau";
phase.collocation.nNodes = 24;
```

The call to `linear()` completes the continuous state and control guess using the fixed endpoints and the constant control guess.

## 3. Build, configure, and solve

Append:

```matlab
problem = raptor.build(ocp);

problem.config.transcription.method = "NLP";
problem.config.scaling.method = "NoScaling";
problem.config.solver.method = "Ipopt";
problem.config.solver.tol = 1e-8;

problem.config.postprocessing.plotting.primal = true;
problem.config.postprocessing.plotting.dual = true;
problem.config.postprocessing.plotting.validation = true;

solution = problem.solve();
```

Always assign a method before changing its `settings`: method assignment replaces the method-specific settings object with fresh defaults.

## 4. Inspect the result

```matlab
assert(solution.exitStatus, "The NLP solver did not report success.")

t = solution.transfer.discretized.time;
r = solution.transfer.discretized.states(1:3, :);
v = solution.transfer.discretized.states(4:6, :);
u = solution.transfer.discretized.controls(1:3, :);

figure
tiledlayout(3, 1)
nexttile; plot(t, r); ylabel("position")
nexttile; plot(t, v); ylabel("velocity")
nexttile; plot(t, u); ylabel("control"); xlabel("time")
```

The phase key `transfer` comes from the name passed to `addPhase`. `discretized` and `collocated` use different time grids for methods whose boundary and collocation nodes differ; do not assume their column counts match.

Finally, compare `solution.transfer.propagated.states` with the discretized solution. Solver convergence and small NLP residuals are necessary, but the independently propagated trajectory is the more direct check of continuous-time dynamic accuracy.

## Next steps

- Learn the array and callback rules in [Concepts and Conventions](concepts.md).
- Add bounds, general constraints, and free time using [Defining Your Problem](../problem-definition/overview.md).
- Choose scaling and differentiation using [Configuring Your Solver](../solver-configuration/configuring-your-solver.md).
- Browse increasingly complex supplied problems in [Examples](../examples/examples.md).
