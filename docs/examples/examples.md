# Examples

The RAPTOR repository contains a progressive set of complete MATLAB formulations under `examples/`. Run `RAPTOR_init` from the repository root before opening an example directory.

## Suggested learning path

| Folder | Problem | What to study |
| --- | --- | --- |
| `00-doubleInt` | Double integrator | Minimal dynamics, Lagrange cost, fixed endpoints, IPOPT |
| `01-landing1D` | One-dimensional landing | Differential constraint for thrust rate |
| `02-breakwell1D` | Breakwell problem | State bounds and control-effort objective |
| `03-brachistochrone` | Brachistochrone | Free final time, path constraint, Mayer cost, metadata, custom plots |
| `04-Zermelo` | Zermelo navigation | Nonlinear equality path constraint |
| `05-Gong` | Gong problem | Local parameter and additive constraint terms |
| `06-orbitRaising2D` | Orbit raising | Orbital dynamics and more realistic scaling |
| `07-ascentGoddard` | Goddard rocket | Free-time ascent and terminal objective |
| `08-boostback2D` | Multi-phase boostback | Three phases and automatic continuity |
| `09-landing3DoF` | Three-DOF landing | Multiple nonlinear path constraints |
| `10-windyLanding3DoF` | Windy landing | Environmental disturbance data |
| `11-entryBetts` | Atmospheric entry | Dense constraints and minimax/local-parameter formulation |
| `12-entryWang` | Atmospheric entry | Nondimensionalized vehicle/environment modules |
| `13-ascent3DoF` | Three-DOF ascent | Boundary constraints and variable thrust |
| `14-landing6DoF` | Six-DOF landing | High-dimensional dynamics and geometric constraints |

The list describes the dominant teaching point rather than every feature in a folder. Some directories contain multiple main scripts or supporting variants.

## Running an example

```matlab
cd("C:\path\to\raptor")
RAPTOR_init();
cd(fullfile("examples", "03-brachistochrone"))
showPlots = true;
main;
```

Many main scripts preserve an externally defined `showPlots` variable. Set it to `false` for noninteractive runs.

## How to read an example

Follow the same sequence in every main script:

1. constants and auxiliary data;
2. `raptor.api.v1.OptimalControlProblem` construction;
3. phase dimensions and metadata;
4. dynamics, constraints, and objective terms;
5. boundary values and box bounds;
6. initial guess;
7. collocation grid;
8. `raptor.build`;
9. numerical configuration;
10. `problem.solve()` and custom analysis.

Open every callback referenced by `add`. The main script establishes dimensions and ordering, while the callback files define the actual mathematical model.

## Adapting an example safely

Copy the closest example into a new working directory and change one layer at a time:

- rename the problem and phase;
- define the new component ordering and metadata;
- replace dynamics and test them independently;
- update boundary values and bounds;
- update constraints and objectives;
- rebuild the guess;
- only then tune collocation and numerical configuration.

Do not carry over solver tolerances, scaling, or node counts without reconsidering the new model's units, smoothness, and accuracy requirements.

## Generate a starting script

The utility `createMainTemplate()` creates a `main.m` blueprint in MATLAB's current directory. It overwrites an existing `main.m`, so call it only in a new directory or after preserving the existing file.

The template is a convenience rather than a required layout. Mature projects should move reusable callbacks, physical models, and analysis into separate files or packages.
