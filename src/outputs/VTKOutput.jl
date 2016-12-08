" Outputs the unstructured mesh with the solution fields "
type VTKOutput <: Output
end

"""
    Create the lists of Cells and Points for Outputting VTK

    Returns a tuple of `cells, points`
"""
function createVTKGeometry(mesh::Mesh)
    # Create the cells
    elems = mesh.elements
    n_elem = length(elems)

    cells = Array{MeshCell}(n_elem)

    for i in 1:n_elem
        elem = mesh.elements[i]
        cells[i] = MeshCell(VTKCellTypes.VTK_QUAD, [ node.id for node in elem.nodes ])
    end

    # Create the Points array
    nodes = mesh.nodes
    n_nodes = length(nodes)

    points = Matrix{Float64}((2, n_nodes))

    for i in 1:n_nodes
        node = mesh.nodes[i]
        points[1,i] = node.coords[1]
        points[2,i] = node.coords[2]
    end

    return cells, points
end

"""
    Creates the point data suitable for outputing to VTK

    returns a Dict{VariableName, Array{Float64}}
"""
function createPointData(solver::Solver, solution::Array)
    # One entry per variable
    point_data = Dict{String, Array{Float64}}()

    sys = solver.system
    mesh = sys.mesh
    nodes = mesh.nodes
    n_nodes = length(nodes)

    for var in sys.variables
        id = var.id
        data = Array{Float64}(n_nodes)

        for i in 1:n_nodes
            data[i] = solution[mesh.nodes[i].dofs[id]]
        end

        point_data[var.name] = data
    end

    return point_data
end

" Write out a VTK file "
function output(out::VTKOutput, solver::Solver, filebase::String)
    startLog(main_perf_log, "output(VTKOutput)")

    serialized_solution = serializeToZero(solver.solution)

    if MPI.Comm_rank(MPI.COMM_WORLD) == 0
        cells, points = createVTKGeometry(solver.system.mesh)

        vtkfile = vtk_grid(filebase, points, cells)

        point_data = createPointData(solver, serialized_solution)

        for name_data in point_data
            vtk_point_data(vtkfile, name_data[2], name_data[1])
        end

        outfiles = vtk_save(vtkfile)
    end

    stopLog(main_perf_log, "output(VTKOutput)")
end
