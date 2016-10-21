module MOOSE

using JuAFEM

export Node, Element, Mesh
export buildSquare

include("mesh/Mesh.jl")
include("mesh/Generation.jl")

end
