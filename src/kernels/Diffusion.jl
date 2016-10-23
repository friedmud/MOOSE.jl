" Implements a Diffusion (Laplacian) operator "
type Diffusion <: Kernel
    u::Variable
end

function computeQpResidual(kernel::Diffusion, qp::Int64, i::Int64)
    u = kernel.u

    return u.grad[qp] ⋅ u.grad_phi[qp][i]
end

function computeQpJacobian(kernel::Diffusion, v::Variable, qp::Int64, i::Int64, j::Int64)
    u = kernel.u

    if u.id == v.id
        return v.grad_phi[qp][j] ⋅ u.grad_phi[qp][i]
    end

    return 0
end
