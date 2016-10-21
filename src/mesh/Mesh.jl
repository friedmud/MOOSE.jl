
include("Node.jl")
include("Element.jl")

type Mesh
  nodes::Array{Node}
  elements::Array{Element}
end
