type PetscNonlinearImplicitSolver <: DenseImplicitSolver
    " The System the solve will be done for "
    system::System

    " The 'stiffness matrix' "
    mat::PetscMat

    " The RHS (force vector) "
    rhs::PetscVec

    " The solution vector "
    solution::PetscVec

    " Whether or not this Solver has been initialized "
    initialized::Bool

    " The ghosted solution vector.  This is last because we're going to leave it unitialized in the beginning. "
    ghosted_solution::GhostedPetscVec

    PetscNonlinearImplicitSolver(system::System) = new(system, PetscMat(), PetscVec(), PetscVec(), false)
end

" Initializes the matrix and rhs to the correct size "
function initialize!(solver::PetscNonlinearImplicitSolver)
    @assert solver.system.initialized

    n_dofs = solver.system.n_dofs

    local_n_dofs = solver.system.local_n_dofs

    setSize!(solver.mat, m_local=(Int32)(local_n_dofs), n_local=(Int32)(local_n_dofs))
    generateSparsity!(solver.system)
    setPreallocation!(solver.mat, solver.system.local_dof_sparsity, solver.system.off_proc_dof_sparsity)

    setSize!(solver.rhs, n_local=(Int32)(local_n_dofs))
    setSize!(solver.solution, n_local=(Int32)(local_n_dofs))

    findGhostedDofs!(solver.system)
    solver.ghosted_solution = GhostedPetscVec(Int32[(Int32)(dof) for dof in solver.system.ghosted_dofs], n_local=(Int32)(local_n_dofs))

    solver.initialized = true
end

" Update the ghosted_solution vector from the actual solution "
function updateGhostedSolution!(solver::PetscNonlinearImplicitSolver)
    copy!(solver.ghosted_solution, solver.solution)
end


"""
    Solve using the built-in dense matrix/vector types

    `nl_max_its`: Maximum number of nonlinear iterations to attempt before giving up
    `nl_rel_tol`: Relative nonlinear residual L2-Norm drop tolerance
    `nl_abs_tol`: Absolute nonlinear residual L2-Norm tolerance
"""
function solve!(solver::PetscNonlinearImplicitSolver; nl_max_its=10, nl_rel_tol=1e-8, nl_abs_tol=1e-20)
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

        if MPI.Comm_rank(MPI.COMM_WORLD) == 0
            println(i, " NL |R|: ", current_residual_norm, ", |R|/|R1|: ", current_residual_norm / initial_residual)
        end

        if current_residual_norm / initial_residual < nl_rel_tol
            if MPI.Comm_rank(MPI.COMM_WORLD) == 0
                println("Relative Tolerance Reached!")
            end
            return
        end

        if current_residual_norm < nl_abs_tol
            if MPI.Comm_rank(MPI.COMM_WORLD) == 0
                println("Absolute Tolerance Reached!")
            end
            return
        end

        if MPI.Comm_rank(MPI.COMM_WORLD) == 0
            println("  Starting Solve... ")
        end

        # Solve the system
        ksp = PetscKSP()
        setOperators(ksp, solver.mat)
        scale!(solver.rhs, -1.0)

        startLog(main_perf_log, "linear_solve")
        solve!(ksp, solver.rhs, delta)
        stopLog(main_perf_log, "linear_solve")

        if MPI.Comm_rank(MPI.COMM_WORLD) == 0
            println("Done.")
        end

        plusEquals!(solver.solution, delta)
    end

    if MPI.Comm_rank(MPI.COMM_WORLD) == 0
        println("Warning!! Solve did NOT converge to within the set tolerances!")
    end
end
