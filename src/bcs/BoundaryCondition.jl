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
