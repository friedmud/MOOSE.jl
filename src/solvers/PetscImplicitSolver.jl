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

    PetscImplicitSolver(system::System) = new(system, PetscMat(), PetscVec(), PetscVec(), false)
end


" Initializes the matrix and rhs to the correct size "
function initialize!(solver::PetscImplicitSolver)
    @assert solver.system.initialized

    n_dofs = solver.system.n_dofs


    setSize!(solver.mat, m_local=(Int32)(n_dofs), n_local=(Int32)(n_dofs))
    setPreallocation!(solver.mat, (Int32)[9 for i in 1:n_dofs], (Int32)[0 for i in 1:n_dofs])

    setSize!(solver.rhs, n_local=(Int32)(n_dofs))
    setSize!(solver.solution, n_local=(Int32)(n_dofs))

    solver.initialized = true
end

"""
    Solve using the built-in dense matrix/vector types

    `assemble` controls whether or not the system will be assembled automatically
"""
function solve!(solver::PetscImplicitSolver; assemble=true)
    if !solver.initialized
        initialize!(solver)
    end

    if assemble
        assembleResidualAndJacobian(solver, solver.system)
    end

    assemble!(solver.solution)

    # Solve the system
    ksp = PetscKSP()
    setOperators(ksp, solver.mat)
    scale!(solver.rhs, -1.0)
    solve!(ksp, solver.rhs, solver.solution)
end
