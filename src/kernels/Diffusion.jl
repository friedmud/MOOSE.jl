" Implements a Diffusion (Laplacian) operator "
type Diffusion <: Kernel
    u::Variable
end

@inline function computeQpResidual(kernel::Diffusion, qp::Integer, i::Integer)
    u = kernel.u

    return u.grad[qp] ⋅ u.grad_phi[qp][i]
end

@inline function computeQpJacobian(kernel::Diffusion, v::Variable, qp::Integer, i::Integer, j::Integer)::Float64
    u = kernel.u

    if u.id == v.id
        return v.grad_phi[qp][j] ⋅ u.grad_phi[qp][i]
    end

    return 0
end

@inline function coupledVars(kernel::Diffusion)::Array{Variable}
    return [kernel.u]
end
