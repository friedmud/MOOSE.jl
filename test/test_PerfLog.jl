@testset "PerfLog.jl" begin
    my_log = PerfLog()
    startLog(my_log, "stuff")

    @test "stuff" in keys(my_log.times)
    @test my_log.times["stuff"] == 0.

    stopLog(my_log, "stuff")
    @test my_log.times["stuff"] > 0
end
