__precompile__()

module MOOSE

using ContMechTensors

using WriteVTK
using JuAFEM

using ForwardDiff
using ForwardDiff: Partials, Dual, value, partials, npartials, setindex, convert
export Dual

using Reexport

const have_petsc = "PETSC_DIR" in keys(ENV)

if have_petsc
    @reexport using MiniPETSc

    import MiniPETSc.assemble!
    import MiniPETSc.solve!
    import MiniPETSc.zero!
    import MiniPETSc.plusEquals!
    import MiniPETSc.zeroRows!
    import MiniPETSc.serializeToZero
else
    import DummyMPI
    MPI = DummyMPI
    export MPI
end

export dofs, processor_id

export Node, Element, Mesh

export buildSquare, readXDAMesh

export Variable, System, addVariable!, addKernel!, addBC!, initialize!

export Solver, solve!, JuliaDenseImplicitSolver, JuliaDenseNonlinearImplicitSolver

if have_petsc
    export PetscImplicitSolver, PetscNonlinearImplicitSolver
end

export Kernel, Diffusion, Convection

export boundaryIDs, DirichletBC

export output, VTKOutput

export invalid_processor_id


# The default value type that will be used by MOOSE.jl
value_type = Float64

# Constructor for making a Dual with a particular value and index
dualVariable{T}(value::T, index::Int64, num_partials::Int64) = Dual(value, Partials(ntuple(n -> n != index ? zero(Float64) : 1.0, num_partials)))

const invalid_processor_id = -1

include("utils/PerfLog.jl")

export PerfLog, startRootLog!, stopRootLog!, startLog, stopLog, clear!

main_perf_log = PerfLog()

export main_perf_log

function finalize()
    println(main_perf_log)

    if !have_petsc
        MPI.Finalize()
    end
end

function __init__()
    if !have_petsc
        MPI.Init()
    end

    atexit(finalize)
end

include("numerics/JuliaSupport.jl")
include("mesh/DofObject.jl")
include("mesh/Node.jl")
include("mesh/Element.jl")
include("mesh/BoundaryInfo.jl")
include("mesh/Mesh.jl")
include("mesh/Generation.jl")
include("mesh/XDAReader.jl")
include("partitioners/Partitioner.jl")
include("partitioners/SimplePartitioner.jl")

if have_petsc
    include("partitioners/MetisPartitioner.jl")
end

include("mesh/MeshInitialization.jl")
include("systems/Variable.jl")
include("kernels/Kernel.jl")
include("bcs/BoundaryCondition.jl")
include("systems/System.jl")
include("solvers/Solver.jl")
include("solvers/Assembly.jl")
include("outputs/Output.jl")

include("solvers/JuliaDenseImplicitSolver.jl")
include("solvers/JuliaDenseNonlinearImplicitSolver.jl")

if have_petsc
    include("solvers/PetscImplicitSolver.jl")
    include("solvers/PetscNonlinearImplicitSolver.jl")
end

include("kernels/Diffusion.jl")
include("kernels/Convection.jl")

include("bcs/DirichletBC.jl")

include("outputs/VTKOutput.jl")

end
