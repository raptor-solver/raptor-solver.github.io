# Installation

## Requirements

RAPTOR requires MATLAB R2023 or newer. The 0.1.0 manual reports successful testing with R2023b, R2025b, and R2026a; compatibility with other releases is not guaranteed.

At least one supported nonlinear-programming solver is also required:

- **IPOPT** is bundled through the `mexIPOPT` interface and is the default backend.
- **SNOPT** is supported but must be installed and licensed separately.
- **WORHP** is supported but must be installed and licensed separately.

See [Third-Party Integrations](third-party-integrations.md) before selecting SNOPT or WORHP.

## Add RAPTOR to MATLAB

Clone or download RAPTOR into a directory where you have write permission. From MATLAB, change to the repository root and run:

```matlab
cd("C:\path\to\raptor")
RAPTOR_init();
```

`RAPTOR_init` adds `src`, `third_party`, and `utils`, including their subdirectories, to the current MATLAB path. The change applies to the current session. Run the function again after restarting MATLAB, or save the path explicitly if that is appropriate for your installation:

```matlab
savepath;
```

!!! note
    Run `RAPTOR_init` from the repository root. The initialization function builds its paths from MATLAB's current working directory.

## Verify the installation

The double-integrator example uses the bundled IPOPT interface and is the smallest practical check:

```matlab
cd("C:\path\to\raptor")
RAPTOR_init();
cd(fullfile("examples", "00-doubleInt"))
showPlots = false;
main;
```

A successful run builds the problem, starts IPOPT, and returns `sol` in the workspace. Inspect:

```matlab
sol.exitStatus
sol.objective
sol.single.discretized.states
```

`exitStatus == true` means the adapter recognized the solver termination as successful. It does not by itself establish continuous-time accuracy; inspect the validation results as described in [Solution and Validation](../analyzing-results/solution.md).

To exercise the supplied examples as a collection, run from the repository root:

```matlab
cd tests
run_all_examples();
```

Some examples can depend on an external solver or license. Investigate each failure individually and rerun that example with its complete command-window output visible.

## Common installation problems

**`RAPTOR_init` is undefined**

: MATLAB is not in the repository root and the root itself is not on the path. Change to the root directory first.

**A `raptor.*` class or function is undefined**

: Rerun `RAPTOR_init`, then use `which raptor.build` to confirm which installation MATLAB sees.

**The problem builds but the solver function is missing**

: The RAPTOR source is available, but the selected NLP backend is not correctly installed or on the MATLAB path. Select the bundled IPOPT interface or complete the external solver setup.

**A MEX-file cannot be loaded**

: Confirm that the bundled binary matches the operating system and architecture, and that its native runtime dependencies are available. Preserve the complete loader error when requesting support.

When reporting an installation issue, include the RAPTOR version, MATLAB release, operating system and architecture, selected solver and version, and the full error message.
