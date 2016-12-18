# Automatic Diferentiation

This example builds on [the Laplacian example](laplacian.md).

## Looking at `Diffusion.jl`

In that example the `Diffusion` Kernel was used to apply a `-div grad` to `u`.  The code for that Kernel can be [viewed on GitHub](https://github.com/friedmud/MOOSE.jl/blob/master/src/kernels/Diffusion.jl).

A `Kernel` is a piece of physics.  Typically one term in a PDE.  It represents the mathematical operator and is generic and can be applied to many different variables.

The implementation of a `Kernel` consists of a `type` that is a sub-type of `Kernel`.  In this case:

```julia
type Diffusion <: Kernel
    u::Variable
end
```

In addition a number of other functions can be specified which work on that type.  In particular:

  - `computeQpResdiual()`: computes the finite element residual at one quadrature point.
  - `computeQpJacobian()`: computes the derivative of the residual with respec to the passed in variable.

For the `Diffusion` Kernel they look like:

```julia
@inline function computeQpResidual(kernel::Diffusion, qp::Integer, i::Integer)
    u = kernel.u

    return u.grad[qp] ⋅ u.grad_phi[qp][i]
end

@inline function computeQpJacobian(kernel::Diffusion, v::Variable, qp::Integer, i::Integer, j::Integer)::Float64
    u = kernel.u

    if u.id == v.id
        return v.grad_phi[qp][j] ⋅ u.grad_phi[qp][i]
    end

    return 0
end
```

While, in this instance, the `computeQpJacobian()` function is straightforward to write, it can become incredibly difficult to derive for complex operators.  In addition, derivation of Jacobian terms is one of the most error-prone pieces of any finite-elemnt code... even moreso for a multiphysics code (because derivatives must be computed with respect to every variable in the system).  For this reason it would be extremely advantageous if the derivatives could be computed automatically.

## Automatic Differentiation (AD)

It turns out that `computeQpJacobian()` can be automatically computed by utilizing [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl)'s `Dual` type.  When working in this mode the `computeQpJacobian()` function will NOT be called at all... and therefore it is not necessary to even specify one.

There is only one small change in your script that is necessary for using AD: the parametric datatype for the `System` object must be changed.  In the [Laplacian Example](laplacian.md) the `System` was created like so:

```julia
diffusion_system = System{Float64}(mesh)
```

The `Float64` in that declaration is specifying the intrinsic datatype the residual is computed with.  To use AD, all that is necessary is simply:

```julia
diffusion_system = System{Dual{4,Float64}}(mesh)
```

That will cause MOOSE.jl to utilize `ForwardDiff.jl` for automatic computation of Jacobian entries.  Analytic derivatives are a thing of the past!

However: what is that `4` in the declaration?  The `4` is the maximum number of degrees of freedom (DoFs) on any one element.  It specifies the storage size inside of `Dual` for derivative information.

In this particular case we have only one variable... and we are using Quad4 elements.  Therefore, we will have _4_ degrees of freedom on each element... hence the choice of `4` here.  If, however, we had two variables then this would need to be `8`, three would be `12`, etc.

In the future we hope to improve the automatic detection of this number... but for now it needs to be set manually.

## Putting It All Together

In summary, to use AD all that is needed is to:

1. Create Kernels that provide `computeQpResidual()`  (`computeQpJacobian()` is unnecessary)
1. Change the parametric type of the `System` object in your script to `Dual`
1. Choose the correct amount of storage for partial derivatives insidue of a `Dual`

Here is the full Laplacian script that uses automatic differentiation:

```julia
using MOOSE

# Create the Mesh
mesh = buildSquare(0, 1, 0, 1, 10, 10)

# Create the System to hold the equations
diffusion_system = System{Dual{4,Float64}}(mesh)

# Add a variable to solve for
u = addVariable!(diffusion_system, "u")

# Apply the Laplacian operator to the variable
addKernel!(diffusion_system, Diffusion(u))

# u = 0 on the Left
addBC!(diffusion_system, DirichletBC(u, [4], 0.0))

# u = 1 on the Right
addBC!(diffusion_system, DirichletBC(u, [2], 1.0))

# Initialize the system of equations
initialize!(diffusion_system)

# Create a solver and solve
solver = JuliaDenseImplicitSolver(diffusion_system)
solve!(solver)

# Output
out = VTKOutput()
output(out, solver, "simple_diffusion_out")
```