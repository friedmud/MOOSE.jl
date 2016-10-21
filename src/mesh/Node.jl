include("DofObject.jl")

"Represents a point in physical space"
type Node <: DofObject
  "x,y,z coordinates"
  coords::Array{Float64}

  "Degrees of freedom assigned to this Node"
  dofs::Array{Int64}
end
