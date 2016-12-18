# Kernel

Note: I also recommend reading [Finite Elements The MOOSE Way](http://mooseframework.org/wiki/MooseTraining/FEM/) over on the MOOSE Wiki for more information.

A `Kernel` represents a piece of physics.  Typically a Kernel will embody one or more terms in a partial differential equation (PDE).  It's useful to think of a Kernel as an "operator" that is then applied to variables within a PDE.  By utilizing multiple Kernels all operating on the same variables large, complex PDEs can be easily solved for.

A Kernel has three major pieces:

1. A `type` that is a sub-type of `Kernel`
1. A `computeQpResidual()` function that works with that `type` and computes the value of the Kernel at one quadrature point.
1. An _optional_ `computeQpJacobian()` function computing the derivative of the residual at one quadrature point.

The `computeQpJacobian()` function is only optional if you're using Automatic Differentiation.  For more information see the [AutomaticDifferentiation Example](../examples/auto_diff.md).

## Kernel Sub-Type

Defining a new Kernel starts by sub-typing `Kernel`.  The sub-type _must_ include a member variable named `u` that is a `Variable`.  `u` is always the name for the Variable _this_ Kernel is operating on.  Here is an example from `Diffusion.jl`:

```julia
type Diffusion <: Kernel
    u::Variable
end
```

In addition to defining `u` a Kernel can also take in other parameters.  For example, `Convection` in `Convection.jl` takes in a constant "velocity vector":

```julia
type Convection <: Kernel
    u::Variable

    velocity::Vec{2, Float64}
end
```

That `velocity` can then be used in `computeQpResidual()`/`computeQpJacobian()`.

Finally, the Kernel sub-type should also have member variables for _coupled_ variables like so:

```julia
type CoupledConvection <: Kernel
    u::Variable
    other_var::Variable
end
```

## Residual

A Kernel embodies the weak form of a term in a PDE.  `computeQpResidual()` is where the value of that term is computed.

### Weak Form

To form the "weak form" of a PDE several steps must be taken:

1.  Write down strong form of PDE.
2.  Rearrange terms so that zero is on the right of the equals sign.
3.  Multiply the whole equation by a "test" function $\phi$.
4.  Integrate the whole equation over the domain $\Omega$.
5.  Integrate by parts (use the divergence theorem) to get the desired derivative order on your functions and simultaneously generate boundary integrals.

Let's try it on an example: a "Convection-Diffusion" PDE:

1. Write the strong form of the equation: $- \nabla\cdot k\nabla u + \vec{\beta} \cdot \nabla u = f  \phantom{\displaystyle \int}$

2. Rearrange to get zero on the right-hand side: $- \nabla\cdot k\nabla u + \vec{\beta} \cdot \nabla u - f = 0 \phantom{\displaystyle \int}$

3. Multiply by the test function $\phi$: $- \phi \left(\nabla\cdot k\nabla u\right) + \phi\left(\vec{\beta} \cdot \nabla u\right) - \phi f = 0 \phantom{\displaystyle \int}$

4. Integrate over the domain $\Omega$: ${-\int_\Omega\phi \left(\nabla\cdot k\nabla u\right)} + \int_\Omega\phi\left(\vec{\beta} \cdot \nabla u\right) - \int_\Omega\phi f = 0$

5. Apply the divergence theorem to the diffusion term: $\int_\Omega\nabla\phi\cdot k\nabla u - \int_{\partial\Omega} \phi \left(k\nabla u \cdot \hat{n}\right) + \int_\Omega\phi\left(\vec{\beta} \cdot \nabla u\right) - \int_\Omega\phi f = 0$

6. Write in inner product notation. Each term of the equation will inherit from an existing MOOSE type as shown below.

$$\underbrace{\left(\nabla\phi, k\nabla u \right)}_{Kernel} -
  \underbrace{\langle\phi, k\nabla u\cdot \hat{n} \rangle}_{BoundaryCondition} +
  \underbrace{\left(\phi, \vec{\beta} \cdot \nabla u\right)}_{Kernel} -
  \underbrace{\left(\phi, f\right)}_{Kernel} = 0 \phantom{\displaystyle \int}$$

For this equation we would create/use three `Kernel` objects and one `BoundaryCondition`.  The "inner-product" notation above shows what the "residual" should be for each term.  The `computeQpResidual()` function needs to compute what's inside each one of these integrals.

### `computeQpResidual()`

Creating a `computeQpResidual()` function for a Kernel is done by specializing `computeQpResidual()` for the new Kernel:

```julia
@inline function computeQpResidual(kernel::NewKernelType, qp::Int64, i::Int64)
    return residual_computation
end
```

where `NewKernelType` represents the new type of Kernel you just create by sub-typing Kernel.  This utilizes Julia's "multiple dispatch" capability so that this new function will get called whenever a residual is needed for the new Kernel.

`qp` is an index to use as the current quadrature point (for numerical integration) while `i` is the index of the current shape function.

#### Laplacian Example

Let's take a concrete example of a Laplacian operator.

1.  Strong form: $-\nabla\cdot\nabla u$
2.  Weak form: $\int_\Omega \nabla u \cdot \nabla \phi$

Then what goes in `computeQpResidual()` is: $\nabla u \cdot \nabla \phi$ like so:

```julia
@inline function computeQpResidual(kernel::Diffusion, qp::Integer, i::Integer)
    u = kernel.u

    return u.grad[qp] ⋅ u.grad_phi[qp][i]
end
```

Getting `u` like that is not strictly necessary.  It's simply done to make the code a littler nicer (so that we're not repeating `kernel.u` all the time).

