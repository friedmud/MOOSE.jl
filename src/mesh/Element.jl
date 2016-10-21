include("DofObject.jl")
include("Node.jl")

"""
  An element is a physical (geometrical) element in space
"""
type Element <: DofObject
  "The nodes that make up the physical position"
  nodes::Array{Node}

  "Degrees of freedom assigned to this Element"
  dofs::Array{Int64}
end
