push!(LOAD_PATH, "/Users/gastdr/projects/MOOSE.jl/src")

importall MOOSE

print(buildSquare(0, 1, 0, 1, 2, 2))

#elements = Array{Element}()
#nodes = Array{Node}()

#mesh = Mesh(nodes, elements)
