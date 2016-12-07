"""
    Keeps track of timing information
"""
type PerfLog
    " The times for each portion of the code in seconds "
    times::Dict{String, Float64}

    PerfLog() = new(Dict{String, Float64}())
end

import Base.clear!

"""
    Clear the entire log and start from scratch
"""
function clear!(perf_log::PerfLog)
    perf_log.times = Dict{String, Float64}()
end

"""
    Start logging for a particular log_entry name
"""
function startLog(perf_log::PerfLog, log_entry::String)
    tic()

    if !(log_entry in keys(perf_log.times))
        perf_log.times[log_entry] = 0.
    end

    perf_log.times[log_entry]
end


"""
    Stop logging for a particular log_entry name
"""
function stopLog(perf_log::PerfLog, log_entry::String)
    perf_log.times[log_entry] += toq()
end

import Base.show

"""
    Print everything out
"""
function show(io::IO, perf_log::PerfLog)
    println("Timing:")
    for key_val in perf_log.times
        println(" ", key_val[1], ": ", key_val[2], "s")
    end
end
