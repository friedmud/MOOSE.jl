using MOOSE
using JuAFEM

using Base.Test

include("test_Node.jl")
include("test_Element.jl")
include("test_Generation.jl")
include("test_Variable.jl")
include("test_System.jl")
include("test_Solver.jl")
include("test_JuliaDenseImplicitSolver.jl")
include("test_Kernel.jl")
include("test_Assembly.jl")

include("test_Diffusion.jl")