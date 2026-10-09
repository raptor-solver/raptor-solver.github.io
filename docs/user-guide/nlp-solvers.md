# NLP Solvers

RAPTOR discretizes the problem and solves the resulting nonlinear program
(NLP) with an external solver:

```matlab
problem.config.solver.method     = "Ipopt";   % or "Snopt", "Worhp"
problem.config.solver.tol        = 1e-8;      % main tolerance, default 1e-6
problem.config.solver.iter_limit = 3000;      % iteration limit, default 3000
```

`tol` and `iter_limit` are passed to the selected solver. Solver-specific
options are in `problem.config.solver.settings`. Set the method first,
because setting it resets the settings.

| Solver | Included | Licence | Setup |
| --- | --- | --- | --- |
| IPOPT | yes | free (EPL) | none on Windows and Linux |
| SNOPT | no | commercial | copy the SNOPT MATLAB interface into `third_party/snopt` |
| WORHP | no | academic or commercial | copy the WORHP files into `third_party/worhp` |

`RAPTOR_init` adds every subfolder of `third_party` to the MATLAB path, so
solver files placed there are found automatically.

## IPOPT

IPOPT is included with RAPTOR through
[mexIPOPT](https://github.com/ebertolazzi/mexIPOPT), and is used by default.
The mex files in `third_party/ipopt` cover:

- **Windows** (64 bit): works out of the box.
- **Linux** (64 bit): the mex file is selected from the version of the C
  compiler configured in MATLAB (`mex -setup C`): one for gcc 7 and 8, and 
  one for gcc 9 or newer, which is also used when no compiler is configured.
- **macOS**: no mex file is included; build it from the mexIPOPT repository
  and place it in `third_party/ipopt`.

```matlab
problem.config.solver.method = "Ipopt";
problem.config.solver.settings.parameters_mu_strategy = "adaptive";
problem.config.solver.settings.termination_wall_time  = 3600;
problem.config.solver.settings.output_print_level     = 5;
```

The settings also expose IPOPT's primary and acceptable tolerances for dual
infeasibility, constraint violation, complementarity and objective change.

## SNOPT

### Setup

1. Obtain SNOPT and its licence from
   [Stanford Business Software](https://www.sbsi-sol-optimize.com/).
2. Copy the files of the SNOPT MATLAB interface (the `sn*.m` functions and
   the `snoptcmex` mex file for your platform) into `third_party/snopt`.
3. Run `RAPTOR_init`.

RAPTOR uses `snsolve`, `snset`, `snseti`, `snsetr` and `snscreen`, as in the
SNOPT 7 MATLAB interface. Check that SNOPT works on its own before using it
with RAPTOR.

### Settings

```matlab
problem.config.solver.method = "Snopt";
problem.config.solver.settings.iterations_limit       = 100000;
problem.config.solver.settings.minor_iterations_limit = 100000;
problem.config.solver.settings.feasibility_tolerance  = 1e-8;
```

If `feasibility_tolerance` is left at its default, RAPTOR uses twice
`problem.config.solver.tol`.

## WORHP

### Setup

WORHP requires a licence issued for your machine (it is linked to the MAC
addresses of the computer, and it has an expiry date).

1. Obtain WORHP and a licence from [worhp.de](https://worhp.de).
2. Copy into `third_party/worhp`:
    - the WORHP MATLAB mex gateway (`worhp.mexw64` on Windows);
    - the WORHP library next to it (`worhp.dll` and its dependencies on
      Windows, `libworhp.so` on Linux, `libworhp.dylib` on macOS);
    - your licence file `worhp.lic`.

    The parameter file `worhp_raptor.xml` used by RAPTOR is already in
    `third_party/worhp`.

3. Run `RAPTOR_init`, then check the installation:

    ```matlab
    checkWorhpInstallation();
    ```

    The check finds each file, reads the licence, and solves a small test
    problem with WORHP. It ends with `WORHP IS READY TO BE USED` when
    everything works.

The licence and the parameter file are searched first next to the mex
gateway, then in `third_party/worhp`. To keep the licence somewhere else,
set its path:

```matlab
problem.config.solver.settings.license_file = "path/to/worhp.lic";
```

### Usage

```matlab
problem.config.solver.method = "Worhp";
problem.config.solver.settings.algorithm = "SQP";   % or "IP"
sol = problem.solve();
```

In addition to the usual fields, the solution contains `sol.exitCode`, the
WORHP termination status: codes of at least `1000` are successful (`1001` is
an optimal solution), codes of at most `-1000` are failures (for example
`-1002` iteration limit, `-1003` timeout, `-1012` local point of
infeasibility).

??? info "WORHP settings"
    All settings are in `problem.config.solver.settings`.

    | Setting | Default | Meaning |
    | --- | --- | --- |
    | `license_file`, `parameters_file` | found automatically | paths of the licence and parameter file |
    | `algorithm` | `"SQP"` | `"SQP"` or `"IP"` |
    | `Timeout` | 7 days | time limit, in seconds |
    | `TolFeas` | follows `tol` | feasibility tolerance |
    | `AcceptTolOpti`, `AcceptTolFeas` | `1e-3` | tolerances of an acceptable iterate |
    | `KeepAcceptableSol` | `true` | return the last acceptable iterate if the solve stops early |
    | `InternalHessianApproximation` | `"BFGS"` | `"BFGS"` or `"FiniteDifference"` |
    | `WhichFiniteDiff`, `FiniteDiffEps` | `"Central"`, `1e-5` | finite differences for the Hessian |
    | `NLPprint` | `1` | WORHP print level (`0` for no output) |
    | `InftyUnbounded` | `1e20` | bound value treated as infinite |
    | `sandbox_root`, `keep_sandbox` | temp folder, `false` | folder used for each solve (see below) |

    `tol` is passed as `TolOpti` and `iter_limit` as `MaxIter`. RAPTOR does
    not provide second derivatives, so the Hessian is always approximated by
    WORHP.

    Any other WORHP parameter can be set through `extraParameters`, applied
    last. Use a struct, or a dictionary for names that contain a dot:

    ```matlab
    problem.config.solver.settings.extraParameters.LineSearchMethod = 3;
    problem.config.solver.settings.extraParameters = ...
        dictionary(["qp.ipComTol", "qp.ipResTol"], [1e-8, 1e-9]);
    ```

    Unknown parameter names are reported as warnings.

??? info "How RAPTOR runs WORHP"
    WORHP reads its licence from the current folder. RAPTOR therefore runs
    each solve in a temporary folder containing a copy of the licence and of
    the parameter file (with the requested settings applied), and returns
    to the original folder afterwards, also after an error. The files in
    `third_party/worhp` and in your working folder are never modified.

??? failure "WORHP troubleshooting"
    | Message | Fix |
    | --- | --- |
    | WORHP mex gateway not found | copy the gateway into `third_party/worhp` and run `RAPTOR_init` |
    | no WORHP licence file found | copy `worhp.lic` into `third_party/worhp`, or set `license_file` |
    | the licence does not cover this machine | the licence was issued for other MAC addresses |
    | the licence expired | request a new licence |
    | `Warning (CheckParams): Parameter qp.ipComTol ...` | harmless; set `qp.ipComTol`, `qp.ipResTol` and `qp.lsTol` to `[1e-2, 1e-3, 1e-4] * tol` through `extraParameters` to remove it |

    The tests of the WORHP interface are run with `cd tests` and
    `run_worhp_tests()`; tests that need WORHP are skipped if it is not
    installed.

## Choosing a solver

Use IPOPT first to check the model and the installation. Another solver may
perform better on some problems, but changing the solver does not fix
modelling errors, wrong derivatives or a poor initial guess.

To compare solvers, keep the model, grid, scaling and derivative method the
same, and compare the exit status, objective, number of iterations, solve
time and [validation error](results.md#validation).

## Solver output

```matlab
sol.exitStatus    % true if the solver reported success
sol.objective
sol.nIterations   % where the solver reports it
sol.solveTime     % where the solver reports it
```

Also read the termination message printed by the solver. Not all solvers
report all quantities; missing values are `NaN` or `Inf`.
