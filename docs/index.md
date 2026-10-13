---
title: Home
template: home.html
hide:
  - navigation
  - toc
---

<section class="rp-section" markdown>

<div class="rp-section__head" markdown>
<span class="rp-eyebrow">Overview</span>

## How RAPTOR works

You define the optimal control problem in MATLAB. RAPTOR discretizes it with
a pseudospectral method, solves the resulting nonlinear program (NLP), and
checks the solution by integrating the dynamics with the optimal controls.
</div>

<div class="rp-pipeline" markdown>

<div class="rp-pipeline__card" markdown>
<span class="rp-eyebrow">1 · Problem</span>

\[
\begin{aligned}
\min\;& \Phi(x_0, x_f) + \textstyle\int_{t_0}^{t_f} L\,\mathrm{d}t \\
\text{s.t.}\;& \dot{x} = f(x, u, t) \\
& g(x, u, t) \le 0 \\
& \psi(x_0, x_f) = 0
\end{aligned}
\]

\(x\): states, \(u\): controls, \(x_0, x_f\): initial and final states,
\(\Phi\): endpoint cost, \(L\): running cost, \(f\): dynamics,
\(g\): path constraints, \(\psi\): boundary conditions.
{ .rp-note }

</div>

<div class="rp-pipeline__arrow" aria-hidden="true"></div>

<div class="rp-pipeline__card rp-pipeline__card--core" markdown>
<span class="rp-eyebrow">2 · Discretization and solution</span>
<p class="rp-pipeline__name">RAPTOR</p>
<ul class="rp-pipeline__stages">
  <li><span>Discretize</span><span>Lagrange or Birkhoff collocation</span></li>
  <li><span>Differentiate</span><span>sparse finite differences</span></li>
  <li><span>Scale</span><span>bounds- and Jacobian-based</span></li>
  <li><span>Solve</span><span>IPOPT, SNOPT or WORHP</span></li>
</ul>
</div>

<div class="rp-pipeline__arrow" aria-hidden="true"></div>

<div class="rp-pipeline__card" markdown>
<span class="rp-eyebrow">3 · Verification</span>
<svg class="rp-mini-plot" viewBox="0 0 260 132" role="img" aria-label="Sketch of the solution at the collocation nodes compared with the integrated dynamics">
  <line class="axis" x1="20" y1="120" x2="250" y2="120" />
  <line class="axis" x1="20" y1="120" x2="20" y2="12" />
  <path class="propagated" d="M 24 112 C 90 118, 150 20, 236 34" />
  <circle class="node" cx="24" cy="112" r="3.6" />
  <circle class="node" cx="31.5" cy="112.2" r="3.6" />
  <circle class="node" cx="52.7" cy="108.6" r="3.6" />
  <circle class="node" cx="84.3" cy="94.2" r="3.6" />
  <circle class="node" cx="122.5" cy="70" r="3.6" />
  <circle class="node" cx="162.9" cy="46.7" r="3.6" />
  <circle class="node" cx="199.8" cy="34.4" r="3.6" />
  <circle class="node" cx="226.3" cy="32.9" r="3.6" />
  <circle class="node" cx="236" cy="34" r="3.6" />
  <text x="246" y="131" text-anchor="end">t</text>
</svg>
<div class="rp-legend"><span>solution at the nodes</span><span>integrated dynamics</span></div>
</div>

</div>
</section>

<section class="rp-section" markdown>

<div class="rp-section__head" markdown>
<span class="rp-eyebrow">Results</span>

## Example results

Two of the examples, animated by their own plotting functions.
</div>

<div class="rp-media">
  <figure>
    <video src="assets/examples/14-rocketAscent.mp4" poster="assets/examples/14-rocketAscent.png" autoplay loop muted playsinline controls></video>
    <figcaption><a href="examples/#vehicle-problems">Rocket ascent</a>: minimum-time first-stage ascent with dynamic pressure limits.</figcaption>
  </figure>
  <figure>
    <video src="assets/examples/13-hypersonicEntry.mp4" poster="assets/examples/13-hypersonicEntry.png" autoplay loop muted playsinline controls></video>
    <figcaption><a href="examples/#vehicle-problems">Hypersonic entry</a>: minimum final velocity with heat flux, dynamic pressure and load limits.</figcaption>
  </figure>
</div>

</section>

<section class="rp-band" markdown>
<div class="rp-split" markdown>

<div markdown>
<span class="rp-eyebrow">Example</span>

## Defining a problem

A problem consists of one or more phases. For each phase you provide the
dynamics, cost, constraints, bounds and initial guess. Dynamics, costs and
constraints are ordinary MATLAB functions, evaluated at many time instants at
once ([vectorized](getting-started/vectorized-functions.md)).

The code shown is the complete double integrator from
`examples/00-doubleIntegrator`. The [Quickstart](getting-started/quickstart.md)
explains it line by line.

[Quickstart :material-arrow-right:](getting-started/quickstart.md){ .md-button .md-button--primary }
</div>

<div class="rp-window" markdown>

