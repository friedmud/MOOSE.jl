module MOOSE

using JuAFEM

export dofs

export Node, Element, Mesh

export buildSquare

export System, addVariable!

include("mesh/Mesh.jl")
include("mesh/Generation.jl")
include("systems/System.jl")

end
