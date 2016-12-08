"""
    Holds the time for one entry and possibly a number of sub-timing entries
"""
type TimingEntry
    " Time in seconds"
    time::Float64

    " Timing for sub-tasks "
    sub_timing_entries::Dict{String, TimingEntry}

    TimingEntry() = new(0., Dict{String, TimingEntry}())
end

"""
    Keeps track of timing information
"""
type PerfLog
    root::TimingEntry

    timing_queue::Array{TimingEntry}

    " Whether or not the root timing has been started "
    root_started::Bool

    PerfLog() = new(TimingEntry(), Array{TimingEntry}(0), false)
end

import Base.clear!

"""
    Clear the entire log and start from scratch
"""
function clear!(perf_log::PerfLog)
    @assert length(perf_log.timing_queue) == 0

    perf_log.root = TimingEntry()

    root_started = false
end

"""
    Start logging for the root time

    Note: MUST be called before any other logging can be done!
"""
function startRootLog!(perf_log::PerfLog)
    push!(perf_log.timing_queue, perf_log.root)

    perf_log.root_started = true

    tic()
end

"""
    Stop logging for the root time
"""
function stopRootLog!(perf_log::PerfLog)
    @assert perf_log.root_started == true
    @assert length(perf_log.timing_queue) == 1 # Should only have the root node in there

    perf_log.root_started = false

    stopLog(perf_log, "root")
end

"""
    Start logging for a particular log_entry name
"""
function startLog(perf_log::PerfLog, log_entry::String)
    current_timing_entries = perf_log.timing_queue[end].sub_timing_entries

    if !(log_entry in keys(current_timing_entries))
        current_timing_entries[log_entry] = TimingEntry()
    end

    push!(perf_log.timing_queue, current_timing_entries[log_entry])

    tic()
end


"""
    Stop logging for a particular log_entry name
"""
function stopLog(perf_log::PerfLog, log_entry::String)
    perf_log.timing_queue[end].time += toq()

    pop!(perf_log.timing_queue)
end

import Base.show

"""
    Small helper function for show()
"""
function showHelper(timing_entry::TimingEntry, level::Int64, root_time::Float64)
    for key_val in timing_entry.sub_timing_entries
        println("  "^level, key_val[1], ": ", round(key_val[2].time, 2), " (", round((key_val[2].time / root_time)*100, 2), "%)")
        showHelper(key_val[2], level+1, root_time)
    end
end

"""
    Print everything out
"""
function show(io::IO, perf_log::PerfLog)
    if MPI.Comm_rank(MPI.COMM_WORLD) != 0
        return
    end

    println("Timing:")

    @assert perf_log.root_started == false

    root_time = perf_log.root.time

    println("  Total: ", root_time)

    showHelper(perf_log.root, 2, root_time)
end
