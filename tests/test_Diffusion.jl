@testset "Diffusion" begin
    var = Variable{Float64}(1, "u")

    diffusion = Diffusion(var)

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

    nodal_values = [0., 1., 1., 0.]

    MOOSE.reinit!(var, fe_values, [0,0,0,0], nodal_values)

    residual = zeros(Float64, var.n_dofs)

    # Test the Kernel Interface
    MOOSE.computeResidual!(residual, diffusion)

    # Verified by running the same problem in MOOSE
    moose_residual = [-0.5, 0.5, 0.5, -0.5]

    for i in 1:length(residual)
        @test abs(residual[i]-moose_residual[i]) < 1e-10
    end

    jacobian = zeros(Float64, var.n_dofs, var.n_dofs)

    MOOSE.computeJacobian!(jacobian, diffusion, var)


    moose_jac = [0.666666666667 -0.166666666667 -0.333333333333 -0.166666666667;
                 -0.166666666667 0.666666666667 -0.166666666667 -0.333333333333;
                 -0.333333333333 -0.166666666667 0.666666666667 -0.166666666667;
                 -0.166666666667 -0.333333333333 -0.166666666667 0.666666666667]

    for i in 1:length(jacobian)
        @test abs(jacobian[i] - moose_jac[i]) < 1e-9
    end
end


@testset "DiffusionFD" begin
    var = Variable{Dual{4, Float64}}(1, "u")

    diffusion = Diffusion(var)

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

    nodal_values = [MOOSE.dualVariable(0., 1, 4),
                    MOOSE.dualVariable(1., 2, 4),
                    MOOSE.dualVariable(1., 3, 4),
                    MOOSE.dualVariable(0., 4, 4)]

    MOOSE.reinit!(var, fe_values, [0,0,0,0], nodal_values)

    residual = zeros(Dual{4, Float64}, var.n_dofs)

    # Test the Kernel Interface
    MOOSE.computeResidual!(residual, diffusion)

    # Verified by running the same problem in MOOSE
    moose_residual = [-0.5, 0.5, 0.5, -0.5]

    for i in 1:length(residual)
        @test abs(residual[i]-moose_residual[i]) < 1e-10
    end

    jacobian = zeros(Float64, var.n_dofs, var.n_dofs)

    MOOSE.computeJacobian!(jacobian, diffusion, var)

    moose_jac = [0.666666666667 -0.166666666667 -0.333333333333 -0.166666666667;
                 -0.166666666667 0.666666666667 -0.166666666667 -0.333333333333;
                 -0.333333333333 -0.166666666667 0.666666666667 -0.166666666667;
                 -0.166666666667 -0.333333333333 -0.166666666667 0.666666666667]

    for i in 1:length(jacobian)
        @test abs(jacobian[i] - moose_jac[i]) < 1e-9
    end
end
