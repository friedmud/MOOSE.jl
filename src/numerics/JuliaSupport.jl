# This file extends / overrides some of the Julia basic capability for linear algebra to add useful things for FE
# Most of the time these are "in-place" operations that Julia doesn't normally have an interface for, but we need.
# Also: these functions help us have a common interface with PETSc (which has more in-place capability than Julia)

"""
    Set all entries to zero
"""
function zero!(v)
    fill!(v, 0.)
end

"""
    v[i] += u
"""
function plusEquals!(v::Array, u::Array, i)
    v[i] += u
end

"""
    mat[i,j] += u
"""
function plusEquals!(mat::Matrix, u::Matrix, i, j)
    mat[i,j] += u
end

"""
    Zero rows in the matrix
"""
function zeroRows!(mat::Matrix, rows::Array)
    mat[rows,:] = 0
end

"""
    No-op (no need to assemble Julia objects)
"""
function assemble!(::Any)
end

"""
    Pass through
"""
function serializeToZero(array::Array)
    return array
end
