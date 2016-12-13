typealias PetscImplicitSolver LinearImplicitSolver{PetscMat, PetscVec, GhostedPetscVec}

function PetscImplicitSolver(system::System)
    # Leaves the ghosted_solution undefined on purpose
    return PetscImplicitSolver(system, false, PetscMat(), PetscVec(), PetscVec(), GhostedPetscVec)
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


" Solve a linear system Ax = b "
function solveLinearSystem!(A::PetscMat, x::PetscVec, b::PetscVec)
    assemble!(x)

    # Solve the system
    ksp = PetscKSP()
    setOperators(ksp, A)
    scale!(b, -1.0)

    solve!(ksp, b, x)
end
