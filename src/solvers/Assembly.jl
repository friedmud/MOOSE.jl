import Base.convert

# How to convert a Dual to a Float
convert{N,T}(Float64, x::Dual{N,T}) = value(x)

"""
    Assemble Jacobian and Residual
"""
function assembleResidualAndJacobian{T}(solver::Solver, sys::System{T})
    startLog(main_perf_log, "assembleResidualAndJacobian()")

    mesh = sys.mesh

    updateGhostedSolution!(solver)

    solution = solver.ghosted_solution

    vars = sys.variables
    n_vars = length(vars)

    # Reset the Residual and Jacobian
    zero!(solver.rhs)
    zero!(solver.mat)

    # Each inner array is of length n_dofs for each var
    var_residuals = Array{Array{T}}(n_vars)
    for i in 1:n_vars
        var_residuals[i] = Array{T}(0)
    end

    # Each inner matrix is i_n_dofs * j_n_dofs
    var_jacobians = Matrix{Matrix{Float64}}((n_vars, n_vars))
    for i in 1:n_vars
        for j in 1:n_vars
            var_jacobians[i,j] = Matrix{Float64}((0,0))
        end
    end

    # Execute the element loop and accumulate Kernel contributions
    for elem in mesh.local_elements
        reinit!(sys, elem, solution)

        # Resize and zero residual vectors and jacobian matrices
        for i_var in sys.variables
            resize!(var_residuals[i_var.id], i_var.n_dofs)
            fill!(var_residuals[i_var.id], 0.)

            for j_var in sys.variables
                # Because for some inexplicable reason Julia doesn't provide a resize!() for Matrices...
                if size(var_jacobians[i_var.id, j_var.id]) != (i_var.n_dofs, j_var.n_dofs)
                    var_jacobians[i_var.id, j_var.id] = Matrix{Float64}((i_var.n_dofs, j_var.n_dofs))
                end

                fill!(var_jacobians[i_var.id, j_var.id], 0.)
            end
        end

        # Get the Residual/Jacobian contributions from all Kernels
        computeResidualAndJacobian!(var_residuals, var_jacobians, vars, sys.kernels)

        # Scatter those entries back out into the Residual and Jacobian
        for i_var in sys.variables
            plusEquals!(solver.rhs, var_residuals[i_var.id], i_var.dofs)

            for j_var in sys.variables
                plusEquals!(solver.mat, var_jacobians[i_var.id, j_var.id], i_var.dofs, j_var.dofs)
            end
        end
    end

    assemble!(solver.mat)
    assemble!(solver.rhs)

    # Now apply BCs

    boundary_info = mesh.boundary_info
    bcs = sys.bcs

    # First: get the set of boundary IDs we need to operate on:
    bids = Set{Int64}()
    for bc in bcs
        union!(bids, bc.bids)
    end

    # Reusable storage for calling residual and jacobian calculations on NodalBCs
    temp_residual = Array{T}(1)
    temp_jacobian = Array{Float64}(n_vars)

    rows_to_zero = []

    entries_in_bc_rows= []

    proc_id = MPI.Comm_rank(MPI.COMM_WORLD)

    # Now go over each nodeset and apply the BCs
    for bid in bids

        # Grab the nodeset for this bid
        node_list = boundary_info.node_list[bid]

        # Iterate over each node and apply the boundary conditions
        for node in node_list
            if node.processor_id == proc_id
                reinit!(sys, node, solution)

                # Apply all of the BCs that should be applied here
                for bc in bcs
                    if bid in bc.bids
                        computeResidualAndJacobian!(temp_residual, temp_jacobian, vars, bc)

                        # First set the residual
                        solver.rhs[bc.u.nodal_dof] = temp_residual[1]

                        # Now - we need to zero out the row in the matrix corresponding to this dof
                        push!(rows_to_zero, bc.u.nodal_dof)

                        # And put this piece in place
                        for v in vars
                            #solver.mat[bc.u.nodal_dof,v.nodal_dof] = temp_jacobian[v.id]
                            push!(entries_in_bc_rows, (bc.u.nodal_dof,v.nodal_dof,temp_jacobian[v.id]))
                        end
                    end
                end
            end
        end
    end

    zeroRows!(solver.mat, rows_to_zero)
    assemble!(solver.mat)

    for entry in entries_in_bc_rows
        solver.mat[entry[1], entry[2]] = entry[3]
    end

    assemble!(solver.mat)
    assemble!(solver.rhs)

    stopLog(main_perf_log, "assembleResidualAndJacobian()")
end
