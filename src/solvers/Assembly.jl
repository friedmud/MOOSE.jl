"""
    Assemble Jacobian and Residual
"""
function assembleResidualAndJacobian(solver::Solver)
    sys = solver.system
    mesh = sys.mesh

    solution = solver.solution

    n_vars = length(sys.variables)

    # Each inner array is of length n_dofs for each var
    var_residuals = Array{Array{Float64}}(n_vars)
    fill!(var_residuals, Array{Float64}(0))

    # Each inner matrix is i_n_dofs * j_n_dofs
    var_jacobians = Array{Matrix{Float64}}(n_vars)
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
            computeResidualAndJacobian!(var_residuals[kernel.u.id], var_jacobians[kernel.u.id], kernel)
        end

        # Scatter those entries back out into the Residual and Jacobian
        for i_var in sys.variables
            solver.rhs[i_var.dofs] += var_residuals[i_var.id]

            for j_var in sys.variables
                solver.mat[i_var.dofs, j_var.dofs] += var_jacobians[i_var.id, j_var.id]
            end
        end
    end
end
