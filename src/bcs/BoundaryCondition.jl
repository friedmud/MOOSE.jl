"""
    A BoundaryCondition is a Kernel... it just computes differently

    A BoundaryCondition _must_ supply a bid::Array{Int64} variable
    that specifies which boundary IDs this BC is applied to
"""
abstract BoundaryCondition <: Kernel
  # bids::Array{Int64}

" A NodalBC gets applied _at_ nodes and overwrites residual / jacobian entries "
abstract NodalBC <: BoundaryCondition

" An IntegratedBC is integrated across sidesets to compute residual / jacobians "
abstract IntegratedBC <: BoundaryCondition

" Get the boundary IDs this BoundaryCondition should be applied to "
function boundaryIDs(bc::BoundaryCondition)
    return bc.bids
end

" Generic `computeJacobian()` for Float64.  Just returns 0 "
function computeJacobian(bc::BoundaryCondition, var::Variable)
    return 0.
end

"""
    Generic `computeJacobian()` for Dual

    Uses Automatic Differentiation to compute the Jacobian.

    NOTE!  This is sub-optimal if you want both the residual and the Jacobian!
    In that case use `computeResidualAndJacobian!()` instead!
"""
function computeJacobian{N,T}(bc::BoundaryCondition, var::Variable{Dual{N,T}})
    residual = computeResidual(bc)

    return partials(residual)[var.id]
end

" Compute the Residual and Jacobian using calls to `computeJacobian()` "
function computeResidualAndJacobian!(residual::Array{Float64},
                                     var_jacobians::Array{Float64},
                                     vars::Array{Variable{Float64}},
                                     bc::BoundaryCondition)
    residual[1] = computeResidual(bc)

    for v in vars
        var_jacobians[v.id] = computeJacobian(bc, v)
    end
end

" Compute the Residual and Jacobian using Automatic Differentiation "
function computeResidualAndJacobian!{N,T}(residual::Array{Dual{N,T}},
                                          var_jacobians::Array{Float64},
                                          vars::Array{Variable{Dual{N,T}}},
                                          bc::BoundaryCondition)
    residual[1] = computeResidual(bc)

    for v in vars
        var_jacobians[v.id] = partials(residual[1])[v.id]
    end
end
