# Scaling

Scaling maps variables, constraints, and the objective to numerically comparable magnitudes. Good scaling improves conditioning of derivatives and linear systems inside the NLP solver.

## Available methods

```matlab
problem.config.scaling.method = "NoScaling";
problem.config.scaling.method = "BoundsProjection";
problem.config.scaling.method = "RuizStatic";
problem.config.scaling.method = "JacobianRowNormalization";
problem.config.scaling.method = "Permutation";
problem.config.scaling.method = "Manual";
```

Several linear methods can be composed in order:

```matlab
problem.config.scaling.method = ["BoundsProjection", "RuizStatic"];
```

The composable methods are `BoundsProjection`, `RuizStatic`, `JacobianRowNormalization`, and `Permutation`. RAPTOR internally selects `CompositeLinearScaling` when an array is assigned. Order matters because each method operates after the previous transformation.

## Method guidance

**NoScaling**

: Leaves the NLP unchanged. Appropriate for an already nondimensionalized, well-scaled formulation and useful as a baseline.

**BoundsProjection**

: Uses variable bounds to map the search space to more uniform scales. Supply realistic finite bounds; infinite or excessively loose bounds provide little information.

**RuizStatic**

: Iteratively equilibrates derivative rows and columns. Configure the stopping tolerance, iteration count, and norm:

```matlab
problem.config.scaling.method = "RuizStatic";
problem.config.scaling.settings.tol = 1e-5;
problem.config.scaling.settings.max_iter = 100;
problem.config.scaling.settings.which_norm = Inf; % 1, 2, or Inf
```

**JacobianRowNormalization**

: Normalizes constraint Jacobian rows and can help when constraint sensitivities have very different magnitudes.

**Permutation**

: Reorders the system using `"DmPerm"` or `"RowColAmd"`:

```matlab
problem.config.scaling.method = "Permutation";
problem.config.scaling.settings.technique = "DmPerm";
```

**Manual**

: Uses explicit characteristic magnitudes per phase. Its settings contain a `phase` structure array. Each entry may contain `time`, `states`, `controls`, `localParameters`, `globalParameters`, `cost`, and named constraint fields, with one scale per component:

```matlab
problem.config.scaling.method = "Manual";
problem.config.scaling.settings.phase(1).time = 100;
problem.config.scaling.settings.phase(1).states = [1e5; 1e3; 1e4];
problem.config.scaling.settings.phase(1).controls = 1;
problem.config.scaling.settings.phase(1).cost = 100;
```

Set `problem.config.scaling.settings.phase(k).default = true` to leave a phase unscaled. Manual scaling is an advanced interface; verify the current release when using it with multiple phases or global parameters.

## Diagnosing poor scaling

Warning signs include very slow progress, oscillatory feasibility, tiny steps, apparent sensitivity to units, or a solution that changes when the same physics is expressed in different units.

Before changing algorithms:

- use consistent physical units;
- inspect typical magnitudes of states, controls, objective terms, and constraint residuals;
- avoid bounds many orders of magnitude wider than the physically reachable region;
- compare against a nondimensional formulation where practical;
- confirm numerical derivatives before attributing a problem to scaling.

Scaling changes numerical conditioning, not the intended physical optimum. Always interpret the returned solution in the original units.
