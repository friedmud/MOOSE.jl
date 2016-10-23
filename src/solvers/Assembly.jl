"""
    Assemble Jacobian and Residual
"""
function assembleResidualAndJacobian(solver::Solver)
    sys = solver.system
    mesh = sys.mesh

    solution = solver.solution

    vars = sys.variables
    n_vars = length(vars)

    # Reset the Residual and Jacobian
    fill!(solver.rhs, 0.)
    fill!(solver.mat, 0.)

    # Each inner array is of length n_dofs for each var
    var_residuals = Array{Array{Float64}}(n_vars)
    fill!(var_residuals, Array{Float64}(0))

    # Each inner matrix is i_n_dofs * j_n_dofs
    var_jacobians = Matrix{Matrix{Float64}}((n_vars, n_vars))
    fill!(var_jacobians, Matrix{Float64}((0,0)))

    # Execute the element loop and accumulate Kernel contributions
    for elem in mesh.elements
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

        # Get the Residual/Jacobian contributions from each Kernel
        for kernel in sys.kernels
            computeResidualAndJacobian!(var_residuals[kernel.u.id], var_jacobians, vars, kernel)
        end

        # Scatter those entries back out into the Residual and Jacobian
        for i_var in sys.variables
            solver.rhs[i_var.dofs] += var_residuals[i_var.id]

            for j_var in sys.variables
                solver.mat[i_var.dofs, j_var.dofs] += var_jacobians[i_var.id, j_var.id]
            end
        end
    end

    # Now apply BCs

    boundary_info = mesh.boundary_info
    bcs = sys.bcs

    # First: get the set of boundary IDs we need to operate on:
    bids = Set{Int64}()
    for bc in bcs
        union!(bids, bc.bids)
    end

    # Reusable storage for calling residual and jacobian calculations on NodalBCs
    temp_residual = Array{Float64}(1)
    temp_jacobian = Array{Float64}(n_vars)

    # Now go over each nodeset and apply the BCs
    for bid in bids

        # Grab the nodeset for this bid
        node_list = boundary_info.node_list[bid]

        # Iterate over each node and apply the boundary conditions
        for node in node_list
            reinit!(sys, node, solution)

            # Apply all of the BCs that should be applied here
            for bc in bcs
                if bid in bc.bids
                    computeResidualAndJacobian!(temp_residual, temp_jacobian, vars, bc)

                    # First set the residual
                    solver.rhs[bc.u.nodal_dof] = temp_residual[1]

                    # Now - we need to zero out the row in the matrix corresponding to this dof
                    solver.mat[bc.u.nodal_dof,:] = 0

                    # And put this piece in place
                    for v in vars
                        solver.mat[bc.u.nodal_dof,v.nodal_dof] = temp_jacobian[v.id]
                    end
                end
            end
        end
    end
end
