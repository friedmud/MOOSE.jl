@testset "Variable" begin
    var = Variable(2, "dog")

    @test var.id == 2
    @test var.name == "dog"
end
