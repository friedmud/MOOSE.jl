module MOOSE

using JuAFEM

export dofs

export Node, Element, Mesh

export buildSquare

export Variable, System, addVariable!, initialize!

export Solver, solve!

include("mesh/Mesh.jl")
include("mesh/Generation.jl")
include("systems/System.jl")
include("solvers/Solver.jl")

end
