"""
    All objects that can be assigned degrees of freedom should be subtypes of this.
"""
abstract DofObject
    # id::Int64
    # dofs::Array{T}
    # processor_id::Int64

"Return the list of dofs on this DofObject"
function dofs(dof_object::DofObject)
    return dof_object.dofs
end

"Return the processor_id this DofObject is assigned to"
function processor_id(dof_object::DofObject)
    return dof_object.processor_id
end
