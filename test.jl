push!(LOAD_PATH, "/Users/gastdr/projects/MOOSE.jl/src")

importall MOOSE

elements = Array{Element}()
nodes = Array{Node}()

mesh = Mesh(nodes, elements)
