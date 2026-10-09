# Multi-Phase Problems

Phases are connected by **linkages**, which are constraints between the end
of one phase and the start of the next. Linkages are defined on the problem
object, `ocp.linkage`.

=== "Continuity"

    For phases with the same state, control and local-parameter dimensions:

    ```matlab
    ocp.linkage.continuity(boostback, freefall);
    ```

    This call:

    - makes time and states continuous across the junction;
    - copies metadata and variable bounds from the first phase to the second;
    - seeds the second phase's initial time and states from the first
      phase's guess;
    - records the connection for numerical propagation.

    For this reason, build the guess of the first phase before calling
    `continuity`, and the guess of the second phase after it:

    ```matlab
    phase1.initialGuess.fromControl();
    ocp.linkage.continuity(phase1, phase2);

    phase2.initialGuess.final.time = tf2Guess;
    phase2.initialGuess.continuous.controls = u2Guess;
    phase2.initialGuess.fromControl();
    ```

=== "Coordinate change"

    Pass a mapping when the second phase uses different state coordinates:

    ```matlab
    ocp.linkage.continuity(phase1, phase2, @mapFinalState);
    ```

    ```matlab
    function x2 = mapFinalState(inputData)
    x1 = inputData.finalStates;
    x2 = [x1(2); x1(1); x1(3:end)];   % illustrative reordering
    end
    ```

    The mapping returns the downstream initial state. It is used in the
    linkage constraint and in numerical propagation, and is always treated
    as nonlinear.

=== "Custom linkage"

    For other conditions, such as staging or partial continuity, define a
    named linkage with bounds and add a function, in the same way as other
    [constraints](constraints.md):

    ```matlab
    ocp.linkage.stack("link12", phase1, phase2, zeros(9, 1), zeros(9, 1));
    link = ocp.linkage.link12.add(@(d) ...
        [d.finalStates - d.initialStates;
         d.finalControls(1:3) - d.initialControls(1:3)]);
    link.functionType = "linear";
    ```

## Fields in a linkage function

| Field | Refers to |
| --- | --- |
| `finalTime`, `finalStates`, `finalControls` | the **first** (upstream) phase |
| `initialTime`, `initialStates`, `initialControls` | the **second** (downstream) phase |
| `upstreamParameters` | local parameters of the first phase |
| `localParameters` | local parameters of the second phase |
| `globalParameters`, `auxdata` | the whole problem |

Check the direction, component order, units and signs. An incorrect linkage
usually does not cause an error message, only a wrong trajectory.

!!! example
    `examples/08-rlvReturn` chains three phases with `continuity`, and
    plots them as a single trajectory (see
    [combined plots](results.md#plots-of-several-phases)).