## Jacobian

A Jacobian is the derivative of the residual.  To define this for a Kernel we'll create a `computeQpJacobian()` function that computes the derivative of the residual with respect to one particular degree of freedom at one quadrature point.

Note: Jacobians are NOT required if you're using Automatic Differentiation!  In that case these functions won't even be called!

### Math

Since $u \approx \sum u_j \phi_j$ that implies that $\frac{\partial u}{\partial u_k} = \phi_k$.  That is: the derivative of the variable with respect to one of its coefficients simply "picks off" the shape function that multiplies that coefficient.  The same applies to the gradient as well.


### `computeQpJacobian()`

The actual implementation is similar to `computeQpResidual()`:

```julia
@inline function computeQpJacobian(kernel::NewKernelType, v::Variable, qp::Integer, i::Integer, j::Integer)::Float64
    return jacobian_calculation
end
```

Where `v::Variable` is the variable MOOSE wants the derivative with respect to and `j::Integer` is an index for the "jth" shape function (the one corresponding to the "trial" function: the one supporting the variable _this_ Kernel is acting on).

What needs to be done is to use the `id` field in `v` to see which variable this variable is... and then if it's a variable that is used in this Kernel's residual computation then return the value of the derivative of the residual with respect to that variable.

Let's do an example:

### Example

Continuing with the Laplacian example from above...

1.  Strong form: $-\nabla\cdot\nabla u$
2.  Weak form: $\int_\Omega \nabla u \cdot \nabla \phi$
3.  Jacobian: $\frac{\partial}{\partial u_j}\int_\Omega \nabla u \cdot \nabla \phi = \int_\Omega \nabla \phi \cdot \nabla \phi$

To code that up looks like:

```julia
@inline function computeQpJacobian(kernel::Diffusion, v::Variable, qp::Integer, i::Integer, j::Integer)::Float64
    u = kernel.u

    if u.id == v.id
        return v.grad_phi[qp][j] ⋅ u.grad_phi[qp][i]
    end

    return 0
end
```

You can clearly see the $\nabla \phi \cdot \nabla \phi$ part... and it is only when MOOSE is looking for the derivative of this new Kernel with respect to the variable it's acting on (found by checking `u.id == v.id`).

The `return 0` at the end means that if MOOSE is looking for the derivative of this Kernel with respect to any other variable... then the value will always be zero (because there are no coefficients of that variable involved in the residual of this Kernel).