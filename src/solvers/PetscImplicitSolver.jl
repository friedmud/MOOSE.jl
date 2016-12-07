" Linear solver that uses PETSc "
type PetscImplicitSolver <: DenseImplicitSolver
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

    PetscImplicitSolver(system::System) = new(system, PetscMat(), PetscVec(), PetscVec(), false)
end


" Initializes the matrix and rhs to the correct size "
function initialize!(solver::PetscImplicitSolver)
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
function updateGhostedSolution!(solver::PetscImplicitSolver)
    copy!(solver.ghosted_solution, solver.solution)
end

"""
    Solve using the built-in dense matrix/vector types

    `assemble` controls whether or not the system will be assembled automatically
"""
function solve!(solver::PetscImplicitSolver; assemble=true)
    startLog(main_perf_log, "solve()")

    if !solver.initialized
        initialize!(solver)
    end

    if assemble
        if MPI.Comm_rank(MPI.COMM_WORLD) == 0
            assembleResidualAndJacobian(solver, solver.system)
        else
            assembleResidualAndJacobian(solver, solver.system)
        end
    end

    assemble!(solver.solution)

    # Solve the system
    ksp = PetscKSP()
    setOperators(ksp, solver.mat)
    scale!(solver.rhs, -1.0)
    startLog(main_perf_log, "linear_solve")
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0
        solve!(ksp, solver.rhs, solver.solution)
    else
        solve!(ksp, solver.rhs, solver.solution)
    end
    stopLog(main_perf_log, "linear_solve")

    stopLog(main_perf_log, "solve()")
end
