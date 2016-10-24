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

function computeResidual!(residual::Vector, kernel::Kernel)
    u = kernel.u
    n_dofs = kernel.u.n_dofs
    n_qp = kernel.u.n_qp

    for qp in 1:n_qp
        for i in 1:n_dofs
            residual[i] += computeQpResidual(kernel, qp, i) * u.JxW[qp]
        end
    end
end

function computeJacobian!(jacobian::Matrix{Float64}, kernel::Kernel, v::Variable{Float64})
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

" Helper function to take a `residual` computed using a Dual and pull the Jacobian out of it "
function pullJacobianFromResidual!{N,T}(jacobian::Matrix{Float64}, residual::Vector{Dual{N,T}}, u::Variable{Dual{N,T}}, v::Variable{Dual{N,T}})
    u_n_dofs = u.n_dofs
    v_n_dofs = v.n_dofs

    # FIXME: Won't work if the number of dofs is different per variable
    partial_offset = (v.id-1) * v_n_dofs;

    for i in 1:u_n_dofs
        for j in 1:v_n_dofs
            jacobian[i,j] += partials(residual[i])[partial_offset + j]
        end
    end
end

"""
    This computes a Jacobian using automatic differentiation.

    However: to do this it must compute a Residual first!
    This is sub-optimal because the residual gets thrown away!
    Only do this in the case where you _only_ want to compute the Jacobian and have no need of the residual!

    If you need both the residual and Jacobian then call `computeResidualAndJacobian!()`
    That will cause the Residual to only be computed once and the Jacobian to be inferred from the result.
"""
function computeJacobian!{N,T}(jacobian::Matrix{Float64}, kernel::Kernel, v::Variable{Dual{N,T}})
    residual = Vector{Dual{N,T}}(kernel.u.n_dofs)

    computeResidual!(residual, kernel)

    pullJacobianFromResidual!(jacobian, residual, kernel.u, v)
end


"""
    Compute both simultaneously.

    Specialization for Float64: Will call `computeJacobian!()` explicitly
"""
function computeResidualAndJacobian!(residual::Vector{Float64},
                                     var_jacobians::Matrix{Matrix{Float64}},
                                     vars::Array{Variable{Float64}},
                                     kernel::Kernel)
    computeResidual!(residual, kernel)

    for v in vars
        computeJacobian!(var_jacobians[kernel.u.id, v.id], kernel, v)
    end
end

"""
    Compute both simultaneously.

    Specialization for Dual: Will use automatic differentiation to compute Jacobian
"""
function computeResidualAndJacobian!{N,T}(residual::Vector,
                                     var_jacobians::Matrix{Matrix{Float64}},
                                     vars::Array{Variable{Dual{N,T}}},
                                     kernel::Kernel)
    this_residual = Vector{Dual{N,T}}(kernel.u.n_dofs)
    for val in this_residual
        val = 0
    end

    computeResidual!(this_residual, kernel)

    residual[:] += this_residual

    for v in vars
        jacobian = var_jacobians[kernel.u.id, v.id]
        pullJacobianFromResidual!(jacobian, this_residual, kernel.u, v)
    end
end

"""
    Compute both simultaneously for all Kernels passed in

    Specialization for Float64: Will end up calling `computeJacobian()`
"""
function computeResidualAndJacobian!(var_residuals::Array{Array{Float64}},
                                     var_jacobians::Matrix{Matrix{Float64}},
                                     vars::Array{Variable{Float64}},
                                     kernels::Array{Kernel})
    for kernel in kernels
        computeResidualAndJacobian!(var_residuals[kernel.u.id], var_jacobians, vars, kernel)
    end
end

"""
    Compute both simultaneously for all Kernels passed in

    Specialization for Dual: Will use automatic differentiation

    This form is here because it's an optimization over doing every Kernel individually
"""
function computeResidualAndJacobian!{N,T}(var_residuals::Array{Array{Dual{N,T}}},
                                     var_jacobians::Matrix{Matrix{Float64}},
                                     vars::Array{Variable{Dual{N,T}}},
                                     kernels::Array{Kernel})
    # Compute all of the residuals
    for kernel in kernels
        computeResidual!(var_residuals[kernel.u.id], kernel)
    end

    # Pull out the Jacobian entries
    for u in vars
        residual = var_residuals[u.id]
        for v in vars
            jacobian = var_jacobians[u.id, v.id]
            pullJacobianFromResidual!(jacobian, residual, u, v)
        end
    end
end
