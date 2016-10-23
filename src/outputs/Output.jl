" An `Output` writes out some data from the simulation "
abstract Output

" These `Outputs` write out to files "
abstract FileOutput <: Output

" MUST be overriden for each type of `FileOutput` object "
function output(out::FileOutput, solver::Solver, filebase::String)
    throw(MethodError(output!, out))
end
