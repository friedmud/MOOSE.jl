"""
    A Solver takes a System and solves it.
"""
abstract Solver

" Should be overridden by the Solver implementations to initialize their data "
function initialize!(solver::Solver)
end

" Must be overriden by Solver implementations to actually do the solve "
function solve!(solver::Solver)
    throw(MethodError(solve!, solver))
end

" Assemble the FE problem "
function assemble!(solver::Solver)
end

" Solvers that solve using a matrix and rhs "
abstract ImplicitSolver <: Solver

" Solvers that use dense matrices "
abstract DenseImplicitSolver <: ImplicitSolver
    # " The System the solve will be done for "
    # system::System

    # " The 'stiffness matrix' "
    # mat::Matrix{Float64}

    # " The RHS (force vector) "
    # rhs::Vector{Float64}

    # " The solution vector "
    # solution::Vector{Float64}

    # " The ghosted solution vector (for Assembly) "
    # ghosted_solution::Vector{Float64}

    # " Whether or not this Solver has been initialized "
    # initialized::Bool

" Initializes the matrix and rhs to the correct size "
function initialize!(solver::DenseImplicitSolver)
    @assert solver.system.initialized

    n_dofs = solver.system.n_dofs

    solver.mat = zeros(Float64, n_dofs, n_dofs)
    solver.rhs = zeros(Float64, n_dofs)
    solver.solution = zeros(Float64, n_dofs)
    solver.ghosted_solution = zeros(Float64, n_dofs)

    solver.initialized = true
end

" Update the ghosted_solution vector from the actual solution "
function updateGhostedSolution!(solver::DenseImplicitSolver)
    solver.ghosted_solution = solver.solution
end
