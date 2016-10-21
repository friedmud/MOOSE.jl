"""
  All objects that can be assigned degrees of freedom should be subtypes of this.

  Each DofObject is required to have an Array{T} member variable called `dofs`
"""
abstract DofObject

"Return the list of dofs on this DofObject"
function dofs(dof_object::DofObject)
  return dof_object.dofs
end
