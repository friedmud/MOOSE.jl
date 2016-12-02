" Implements a Convection operator "
type Convection <: Kernel
    u::Variable

    velocity::Vec{2, Float64}
end

@inline function computeQpResidual(kernel::Convection, qp::Integer, i::Integer)
    u = kernel.u

    return (kernel.velocity ⋅ u.grad[qp]) * u.phi[qp][i]
end

@inline function computeQpJacobian(kernel::Convection, v::Variable, qp::Integer, i::Integer, j::Integer)::Float64
    u = kernel.u

    if u.id == v.id
        return (kernel.velocity ⋅ v.grad_phi[qp][j]) * u.phi[qp][i]
    end

    return 0
end

@inline function coupledVars(kernel::Convection)::Array{Variable}
    return [kernel.u]
end
