# Box constraints

Box constraints provide component-wise lower and upper bounds on decision variables. Unspecified lower bounds default to `-Inf`; unspecified upper bounds default to `Inf`.

## Phase bounds

```matlab
phase.box.lower.initialTime = 0;
phase.box.upper.initialTime = 10;
phase.box.lower.finalTime = 20;
phase.box.upper.finalTime = 100;

phase.box.lower.states = [-100; -50];
phase.box.upper.states = [ 100;  50];
phase.box.lower.controls = -5;
phase.box.upper.controls =  5;
phase.box.lower.localParameters = 0;
phase.box.upper.localParameters = 1;
```

State and control bounds apply wherever those variables are represented on the transcription grid. Time bounds apply to the endpoint decision variables. Local-parameter bounds apply to the static phase variables.

## Problem-level bounds

Global parameter bounds live on the top-level problem:

```matlab
ocp.box.lower.globalParameters = [0; -1];
ocp.box.upper.globalParameters = [5;  1];
```

## Shape and ordering

Use one entry per declared component and preserve the model ordering. Column vectors are the clearest form and match the declared API property shapes.

```matlab
% For state order [x; y; speed]
phase.box.lower.states = [0; 0; 0];
phase.box.upper.states = [10; 100; 100];
```

## Bounds versus fixed values

Set a fixed endpoint value with `boundaryConditions`, not by giving the entire state trajectory equal lower and upper bounds:

```matlab
phase.boundaryConditions.initial.states(1) = 0;
```

Equal box bounds fix a quantity everywhere in the phase and are appropriate for a control that is identically known, for example during a coast phase:

```matlab
coast.box.lower.controls = [0; 0];
coast.box.upper.controls = [0; 0];
```

## Practical guidance

- Prefer physically meaningful finite bounds when known; they restrict the search and support bounds-based scaling.
- Do not invent tight bounds solely to force convergence. They can hide model errors or exclude the optimum.
- Ensure every fixed boundary value lies within its corresponding box bounds.
- Check that the initial guess is within or close to the bounds.
- Use path constraints for nonlinear limits such as dynamic pressure or vector norms.
