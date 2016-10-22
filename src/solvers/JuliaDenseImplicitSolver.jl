" Linear solver that uses the built-in linear algebra capabilities "
type JuliaDenseImplicitSolver <: Solver
    " The System the solve will be done for "
    system::System

    " The 'stiffness matrix' "
    mat::Matrix{Float64}

    " The RHS (force vector) "
    rhs::Vector{Float64}

    " The solution vector "
    solution::Vector{Float64}

    " Whether or not this Solver has been initialized "
    initialized::Bool

    JuliaDenseImplicitSolver(system::System) = new(system, Matrix{Float64}(), Vector{Float64}(), Vector{Float64}(), false)
end

" Initializes the matrix and rhs to the correct size "
function initialize!(solver::JuliaDenseImplicitSolver)
    @assert solver.system.initialized

    n_dofs = solver.system.n_dofs

    solver.mat = zeros(Float64, n_dofs, n_dofs)
    solver.rhs = zeros(Float64, n_dofs)
    solver.solution = zeros(Float64, n_dofs)

    solver.initialized = true
end

" Solve using the built-in dense matrix/vector types "
function solve!(solver::JuliaDenseImplicitSolver)
    @assert solver.initialized

    # Direct solve
    solver.solution = \(solver.mat, solver.rhs)
end
