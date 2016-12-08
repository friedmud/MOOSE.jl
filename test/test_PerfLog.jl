@testset "PerfLog.jl" begin
    my_log = PerfLog()
    startLog(my_log, "stuff")

    @test "stuff" in keys(my_log.root.sub_timing_entries)
    @test my_log.root.sub_timing_entries["stuff"].time == 0.
    @test length(my_log.timing_queue) == 2 # root and stuff

    startLog(my_log, "junk")

    @test length(my_log.timing_queue) == 3 # root, stuff and junk
    @test "junk" in keys(my_log.root.sub_timing_entries["stuff"].sub_timing_entries)

    stopLog(my_log, "junk")

    stopLog(my_log, "stuff")
    @test my_log.root.sub_timing_entries["stuff"].time > 0
end
