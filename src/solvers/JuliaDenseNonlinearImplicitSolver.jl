typealias JuliaDenseNonlinearImplicitSolver NonlinearImplicitSolver{Matrix{Float64}, Vector{Float64}, Vector{Float64}}

function JuliaDenseNonlinearImplicitSolver(system::System)
    return JuliaDenseNonlinarImplicitSolver(system, Matrix{Float64}(), Vector{Float64}(), Vector{Float64}(), Vector{Float64}(), false)
end
