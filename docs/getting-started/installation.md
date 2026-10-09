# Installation

RAPTOR is written in MATLAB and does not need to be compiled. To install it,
download the repository, add it to the MATLAB path, and run an example to
check that the included IPOPT solver works on your system.

## Requirements

| | |
| --- | --- |
| **MATLAB** | R2023b or newer. Tested on R2023b, R2025b and R2026a. |
| **Platform** | Windows or Linux (64 bit). On macOS, the IPOPT mex file must be built first, see [NLP Solvers](../user-guide/nlp-solvers.md#ipopt). |
| **NLP solver** | IPOPT is included (through `mexIPOPT`) and used by default. SNOPT and WORHP can be used if you install them and have a licence, see [NLP Solvers](../user-guide/nlp-solvers.md). |

## Install

<div class="rp-steps" markdown>

1. **Download RAPTOR.** Clone the repository, or download and extract a
   release archive, into a folder where you have write access.

    ```bash
    git clone https://github.com/raptor-solver/raptor-matlab.git
    ```

2. **Add RAPTOR to the MATLAB path.** In MATLAB, go to the repository root
   folder and run:

    ```matlab
    cd("path/to/raptor-matlab")
    RAPTOR_init();
    ```

    `RAPTOR_init` adds the `src`, `third_party` and `utils` folders and their
    subfolders to the path for the current session.

3. **Save the path (optional).** To avoid running `RAPTOR_init` after every
   MATLAB restart, save the path:

    ```matlab
    savepath;
    ```

</div>

!!! note
    Run `RAPTOR_init` from the repository root folder. It builds the paths
    from the current folder.

## Verify the installation

Run the double integrator example. It only uses the included IPOPT solver.

```matlab
RAPTOR_init();
cd(fullfile("examples", "00-doubleIntegrator"))
showPlots = false;
main;
```

IPOPT prints its iteration log, and the solution is stored in `sol`:

```matlab
sol.exitStatus   % true if the solver reports success
sol.objective
```

To run all the examples:

```matlab
cd tests
run_all_examples();
```

Some examples may need an external solver or licence. If an example fails,
run it on its own to see the complete output.

## Common problems

??? question "`RAPTOR_init` is undefined"
    MATLAB is not in the repository root folder. Use `cd` to go there first.

??? question "A `raptor.*` class or function is undefined"
    Run `RAPTOR_init` again, then check which installation MATLAB uses with
    `which raptor.build`.

??? question "The problem builds but the solver function is missing"
    RAPTOR is on the path but the selected NLP solver is not. Select
    `"Ipopt"`, or complete the setup described in
    [NLP Solvers](../user-guide/nlp-solvers.md).

??? question "A MEX file cannot be loaded"
    Check that the included binary matches your operating system and
    architecture, and that its runtime libraries are available. Include the
    full error message when asking for help.

When you report an installation problem, include the RAPTOR version, MATLAB
release, operating system, selected solver, and the complete error message.

[Next: Quickstart :material-arrow-right:](quickstart.md){ .md-button .md-button--primary }
