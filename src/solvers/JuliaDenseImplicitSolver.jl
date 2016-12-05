" Linear solver that uses the built-in linear algebra capabilities "
type JuliaDenseImplicitSolver <: DenseImplicitSolver
    " The System the solve will be done for "
    system::System

    " The 'stiffness matrix' "
    mat::Matrix{Float64}

    " The RHS (force vector) "
    rhs::Vector{Float64}

    " The solution vector "
    solution::Vector{Float64}

    " The ghosted solution vector (for Assembly) "
    ghosted_solution::Vector{Float64}

    " Whether or not this Solver has been initialized "
    initialized::Bool

    JuliaDenseImplicitSolver(system::System) = new(system, Matrix{Float64}(), Vector{Float64}(), Vector{Float64}(), Vector{Float64}(), false)
end

"""
    Solve using the built-in dense matrix/vector types

    `assemble` controls whether or not the system will be assembled automatically
"""
function solve!(solver::JuliaDenseImplicitSolver; assemble=true)
    if !solver.initialized
        initialize!(solver)
    end

    if assemble
        assembleResidualAndJacobian(solver, solver.system)
    end

    # Direct solve
    solver.solution = \(solver.mat, -solver.rhs)
end
