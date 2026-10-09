# Vectorized Functions

RAPTOR evaluates your model functions (dynamics, running costs, path and
differential constraints) at many time instants in a single call. Each
quantity that changes in time is passed as an array with **one row per
component and one column per time instant**, and your function must return
an array with the same layout.

This page shows how to write common mathematical expressions in this form.
The code is often different from what you would write for a single time
instant, but the rules are few and always the same.

## The layout

For `nx` states, `nu` controls and `N` time instants:

| Input | Size | Column `k` |
| --- | --- | --- |
| `inputData.time` | `1 x N` | time \(t_k\) |
| `inputData.states` | `nx x N` | state \(x(t_k)\) |
| `inputData.controls` | `nu x N` | control \(u(t_k)\) |
| `inputData.localParameters`, `globalParameters` | vectors | (constant in time) |
| `inputData.auxdata` | your data | (constant in time) |

| Output | Size |
| --- | --- |
| dynamics | `nx x N` |
| path or differential constraint with `ng` components | `ng x N` |
| running (Lagrange) cost | `1 x N` |

So `x(:, k)` is the whole state at one time instant, and `x(i, :)` is the
time history of component `i`. **Work on rows**: extract the components you
need as rows, combine them element by element, and stack the results.

## Cheat sheet

In the table, `a`, `b` and `x` are `3 x N` arrays (vectors at each time
instant), `s` and `w` are `1 x N` rows (scalars at each time instant), and
`A` and `c` are constants.

