"""
    A Kernel represents one (or more) volume integral terms in the weak form of a PDE

    All Kernels _must_ have a member variable named `u` that is of type Variable.
    That `Variable` is the one being operated on by this Kernel
"""
abstract Kernel
    #u::Variable

"""
    Required to be overrdien!

    Inherited types should fill in the Residual vector
"""
function computeQpResidual(residual::Vector{Float64}, kernel::Kernel, qp::Int64, i::Int64)
    throw(MethodError(computeQpResidual!, residual, kernel))
end

"""
    Should be overridden!

    Inherited types should fill in the Jacobian vector

    Computes the derivative of the residual for `kernel` WRT the variable `v`
    and stores it in `jacobian`
"""
function computeQpJacobian!(jacobian::Matrix{Float64}, kernel::Kernel, v::Variable, qp::Int64, i::Int64, j::Int64)
end

function computeResidual!(residual::Vector{Float64}, kernel::Kernel)
    u = kernel.u
    n_dofs = kernel.u.n_dofs
    n_qp = kernel.u.n_qp

    for qp in 1:n_qp
        for i in 1:n_dofs
            residual[i] += computeQpResidual(kernel, qp, i) * u.JxW[qp]
        end
    end
end

function computeJacobian!(jacobian::Matrix{Float64}, kernel::Kernel, v::Variable)
    u = kernel.u
    u_n_dofs = kernel.u.n_dofs
    n_qp = kernel.u.n_qp

    v_n_dofs = v.n_dofs

    # Derivative of the residual WRT the variable it's acting on
    for qp in 1:n_qp
        for i in 1:u_n_dofs
            for j in 1:v_n_dofs
                jacobian[i,j] += computeQpJacobian(kernel, v, qp, i, j) * u.JxW[qp]
            end
        end
    end
end


"""
    Compute both simultaneously.

    Overridden versions can be more efficient
"""
function computeResidualAndJacobian!(residual::Vector{Float64}, jacobian::Matrix{Float64}, kernel::Kernel)
    computeResidual!(residual, kernel)
    computeJacobian!(jacobian, kernel, kernel.u)
end
