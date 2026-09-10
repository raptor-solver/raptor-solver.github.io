# Numerical differentiation

The transcribed NLP needs the objective gradient and constraint Jacobian. RAPTOR combines known linear structure, optional user-supplied derivative information, and a configured numerical method.

```matlab
problem.config.transcription.numericalJacobian = "CentralDifferences";
problem.config.transcription.finiteStep = 1e-5;
```

## Available methods

### Central differences

```matlab
problem.config.transcription.numericalJacobian = "CentralDifferences";
problem.config.transcription.finiteStep = 1e-5;
```

Central differences work with most smooth real-valued MATLAB code. A step that is too small amplifies floating-point cancellation; a step that is too large increases truncation error. The default `1e-5` is a starting point, not a universal optimum.

### Complex-step differences

```matlab
problem.config.transcription.numericalJacobian = "ComplexStepDifferences";
problem.config.transcription.finiteStep = 1e-10;
```

Complex step avoids subtractive cancellation and permits a very small step, but callbacks must propagate complex perturbations analytically. Incompatible operations include:

- `abs`, `norm`, or non-analytic complex functions;
- comparisons and branches that depend on a perturbed variable;
- `real`, `imag`, or casting to a real data type;
- external routines that reject complex inputs.

For a squared Euclidean norm, `sum(v.^2,1)` is complex-step compatible whereas `sum(abs(v).^2,1)` is not equivalent under complex perturbation.

### Dual-step differences

`"DualStepDifferences"` is accepted by the configuration API. Use it only when the callbacks and release-specific implementation support the required dual-number behavior; the supplied examples primarily demonstrate central and complex-step differences.

## Sparsity patterns at build time

During `raptor.build`, RAPTOR estimates which inputs affect each user function. It first perturbs inputs with `NaN` to obtain a conservative dependency pattern. If a callback rejects `NaN`, it falls back to finite perturbations near the initial guess.

The fallback can miss dependencies that are inactive at the guess—for example, a branch or saturation that activates elsewhere. Avoid branching where possible and inspect patterns for piecewise models.

## Function type and manual information

The object returned by `add` defaults to:

```matlab
term.functionType = "nonlinear";
```

Set `"linear"` only when the entire term is linear in all optimized inputs. A numeric derivative value with the expected output-by-input shape also establishes the corresponding logical dependency pattern. Advanced users can assign `term.jacobian.pattern.<field>` or `.value.<field>`; the field names mirror the path or boundary `inputData` fields.

Because manual derivative contracts are low-level and sensitive to dimensions, validate them against finite differences on representative points before relying on them.

## Verification strategy

1. Test each callback with multiple time columns.
2. Compare central differences using two sensible step sizes.
3. If compatible, compare against complex step.
4. Check random directions rather than only individual entries for large systems.
5. Repeat away from the initial guess, especially around regime changes.

Incorrect derivatives often look like solver or scaling failures. Verify them before aggressively changing tolerances.