| Mathematics | Vectorized MATLAB | Result size |
| --- | --- | --- |
| component \(x_i\) | `x(i, :)` | `1 x N` |
| \(s\,w\), \(s/w\), \(s^2\) | `s .* w`, `s ./ w`, `s.^2` | `1 x N` |
| \(\sin s\), \(e^{s}\), \(\sqrt{s}\) | `sin(s)`, `exp(s)`, `sqrt(s)` | `1 x N` |
| \(s\,\mathbf{a}\) | `s .* a` | `3 x N` |
| \(\mathbf{a} - \mathbf{c}\) (constant vector) | `a - c` (with `c` a column) | `3 x N` |
| \(\lVert \mathbf{a} \rVert\) | `sqrt(sum(a.^2, 1))` | `1 x N` |
| \(\mathbf{a} / \lVert \mathbf{a} \rVert\) | `a ./ sqrt(sum(a.^2, 1))` | `3 x N` |
| \(\mathbf{a} \cdot \mathbf{b}\) | `sum(a .* b, 1)` | `1 x N` |
| \(\mathbf{a} \times \mathbf{b}\) | `cross(a, b, 1)` | `3 x N` |
| \(A\,\mathbf{a}\) (constant matrix) | `A * a` | `3 x N` |
| \(A(t)\,\mathbf{a}\) (matrix changing in time) | see [below](#matrices-that-change-in-time) | `3 x N` |
| constant \(c\) | `c + 0 .* s` | `1 x N` |
| stack components | `[s; w; s .* w]` | `3 x N` |

The key points:

- **Use the element-wise operators** `.*`, `./` and `.^` between quantities
  that change in time. `*` and `/` are only correct when one of the two
  operands is a constant (a scalar, or a constant matrix multiplying from
  the left).
- **Give the dimension** to functions that work along a dimension: `sum(x, 1)`,
  `cross(a, b, 1)`, `vecnorm(x, 2, 1)`. Without it, MATLAB picks the first
  dimension that is not 1, which is the time dimension when an array has a
  single row.
- **Constants are expanded automatically** when combined with arrays: a
  column vector `c` is subtracted from each column of `a` in `a - c`, and a
  row `s` multiplies each row of `a` in `s .* a`.

## A complete example

The dynamics of a point mass with thrust \(T\) along a unit direction
\(\hat{\mathbf{u}}\), drag and central gravity,

\[
\dot{\mathbf{r}} = \mathbf{v}, \qquad
\dot{\mathbf{v}} = \frac{T}{m}\,\hat{\mathbf{u}}
- \frac{D}{m} \frac{\mathbf{v}}{\lVert \mathbf{v} \rVert}
- \frac{\mu}{\lVert \mathbf{r} \rVert^3}\,\mathbf{r}, \qquad
\dot{m} = -\frac{T}{c},
\]

with \(D = k \lVert \mathbf{v} \rVert^2\), are written as:

```matlab
function xdot = pointMassDynamics(inputData)
aux = inputData.auxdata;

% components (rows) of the states and controls
r = inputData.states(1 : 3, :);           % 3 x N
v = inputData.states(4 : 6, :);           % 3 x N
m = inputData.states(7, :);               % 1 x N
uHat = inputData.controls(1 : 3, :);      % 3 x N

% norms at each time instant
rNorm = sqrt(sum(r.^2, 1));               % 1 x N
vNorm = sqrt(sum(v.^2, 1));               % 1 x N

% forces per unit mass
thrust = aux.T ./ m .* uHat;              % 3 x N
drag = - aux.k .* vNorm.^2 ./ m .* v ./ vNorm;
gravity = - aux.mu ./ rNorm.^3 .* r;

% state derivative
xdot = [v;
        thrust + drag + gravity;
        - aux.T / aux.c + 0 .* m];        % constant mass flow, as a 1 x N row
end
```

The same approach gives path constraints and running costs. A constraint on
the thrust direction being a unit vector, and a cost on the squared thrust
angle from the vertical \(\mathbf{e}_z\), are:

```matlab
function g = unitThrustDirection(inputData)
uHat = inputData.controls(1 : 3, :);
g = sum(uHat.^2, 1);                      % 1 x N, bounded to [1, 1]
end

function L = thrustAngleCost(inputData)
uHat = inputData.controls(1 : 3, :);
cosAngle = uHat(3, :);                    % dot product with [0; 0; 1]
L = (1 - cosAngle).^2;                    % 1 x N
end
```

## More cases

### Matrices that change in time

When a matrix depends on the states (for example a rotation matrix from a
quaternion), it is different at each time instant. Two options:

=== "Write the product by rows"

    Write each row of the matrix as a `3 x N` array, and take the dot
    product with the vector:

    ```matlab
    q = inputData.states(8 : 11, :);       % quaternion, 4 x N
    C1 = [1 - 2 * (q(3, :).^2 + q(4, :).^2);
          2 * (q(2, :) .* q(3, :) + q(1, :) .* q(4, :));
          2 * (q(2, :) .* q(4, :) - q(1, :) .* q(3, :))];
    % ... C2, C3 in the same way
    y = [sum(C1 .* a, 1); sum(C2 .* a, 1); sum(C3 .* a, 1)];
    ```

=== "Use pages"

    Store one matrix per time instant as a `3 x 3 x N` array `C`, and use
    `pagemtimes`:

    ```matlab
    y = reshape(pagemtimes(C, reshape(a, 3, 1, [])), 3, []);
    ```

### Parameters and constant data

Parameters and `auxdata` do not change in time, so they combine with time
histories directly:

```matlab
p = inputData.localParameters(1);         % scalar
g = inputData.controls(1, :) .* inputData.states(2, :) - p;   % 1 x N
```

Use linear indexing (`localParameters(1)`) for parameters, so that the code
does not depend on whether they are passed as a row or a column.

### Functions of time and tables

Data that depends on time, such as a wind profile, can be stored in
`auxdata` as a vectorized function handle:

```matlab
auxdata.wind = @(t) [sin(t); 0 .* t; cos(t)];   % 3 x N for a 1 x N time
% in the dynamics
w = inputData.auxdata.wind(inputData.time);
```

Tabulated data, such as an atmosphere model, can be interpolated with
`interp1`, which returns a row for a row input:

```matlab
h = sqrt(sum(r.^2, 1)) - aux.R0;          % 1 x N
rho = interp1(aux.hTable, aux.rhoTable, h);   % 1 x N
```

### Conditions

An `if` on a state or control only looks at one value, so it does not work
on time histories, and it makes the function non-smooth. Prefer a smooth
formulation. When a switch is really needed, use logical arrays:

```matlab
% instead of: if h > hSwitch, k = k1; else, k = k2; end
above = h > aux.hSwitch;                  % 1 x N logical
k = above .* aux.k1 + ~above .* aux.k2;   % 1 x N
```

### Boundary functions

Endpoint costs, boundary constraints and linkages are evaluated once, on the
endpoint values, so they are not vectorized: `inputData.finalStates` is a
single column, and the function returns a column vector. Norms are still
best written as `sqrt(sum(x.^2))`.

## Complex-step differentiation

With [complex-step differentiation](../user-guide/numerical-setup.md#complex-step-differences),
the inputs carry a small imaginary perturbation, and every operation must
keep it. Some common MATLAB functions do not:

| Avoid | Use instead |
| --- | --- |
| `norm(x)`, `vecnorm(x)` | `sqrt(sum(x.^2, 1))` |
| `dot(a, b)` | `sum(a .* b, 1)` |
| `abs(s)` | `sqrt(s.^2)` (smooth only away from 0) |
| `max`, `min`, comparisons on perturbed values | smooth formulations |
| `real`, `imag`, conversions to real types | (remove) |

The replacements also work with central differences, so using them
everywhere keeps your functions compatible with both methods.

## Check a function before building

A function that works for one time instant may still fail for several, or
give results with the wrong layout. Evaluate it on test data with a few
columns, and compare it with one column at a time:

```matlab
data = raptor.inputData([], auxdata);
data.time = [0 1 2];
data.states = rand(7, 3);
data.controls = rand(3, 3);
data.localParameters = zeros(0, 1);

xdotAll = pointMassDynamics(data);        % all instants at once
assert(isequal(size(xdotAll), [7 3]))

one = data;                               % only the second instant
one.time = data.time(2);
one.states = data.states(:, 2);
one.controls = data.controls(:, 2);
assert(max(abs(pointMassDynamics(one) - xdotAll(:, 2))) < 1e-12)
```

If the two results differ, a `*`, `/` or `^` without the dot, or a function
called without the dimension, is the most likely cause.
