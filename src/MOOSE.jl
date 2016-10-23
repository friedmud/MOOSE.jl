module MOOSE

using JuAFEM
using WriteVTK

export dofs

export Node, Element, Mesh

export buildSquare

export Variable, System, addVariable!, addKernel!, addBC!, initialize!

export Solver, solve!, JuliaDenseImplicitSolver

export Kernel, computeResidual!, computeJacobian!, computeResidualAndJacobian!, Diffusion

export boundaryIDs, DirichletBC

export output, VTKOutput

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
include("solvers/JuliaDenseImplicitSolver.jl")
include("solvers/Assembly.jl")
include("outputs/Output.jl")

include("kernels/Diffusion.jl")

include("bcs/DirichletBC.jl")

include("outputs/VTKOutput.jl")

end
