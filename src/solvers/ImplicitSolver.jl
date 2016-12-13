" Solvers that solve using a matrix and rhs "
abstract ImplicitSolver <: Solver

" Linear solver "
type LinearImplicitSolver{mat_T, vec_T, ghosted_vec_T} <: ImplicitSolver
    " The System the solve will be done for "
    system::System

    " Whether or not this Solver has been initialized "
    initialized::Bool

    " The 'stiffness matrix' "
    mat::mat_T

    " The RHS (force vector) "
    rhs::vec_T

    " The solution vector "
    solution::vec_T

    " The ghosted solution vector (for Assembly) "
    ghosted_solution::ghosted_vec_T

    LinearImplicitSolver{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat::mat_T, rhs::vec_T, solution::vec_T, ghosted_solution::ghosted_vec_T) = new{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat, rhs, solution, ghosted_solution)

    " Allow for leaving ghosted_solution undefined "
    LinearImplicitSolver{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat::mat_T, rhs::vec_T, solution::vec_T, ::Type{ghosted_vec_T}) = new{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat, rhs, solution)
end


" Nonlinear solver "
type NonlinearImplicitSolver{mat_T, vec_T, ghosted_vec_T} <: ImplicitSolver
    " The System the solve will be done for "
    system::System

    " Whether or not this Solver has been initialized "
    initialized::Bool

    " The 'stiffness matrix' "
    mat::mat_T

    " The RHS (force vector) "
    rhs::vec_T

    " The solution vector "
    solution::vec_T

    " The ghosted solution vector (for Assembly) "
    ghosted_solution::ghosted_vec_T

    NonlinearImplicitSolver{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat::mat_T, rhs::vec_T, solution::vec_T, ghosted_solution::ghosted_vec_T) = new{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat, rhs, solution, ghosted_solution)

    " Allow for leaving ghosted_solution undefined "
    NonlinearImplicitSolver{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat::mat_T, rhs::vec_T, solution::vec_T, ::Type{ghosted_vec_T}) = new{mat_T, vec_T, ghosted_vec_T}(system, initialized, mat, rhs, solution)

end


function updateGhostedSolution!(solver::ImplicitSolver)
    solver.ghosted_solution = solver.solution
end

" Solve a linear system Ax = b "
function solveLinearSystem!(A::AbstractMatrix, x::AbstractVector, b::AbstractVector)
    x .= \(A, -b)
end

"""
    `assemble` controls whether or not the system will be assembled automatically
"""
function solve!(solver::LinearImplicitSolver; assemble=true)
    startLog(main_perf_log, "solve!(LinearImplicitSolver)")

    if !solver.initialized
        initialize!(solver)
    end

    if assemble
        assembleResidualAndJacobian(solver, solver.system)
    end

    startLog(main_perf_log, "linear_solve")
    solveLinearSystem!(solver.mat, solver.solution, solver.rhs)
    stopLog(main_perf_log, "linear_solve")

    stopLog(main_perf_log, "solve!(LinearImplicitSolver)")
end


"""
    Solve using the built-in dense matrix/vector types

    `nl_max_its`: Maximum number of nonlinear iterations to attempt before giving up
    `nl_rel_tol`: Relative nonlinear residual L2-Norm drop tolerance
    `nl_abs_tol`: Absolute nonlinear residual L2-Norm tolerance
"""
function solve!(solver::NonlinearImplicitSolver; nl_max_its=10, nl_rel_tol=1e-8, nl_abs_tol=1e-20)
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
