@testset "Variable" begin
    var = Variable(2, "dog")

    @test var.id == 2
    @test var.name == "dog"

    # Generate shape function and Variable values for a dummy element
    qr = QuadratureRule{2,RefCube}(:legendre, 2)
    func_space = Lagrange{2, RefCube, 1}()
    fe_values = FECellValues(qr, func_space)
    n_qp = length(points(qr))

    # Nodal coordinates
    coords = Vec{2, Float64}[Vec{2}((-1, -1)),
                             Vec{2}((1, -1)),
                             Vec{2}((1, 1)),
                             Vec{2}((-1, 1))]

    reinit!(fe_values, coords)

    dof_values = [0., 1., 1., 0.]

    MOOSE.reinit!(var, fe_values, [1,2,3,4], dof_values)

    @test var.dofs == [1,2,3,4]
    @test var.n_dofs == 4
    @test var.n_qp == 4

    for grad in var.grad
        @test abs(grad[1] - 0.5) < 1e-9
        @test abs(grad[2] - 0.0) < 1e-9
    end

    # Test reinit at a node
    MOOSE.reinit!(var, 3, 2.7)

    @test var.nodal_dof == 3
    @test var.nodal_value == 2.7
end
