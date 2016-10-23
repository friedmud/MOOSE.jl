__precompile__()

module MOOSE

using Reexport

@reexport using ContMechTensors
using WriteVTK
using JuAFEM

using ForwardDiff
using ForwardDiff: Partials, Dual, value, partials, npartials, setindex

export dofs

export Node, Element, Mesh

export buildSquare

export Variable, System, addVariable!, addKernel!, addBC!, initialize!

export Solver, solve!, JuliaDenseImplicitSolver, JuliaDenseNonlinearImplicitSolver

export Kernel, Diffusion, Convection

export boundaryIDs, DirichletBC

export output, VTKOutput

# The default value type that will be used by MOOSE.jl
value_type = Float64

include("mesh/DofObject.jl")
include("mesh/Node.jl")
include("mesh/Element.jl")
include("mesh/BoundaryInfo.jl")
include("mesh/Mesh.jl")
include("mesh/Generation.jl")
include("systems/Variable.jl")
include("kernels/Kernel.jl")
include("bcs/BoundaryCondition.jl")
include("systems/System.jl")
include("solvers/Solver.jl")
include("solvers/Assembly.jl")
include("outputs/Output.jl")

include("solvers/JuliaDenseImplicitSolver.jl")
include("solvers/JuliaDenseNonlinearImplicitSolver.jl")

include("kernels/Diffusion.jl")
include("kernels/Convection.jl")

include("bcs/DirichletBC.jl")

include("outputs/VTKOutput.jl")

end
