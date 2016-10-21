"""
    A Solver takes a System and solves it.
"""
abstract Solver

" Should be overriden by the Solver implementations to initialize their data "
function initialize!(solver::Solver)
end

" Must be overriden by Solver implementations to actually do the solve "
function solve!(solver::Solver)
    throw(MethodError(solve!, solver))
end
