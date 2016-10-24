type DummyKernel <: Kernel
end

@testset "Kernel" begin
    residual = Vector{Float64}(0)

    dummy_kernel = DummyKernel()

    # Test the Kernel Interface
    @test_throws MethodError MOOSE.computeQpResidual(dummy_kernel, 1, 1)
end
