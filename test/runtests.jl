using JuAFEM
using MOOSE

using ForwardDiff
using ForwardDiff: Partials, Dual, value, partials, npartials, setindex

using Base.Test

if MPI.Comm_size(MPI.COMM_WORLD) == 1
#    include("test_Node.jl")
#    include("test_Element.jl")
#    include("test_Generation.jl")
#    include("test_Variable.jl")
#    include("test_System.jl")
#    include("test_Solver.jl")
#    include("test_Kernel.jl")
#    include("test_Assembly.jl")
#
#    include("test_Diffusion.jl")
#
#    include("test_DirichletBC.jl")
#
#    include("test_VTKOutput.jl")
#
#    include("test_JuliaDenseImplicitSolver.jl")
#
#    if MOOSE.have_petsc
#       include("test_PetscImplicitSolver.jl")
#    end
#
#    include("test_Mesh.jl")
#    include("test_PerfLog.jl")
    include("test_XDAReader.jl")
end

if MPI.Comm_size(MPI.COMM_WORLD) == 2
#    include("test_parallel_Mesh.jl")
#    include("test_parallel_System.jl")
end

if MOOSE.have_petsc
#   include("test_MetisPartitioner.jl")
end