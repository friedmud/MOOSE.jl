# BoundaryCondition

A BoundaryCondition is similar to a [Kernel](kernel.md).  It is formed out of the weak form of a PDE (see the [explanation in Kernel](kernel.md)) and computes a residual and a Jacobian.

However, there are two types of BoundaryCondition objects: `IntegratedBC` and `NodalBC`.  In general, an `IntegratedBC` should be used to represent boundary integrals within a weak form.  The `NodalBC` is mainly used for "Dirichlet" or "Type-1" or "Essential" boundary conditions.

## NodalBC

As mentioned above a `NodalBC` represents a "Dirichlet" boundary condition.  That is, a condition of the type $u = value$ on the boundary nodes.  In MOOSE that value can either be a constant, or even a nonlinear function of the solution variables at that node.  One restriction on `NodalBC` objects is that they do _not_ have access to gradient information (because gradients are typically discontinuous at the nodes).


### Creating a NodalBC

To create a new NodalBC you need to create a sub-type of `NodalBC` like so:

```julia
" Boundary condition expressing `u = value` at a set of nodes "
type DirichletBC <: NodalBC
    " The variable the BC will be applied to "
    u::Variable

    " The boundary ID to apply this BC to "
    bids::Array{Int64}

    " The value on the boundary "
    value::Float64
end
```

Here we are showing the actual code from `DirichletBC.jl` for implementing a $u=v$ type BC.  A BoundaryCondition _must_ provide `u`: the Variable the BC is being applied to and `bids::Array{Int64}`: the boundary IDs in the mesh where the BC will be applied.

After the type has been created then a `computeQpResidual()` function needs to be created similar to [Kernels](kernel.md).  However, to form the residual for a NodalBC you simply take the $u=v$ equation and move everything to the left hand side: $u-v=0$.  What is on the left hand side is the "residual" and can be coded up like so:

```julia
function computeResidual(bc::DirichletBC)
    u = bc.u

    return u.nodal_value - bc.value
end
```

Similar to Kernels a `computeQpJacobian()` statement can be provided.  It is only optional if you are using [Automatic Differentiation](../examples/auto_diff.md).  Since the value of any Lagrange shape function at a node is always 1... $\frac{\partial u}{\partial u_j} = 1$ at the node.  Therefore:

```julia
function computeJacobian(bc::DirichletBC, v::Variable{Float64})
    u = bc.u

    if u.id == v.id
        return 1.
    end

    return 0.
end
```

Just as in [Kernels](kernel.md) you should always `return 0` in the case where MOOSE is looking for a derivative with respect to a variable this BoundaryCondition is not operating on.