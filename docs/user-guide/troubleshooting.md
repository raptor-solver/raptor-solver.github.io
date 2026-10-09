# Troubleshooting

Start by finding the **first** step that fails: installation, a model function,
the build, the solve, or the validation. Changing the settings of a later
step does not fix an error in an earlier one.

??? failure "The problem does not build"
    Check, in this order:

    1. Every function takes exactly one argument.
    2. Path functions work with several time columns and return the right
       number of rows (see [Vectorized Functions](../getting-started/vectorized-functions.md), which also
       shows how to test a function).
    3. Constraint outputs have as many rows as their bounds.
    4. State, control and parameter ordering is consistent everywhere.
    5. Fixed endpoint values lie inside the box bounds.
    6. Guess states and controls have the same number of columns.
    7. All guesses and parameters are defined.
    8. Collocation option strings are spelled exactly as documented.

    Reproduce a failing function outside RAPTOR with a hand-filled
    `raptor.inputData` (see [Dynamics and Costs](dynamics-and-costs.md)).
    The first MATLAB error message is usually the most useful one.

??? failure "The solver does not converge"
    Before changing the tolerances:

    1. Recheck equations, signs, units and ordering against your formulation.
    2. Check that the boundary conditions, bounds and constraints can be
       satisfied at the same time.
    3. Plot the initial guess and evaluate every function on it.
    4. Verify the derivatives on a few representative points.
    5. Look at the magnitudes of variables, constraints and derivatives.
    6. Use a moderate number of nodes.
    7. Read the solver's exact termination message.

    | Symptom | Common causes |
    | --- | --- |
    | restoration or infeasibility failure | inconsistent constraints, poor scaling, guess far from feasible |
    | tiny steps, no progress | wrong derivatives, ill-conditioning, non-smooth functions |
    | diverging iterates | missing bounds, sign errors, unbounded cost, `NaN`/`Inf` from a function |
    | iteration limit | check whether the constraint violation was still decreasing before increasing the limit |

??? failure "Complex step gives a different answer"
    Look for `abs`, `norm`, comparisons, saturations, look-up tables that
    discard the imaginary part, or external code that does not support
    complex inputs. Compare with central differences. The replacements for
    these operations are listed in
    [Vectorized Functions](../getting-started/vectorized-functions.md#complex-step-differentiation).

??? failure "Converged, but the propagation error is large"
    - Plot the discretized and propagated states for each component and find
      where the error increases.
    - Add nodes, or use an [hp grid](collocation.md#hp-collocation), and
      repeat; see [Collocation](collocation.md#number-of-nodes).
    - Try a smoother control `interpolationMethod`.
    - Look for discontinuities or rapid changes. These may require an
      additional phase.
    - Make sure the validation `relTol` and `absTol` are below the error you are measuring.
    - In multi-phase problems, check that each phase propagates from the
      intended upstream state.

    Reducing only the NLP tolerance does not usually reduce the
    discretization error.

??? failure "Plots or dual quantities are missing"
    If a post-processing step fails, RAPTOR shows a warning and still returns
    the solution. Read the warning and check which fields exist. A missing
    `costates` or `propagated` field means that step failed; the rest of the
    solution is still available.

## Asking for help

Open an issue on [GitHub](https://github.com/raptor-solver/raptor-matlab/issues)
with:

- RAPTOR version or commit, MATLAB release and operating system;
- the solver and its version;
- the full build and solver output;
- the configuration you changed from the defaults;
- a minimal problem that reproduces the behaviour;
- whether the double integrator example runs.

You can remove confidential data, but keep the dimensions and orders of
magnitude.
