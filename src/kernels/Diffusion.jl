" Implements a Diffusion (Laplacian) operator "
type Diffusion <: Kernel
    u::Variable

    Diffusion(u::Variable) = new(u)
end

function computeResidual!(residual::Vector{Float64}, kernel::Diffusion)
    u = kernel.u
    n_dofs = kernel.u.n_dofs
    n_qp = kernel.u.n_qp

    for qp in 1:n_qp
        for i in 1:n_dofs
            residual[i] += u.grad[qp] ⋅ u.grad_phi[qp][i] * u.JxW[qp]
        end
    end
end

function computeJacobian!(jacobian::Matrix{Float64}, kernel::Diffusion, v::Variable)
    u = kernel.u
    u_n_dofs = kernel.u.n_dofs
    n_qp = kernel.u.n_qp

    v_n_dofs = v.n_dofs

    # Derivative of the residual WRT the variable it's acting on
    if v.id == u.id
        for qp in 1:n_qp
            for i in 1:u_n_dofs
                for j in 1:v_n_dofs
                    jacobian[i,j] += v.grad_phi[qp][j] ⋅ u.grad_phi[qp][i] * u.JxW[qp]
                end
            end
        end
    end
end
