"""
    Simply cuts the elements up into n_procs chunks
    and assigns them in increasing order based on the
    element IDs

    Note: This is generally a REALLY bad idea!
    (but it will get us going)
"""
abstract MetisPartitioner <: Partitioner

const metis_library = string(ENV["PETSC_DIR"],"/lib/libmetis")

const METIS_NOPTIONS = 40
typealias idx_t Int32

# One based
const METIS_OPTION_PTYPE = 1
const METIS_OPTION_OBJTYPE = 2
const METIS_OPTION_CTYPE = 3
const METIS_OPTION_IPTYPE = 4
const METIS_OPTION_RTYPE = 5
const METIS_OPTION_DBGLVL = 6
const METIS_OPTION_NITER = 7
const METIS_OPTION_NCUTS = 8
const METIS_OPTION_SEED = 9
const METIS_OPTION_NO2HOP = 10
const METIS_OPTION_MINCONN = 11
const METIS_OPTION_CONTIG = 12
const METIS_OPTION_COMPRESS = 13
const METIS_OPTION_CCORDER = 14
const METIS_OPTION_PFACTOR = 15
const METIS_OPTION_NSEPS = 16
const METIS_OPTION_UFACTOR = 17
const METIS_OPTION_NUMBERING = 18

const METIS_PTYPE_RB = 0
const METIS_PTYPE_KWAY = 1

const METIS_OBJTYPE_CUT = 0
const METIS_OBJTYPE_VOL = 1
const METIS_OBJTYPE_NODE = 2

const METIS_IPTYPE_GROW = 0
const METIS_IPTYPE_RANDOM = 1
const METIS_IPTYPE_EDGE = 2
const METIS_IPTYPE_NODE = 3
const METIS_IPTYPE_METISRB = 4

const METIS_CTYPE_RM = 0
const METIS_CTYPE_SHEM = 1

function partition!(mesh::Mesh, ::Type{MetisPartitioner})
    n_procs = MPI.Comm_size(MPI.COMM_WORLD)
    proc_id = MPI.Comm_rank(MPI.COMM_WORLD)

    options = Array{idx_t}(METIS_NOPTIONS)

    ccall((:METIS_SetDefaultOptions, metis_library), Int32, (Ref{idx_t},), options)

#    options[METIS_OPTION_NUMBERING] = 1 # 1-based numbering! Handy!  Well... I ended up doing 0-based because debugging (and the answer needs to be zero based anyway because MPI is)

    # libMesh defaults
    if n_procs <= 8
        options[METIS_OPTION_PTYPE] = METIS_PTYPE_RB
    else
        options[METIS_OPTION_PTYPE] = METIS_PTYPE_KWAY
    end

#    options[METIS_OPTION_IPTYPE] = METIS_IPTYPE_GROW
#    options[METIS_OPTION_OBJTYPE] = METIS_OBJTYPE_CUT
#    options[METIS_OPTION_CTYPE] = METIS_CTYPE_RM
#    options[METIS_OPTION_NCUTS] = 4
#    options[METIS_OPTION_NITER] = 10
#    options[METIS_OPTION_MINCONN] = 0
#    options[METIS_OPTION_UFACTOR] = 1
#    options[METIS_OPTION_DBGLVL] = (idx_t)(1) | (idx_t)(16) | (idx_t)(128) | (idx_t)(256)

    ne = (idx_t)(length(mesh.elements))
    nn = (idx_t)(length(mesh.nodes))

    eptr = Array{idx_t}(ne+1)
    eind = Array{idx_t}(ne*4)

    for elem in mesh.elements
        node_start = (4*(elem.id-1))
        eptr[elem.id] = node_start

        for n in 1:length(elem.nodes)
            eind[node_start + n] = elem.nodes[n].id - 1
        end
    end

    eptr[length(eptr)] = (ne*4)

    # Note!  Weights are required!  Right now it's just 4 (the number of nodes)
    vwgt = Array{idx_t}(ne)
    fill!(vwgt, 4)

    ncommon = (idx_t)(2)
    nparts = (idx_t)(n_procs)
    objval = (idx_t)(0)

    epart = Array{idx_t}(ne)
    npart = Array{idx_t}(nn)

    ret_val = ccall((:METIS_PartMeshDual, metis_library), Int32, (Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ptr{Float64}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}),
                    ne, nn, eptr, eind, vwgt, C_NULL, ncommon, nparts, C_NULL, options, objval, epart, npart)

    # Assign the IDs
    for elem in mesh.elements
        elem.processor_id = epart[elem.id]
    end

#    ret_val = ccall((:METIS_PartMeshNodal, metis_library), Int32, (Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ptr{Float64}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}),
#                    ne, nn, eptr, eind, C_NULL, C_NULL, nparts, C_NULL, options, objval, epart, npart)

    # numflag = 0

    # xadj = Ref{Ptr{idx_t}}()
    # adjncy = Ref{Ptr{idx_t}}()

    # ccall((:METIS_MeshToDual, metis_library), Int32, (Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{Ptr{idx_t}}, Ref{Ptr{idx_t}}),
    #       ne, nn, eptr, eind, ncommon, numflag, xadj, adjncy)

    # xadj_array = unsafe_wrap(Array, xadj[], ne + 1, true)
    # adjncy_array = unsafe_wrap(Array, adjncy[], xadj_array[end], true)

    # println(xadj_array)
    # println(adjncy_array)

    # nvtxs = length(xadj_array) - 1
    # ncon = 1

    # part = Array{idx_t}(nvtxs)

    # vwgt = Array{idx_t}(nvtxs)
    # fill!(vwgt, 4)

    # ret_val = ccall((:METIS_PartGraphRecursive, metis_library), Int32, (Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}, Ptr{Float64}, Ptr{Float64}, Ref{idx_t}, Ref{idx_t}, Ref{idx_t}),
    #                 nvtxs, ncon, xadj_array, adjncy_array, vwgt, C_NULL, C_NULL, nparts, C_NULL, C_NULL, options, objval, part)

    # println(ret_val)
    # println(part)

    assignNodeProcessorIDs(mesh)
end
