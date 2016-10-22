include("Kernel.jl")
include("Variable.jl")

" Implements a Diffusion (Laplacian) operator "
type Diffusion <: Kernel
    u::Variable

    Diffusion(u::Variable) = new(u)
end

function computeResidual!(residual::Vector{Float64}, kernel::Diffusion)
end

function computeJacobian!(jacobian::Matrix{Float64}, kernel::Diffusion)
end
