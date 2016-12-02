__precompile__()

module MOOSE

using Reexport

@reexport using ContMechTensors
using WriteVTK
using JuAFEM

using ForwardDiff
using ForwardDiff: Partials, Dual, value, partials, npartials, setindex, convert
export Dual

using MiniPETSc

import MiniPETSc.assemble!
import MiniPETSc.solve!
import MiniPETSc.zero!
import MiniPETSc.plusEquals!
import MiniPETSc.zeroRows!

export dofs

export Node, Element, Mesh

export buildSquare

export Variable, System, addVariable!, addKernel!, addBC!, initialize!

export Solver, solve!, JuliaDenseImplicitSolver, JuliaDenseNonlinearImplicitSolver, PetscImplicitSolver

export Kernel, Diffusion, Convection

export boundaryIDs, DirichletBC

export output, VTKOutput



# The default value type that will be used by MOOSE.jl
value_type = Float64

# Constructor for making a Dual with a particular value and index
dualVariable{T}(value::T, index::Int64, num_partials::Int64) = Dual(value, Partials(ntuple(n -> n != index ? zero(Float64) : 1.0, num_partials)))

include("numerics/JuliaSupport.jl")
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
include("solvers/PetscImplicitSolver.jl")

include("kernels/Diffusion.jl")
include("kernels/Convection.jl")

include("bcs/DirichletBC.jl")

include("outputs/VTKOutput.jl")

end
