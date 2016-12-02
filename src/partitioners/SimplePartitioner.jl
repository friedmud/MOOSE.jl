"""
    Simply cuts the elements up into n_procs chunks
    and assigns them in increasing order based on the
    element IDs

    Note: This is generally a REALLY bad idea!
    (but it will get us going)
"""
abstract SimplePartitioner <: Partitioner

function partition!(mesh::Mesh, ::Type{SimplePartitioner})
    n_procs = MPI.Comm_size(MPI.COMM_WORLD)
    proc_id = MPI.Comm_rank(MPI.COMM_WORLD)

    n_elems = length(mesh.elements)

    n_elems_per_proc = div(n_elems,n_procs)

    # We'll just give the extra elements to the last processor
    extra_elems = rem(n_elems, n_procs)

    elems_on_proc = 0
    current_proc = 0

    # Loop over all of the elements and assign their processor IDs
    for elem in mesh.elements
        elem.processor_id = current_proc

        elems_on_proc += 1

        if elems_on_proc >= n_elems_per_proc && current_proc != n_procs-1
            elems_on_proc = 0
            current_proc += 1
        end
    end

    assignNodeProcessorIDs(mesh)
end