=== "main.m"

    ```matlab
    ocp = raptor.api.v1.OptimalControlProblem("doubleIntegrator", auxdata, 0);
    phase = ocp.addPhase("single", 6, 3, 0);  % 6 states, 3 controls

    f = phase.dynamics.add(@double_integrator);
    f.functionType = "linear";
    phase.costs.lagrange.add(@control_effort_cost);

    phase.boundaryConditions.initial.time   = 0;
    phase.boundaryConditions.final.time     = 11;
    phase.boundaryConditions.initial.states = [auxdata.r0; auxdata.v0];
    phase.boundaryConditions.final.states   = [auxdata.rf; auxdata.vf];

    phase.initialGuess.continuous.controls = [0 0 0]';
    phase.initialGuess.linear();

    phase.collocation.nodes  = "Gauss-Radau";
    phase.collocation.nNodes = 24;

    problem = raptor.build(ocp);
    problem.config.solver.method = "Ipopt";
    sol = problem.solve();
    ```

=== "double_integrator.m"

    ```matlab
    function xdot = double_integrator(inputData)
    % rows are state components, columns are time instants
    m = inputData.auxdata.mass;
    xdot = [inputData.states(4:6, :);
            inputData.controls(1:3, :) ./ m];
    end
    ```

=== "control_effort_cost.m"

    ```matlab
    function L = control_effort_cost(inputData)
    % scalar running cost, returned as a 1-by-N row
    w = inputData.auxdata.control_weight;
    L = w * sum(inputData.controls(1:3, :).^2, 1);
    end
    ```

</div>

</div>
</section>

<section class="rp-section" markdown>

<div class="rp-section__head" markdown>
<span class="rp-eyebrow">Features</span>

## Features
</div>

<div class="rp-cards rp-cards--3" markdown>

<div class="rp-card" markdown>
:material-vector-polyline: Multi-phase problems
{ .rp-card__title }

Mayer and Lagrange costs; path, differential, boundary and linkage
constraints.
</div>

<div class="rp-card" markdown>
:material-chart-bell-curve-cumulative: Pseudospectral methods
{ .rp-card__title }

Lagrange and Birkhoff formulations with Legendre polynomials,
Gauss-Radau or Gauss-Lobatto nodes, on a single segment or an hp grid.
</div>

<div class="rp-card" markdown>
:material-matrix: Numerical derivatives
{ .rp-card__title }

Central or complex-step differences. Sparsity patterns are
detected automatically.
</div>

<div class="rp-card" markdown>
:material-tune-variant: Scaling
{ .rp-card__title }

Bounds projection, Ruiz equilibration, Jacobian row normalization and
manual scaling. Methods can be combined.
</div>

<div class="rp-card" markdown>
:material-swap-horizontal: NLP solvers
{ .rp-card__title }

IPOPT is included. Interfaces to SNOPT and WORHP are available if you
have a licence for them.
</div>

<div class="rp-card" markdown>
:material-check-decagram: Solution checks
{ .rp-card__title }

Costates and Hamiltonian estimates, and integration of the dynamics to
check the accuracy of each solution.
</div>

</div>
</section>

<section class="rp-band" markdown>

<div class="rp-section__head" markdown>
<span class="rp-eyebrow">Examples</span>

## Examples

The repository includes 16 example problems, ordered by difficulty. Each
example introduces a few new features.
</div>

<div class="rp-ladder" markdown>

<div class="rp-card rp-card--link" markdown>
<span class="rp-level">00 – 05</span>

[:material-school-outline: Introductory problems](examples.md#introductory-problems)
{ .rp-card__title }

- Double integrator
- 1D landing
- Breakwell
- Brachistochrone
- Zermelo
- Gong

</div>

<div class="rp-card rp-card--link" markdown>
<span class="rp-level">06 – 08</span>

[:material-orbit: Classical aerospace problems](examples.md#classical-aerospace-problems)
{ .rp-card__title }

- Goddard rocket
- Orbit raising
- RLV return to launch site

</div>

<div class="rp-card rp-card--link" markdown>
<span class="rp-level">09 – 15</span>

[:material-rocket-launch-outline: Vehicle problems](examples.md#vehicle-problems)
{ .rp-card__title }

- 3-DoF Mars landing
- Windy landing
- Shuttle reentry
- Shuttle minimum heating
- Hypersonic entry
- Rocket ascent
- 6-DoF Mars landing

</div>

</div>
</section>

<section class="rp-section" markdown>
<div class="rp-cite" markdown>

<div markdown>
<span class="rp-eyebrow">Citing</span>

## Citing RAPTOR

The paper describing RAPTOR is available as an arXiv preprint. If you use
RAPTOR in published work, please cite it using the reference below.

[Citation details :material-arrow-right:](citing.md){ .md-button }
</div>

```bibtex
@misc{raptor,
  author        = {Minnozzi, Riccardo and Sagliano, Marco},
  title         = {Theoretical and Computational Advances in Birkhoff Pseudospectral Transcription for Aerospace Optimal Control},
  year          = {2026},
  eprint        = {XXXX.XXXXX},
  archivePrefix = {arXiv}
}
```

</div>
</section>

<section class="rp-section" markdown>
<span class="rp-eyebrow">Acknowledgements</span>

## Acknowledgements

Funded by the European Union ([ERC, STARGATE, 101169959](https://cordis.europa.eu/project/id/101169959)). Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Research Council. Neither the European Union nor the granting authority can be held responsible for them.

</section>

<section class="rp-band rp-cta" markdown>

## Getting started

Install RAPTOR and run the first example, then continue with the user guide.

[Installation](getting-started/installation.md){ .md-button .md-button--primary }
[User guide](user-guide/index.md){ .md-button }

</section>
