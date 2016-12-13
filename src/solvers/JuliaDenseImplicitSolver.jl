typealias JuliaDenseImplicitSolver LinearImplicitSolver{Matrix{Float64}, Vector{Float64}, Vector{Float64}}

function JuliaDenseImplicitSolver(system::System)
    return JuliaDenseImplicitSolver(system, false, Matrix{Float64}(), Vector{Float64}(), Vector{Float64}(), Vector{Float64}())
end

" Initializes the matrix and rhs to the correct size "
function initialize!(solver::JuliaDenseImplicitSolver)
    @assert solver.system.initialized

    n_dofs = solver.system.n_dofs

    solver.mat = zeros(Float64, n_dofs, n_dofs)
    solver.rhs = zeros(Float64, n_dofs)
    solver.solution = zeros(Float64, n_dofs)
    solver.ghosted_solution = zeros(Float64, n_dofs)

    solver.initialized = true
end
