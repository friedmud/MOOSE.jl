" Linear solver that uses the built-in linear algebra capabilities "
type JuliaDenseNonlinearImplicitSolver <: DenseImplicitSolver
    " The System the solve will be done for "
    system::System

    " The 'stiffness matrix' "
    mat::Matrix{Float64}

    " The RHS (force vector) "
    rhs::Vector{Float64}

    " The current solution vector "
    solution::Vector{Float64}

    " Whether or not this Solver has been initialized "
    initialized::Bool

    JuliaDenseNonlinearImplicitSolver(system::System) = new(system, Matrix{Float64}(), Vector{Float64}(), Vector{Float64}(), false)
end

"""
    Solve using the built-in dense matrix/vector types

    `nl_max_its`: Maximum number of nonlinear iterations to attempt before giving up
    `nl_rel_tol`: Relative nonlinear residual L2-Norm drop tolerance
    `nl_abs_tol`: Absolute nonlinear residual L2-Norm tolerance
"""
function solve!(solver::JuliaDenseNonlinearImplicitSolver; nl_max_its=10, nl_rel_tol=1e-8, nl_abs_tol=1e-20)
    if !solver.initialized
        initialize!(solver)
    end

    initial_residual = 0.0

    # The thing being solved for
    delta = similar(solver.solution)

    # Newton loops
    for i in 1:nl_max_its
        assembleResidualAndJacobian(solver, solver.system)

        current_residual_norm = norm(solver.rhs)

        # First iteration save off the residual
        if i == 1
            initial_residual = current_residual_norm
        end

        println(i, " NL |R|: ", current_residual_norm, ", |R|/|R1|: ", current_residual_norm / initial_residual)

        if current_residual_norm / initial_residual < nl_rel_tol
            println("Relative Tolerance Reached!")
            return
        end

        if current_residual_norm < nl_abs_tol
            println("Absolute Tolerance Reached!")
            return
        end

        print("  Starting Solve... ")
        flush(STDOUT)

        # Direct solve
        delta = \(solver.mat, -solver.rhs)
        println("Done.")

        solver.solution += delta
    end

    println("Warning!! Solve did NOT converge to within the set tolerances!")
end
